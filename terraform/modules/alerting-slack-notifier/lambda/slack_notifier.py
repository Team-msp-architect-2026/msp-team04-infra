import json
import os
import urllib.error
import urllib.request

import boto3


secretsmanager = boto3.client("secretsmanager")

SEVERITY_DISPLAY = {
    "critical": "CRITICAL",
    "high": "HIGH",
    "medium": "MEDIUM",
    "info": "INFO",
}


def lambda_handler(event, context):
    webhook_url = _load_slack_webhook_url()

    messages = []
    for record in event.get("Records", []):
        sns = record.get("Sns", {})
        subject = sns.get("Subject", "MoMent Alert")
        raw_message = sns.get("Message", "")
        messages.append(_format_message(subject, raw_message))

    if not messages:
        messages.append(
            {
                "text": _format_plain_text(
                    title="SlackNotifierTest",
                    environment=os.environ.get("ENVIRONMENT", "unknown"),
                    source="cloudwatch",
                    state="TEST",
                    severity="info",
                    alarm_name="SlackNotifierTest",
                    description="Slack notifier test invocation.",
                    service="alerting",
                    category="notification",
                    reason="Lambda invoked without SNS records.",
                    current_value="TEST",
                    threshold_text="N/A",
                    owner="Infra/Observability",
                    action_hint="Check Lambda invocation result and Slack delivery.",
                    runbook_url="docs/runbooks/slack-notifier.md",
                    extra_lines=[],
                )
            }
        )

    for message in messages:
        _post_to_slack(webhook_url, message)

    return {
        "statusCode": 200,
        "body": json.dumps(
            {
                "delivered": len(messages),
                "environment": os.environ.get("ENVIRONMENT", "unknown"),
            }
        ),
    }


def _load_slack_webhook_url():
    secret_name = os.environ["SLACK_WEBHOOK_SECRET_NAME"]
    secret_value = secretsmanager.get_secret_value(SecretId=secret_name)
    secret_string = secret_value.get("SecretString", "")

    if not secret_string:
        raise ValueError("Slack webhook secret has no SecretString.")

    try:
        parsed = json.loads(secret_string)
        webhook_url = parsed.get("url", "")
    except json.JSONDecodeError:
        webhook_url = secret_string

    webhook_url = webhook_url.strip()
    if not webhook_url:
        raise ValueError("Slack webhook URL is empty.")

    return webhook_url


def _format_message(subject, raw_message):
    environment = os.environ.get("ENVIRONMENT", "unknown")

    try:
        payload = json.loads(raw_message)
    except json.JSONDecodeError:
        return {
            "text": _format_plain_text(
                title=subject,
                environment=environment,
                source="cloudwatch",
                state="UNKNOWN",
                severity="info",
                alarm_name=subject,
                description="Received non-JSON SNS message.",
                service="unknown",
                category="cloudwatch",
                reason="SNS message was not a CloudWatch Alarm JSON payload.",
                current_value=raw_message[:1000],
                threshold_text="N/A",
                owner="Infra/Observability",
                action_hint="Check SNS publisher and CloudWatch alarm action configuration.",
                runbook_url="docs/runbooks/cloudwatch-alert.md",
                extra_lines=[],
            )
        }

    alarm_name = payload.get("AlarmName", subject)
    state = payload.get("NewStateValue", "UNKNOWN")
    previous_state = payload.get("OldStateValue", "UNKNOWN")
    state_reason = payload.get("NewStateReason", "")
    region = payload.get("Region", "")
    trigger = payload.get("Trigger", {}) or {}
    namespace = trigger.get("Namespace", "")
    metric_name = trigger.get("MetricName", "")
    dimensions = trigger.get("Dimensions", []) or []

    metadata = _parse_alarm_metadata(payload.get("AlarmDescription", ""))

    severity = metadata.get("severity", "info")
    display_name = metadata.get("display_name", alarm_name)
    description = metadata.get("description", metadata.get("summary", f"{previous_state} -> {state}"))
    service = metadata.get("service", _infer_service(namespace))
    category = metadata.get("category", "aws")
    owner = metadata.get("owner", "Infra/Observability")
    reason = metadata.get("reason", state_reason or f"{previous_state} -> {state}")
    threshold_text = metadata.get("threshold_text", _format_threshold_text(trigger))
    action_hint = metadata.get(
        "action_hint",
        "Check CloudWatch alarm, related AWS resource metrics, and recent deployment/runtime changes.",
    )
    runbook_url = metadata.get("runbook_url", "docs/runbooks/cloudwatch-alert.md")

    dimension_text = ", ".join(
        f"{item.get('name')}={item.get('value')}"
        for item in dimensions
        if item.get("name") and item.get("value")
    )

    extra_lines = [
        f"*AWS Region:* {region}" if region else "",
        f"*Metric:* {namespace}/{metric_name}" if namespace or metric_name else "",
        f"*Dimensions:* {dimension_text}" if dimension_text else "",
        f"*CloudWatch Alarm:* {alarm_name}",
    ]

    return {
        "text": _format_plain_text(
            title=display_name,
            environment=environment,
            source="cloudwatch",
            state=state,
            severity=severity,
            alarm_name=display_name,
            description=description,
            service=service,
            category=category,
            reason=reason,
            current_value=state_reason or f"{previous_state} -> {state}",
            threshold_text=threshold_text,
            owner=owner,
            action_hint=action_hint,
            runbook_url=runbook_url,
            extra_lines=extra_lines,
        )
    }


def _parse_alarm_metadata(description):
    if not description:
        return {}

    try:
        parsed = json.loads(description)
    except json.JSONDecodeError:
        return {
            "summary": description,
            "description": description,
        }

    if not isinstance(parsed, dict):
        return {}

    return {str(key): str(value) for key, value in parsed.items() if value is not None}


def _format_threshold_text(trigger):
    metric_name = trigger.get("MetricName", "metric")
    comparison = trigger.get("ComparisonOperator", "comparison")
    threshold = trigger.get("Threshold", "")
    period = trigger.get("Period", "")
    evaluation_periods = trigger.get("EvaluationPeriods", "")

    duration = ""
    if period and evaluation_periods:
        try:
            duration_seconds = int(period) * int(evaluation_periods)
            if duration_seconds % 60 == 0:
                duration = f" for {duration_seconds // 60}m"
            else:
                duration = f" for {duration_seconds}s"
        except (TypeError, ValueError):
            duration = ""

    return f"{metric_name} {comparison} {threshold}{duration}".strip()


def _infer_service(namespace):
    if namespace == "AWS/RDS":
        return "rds-postgres"
    if namespace == "AWS/ElastiCache":
        return "redis"
    if namespace == "AWS/ES":
        return "opensearch"
    if namespace == "AWS/SQS":
        return "sqs"
    if namespace == "AWS/Lambda":
        return "lambda"
    if namespace == "AWS/ApplicationELB":
        return "alb"
    return "unknown"


def _status_label(state, severity):
    normalized_state = str(state).upper()
    normalized_severity = str(severity).lower()

    if normalized_state == "OK":
        return "RESOLVED"
    if normalized_state == "ALARM":
        return SEVERITY_DISPLAY.get(normalized_severity, normalized_severity.upper())
    return normalized_state


def _format_plain_text(
    title,
    environment,
    source,
    state,
    severity,
    alarm_name,
    description,
    service,
    category,
    reason,
    current_value,
    threshold_text,
    owner,
    action_hint,
    runbook_url,
    extra_lines=None,
):
    label = _status_label(state, severity)
    severity_text = SEVERITY_DISPLAY.get(str(severity).lower(), str(severity).upper())

    lines = [
        f"*[{label}] [{environment}] {title}*",
        "",
        f"*알람명:* {alarm_name}",
        f"*설명:* {description}",
        f"*심각도:* {severity_text}",
        f"*환경:* {environment}",
        f"*서비스:* {service}",
        f"*영역:* {category}",
        f"*사유:* {reason}",
        f"*현재값:* {current_value}",
        f"*기준값:* {threshold_text}",
        f"*담당자:* {owner}",
        f"*조치:* {action_hint}",
        f"*Runbook:* {runbook_url}",
    ]

    for line in extra_lines or []:
        if line:
            lines.append(line)

    lines.append(f"*Source:* {source}")

    return "\n".join(lines)


def _post_to_slack(webhook_url, message):
    body = json.dumps(message).encode("utf-8")
    request = urllib.request.Request(
        webhook_url,
        data=body,
        headers={"Content-Type": "application/json"},
        method="POST",
    )

    try:
        with urllib.request.urlopen(request, timeout=10) as response:
            status = response.getcode()
            if status < 200 or status >= 300:
                raise RuntimeError(f"Slack webhook returned non-2xx status: {status}")
    except urllib.error.HTTPError as exc:
        raise RuntimeError(f"Slack webhook HTTP error: {exc.code}") from exc
    except urllib.error.URLError as exc:
        raise RuntimeError("Slack webhook request failed.") from exc
