import json
import os
import urllib.error
import urllib.request

import boto3


secretsmanager = boto3.client("secretsmanager")


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
                    title="MoMent Alert Test",
                    environment=os.environ.get("ENVIRONMENT", "unknown"),
                    source="cloudwatch",
                    state="TEST",
                    summary="Lambda Slack notifier invoked without SNS records.",
                    detail="This message verifies the Slack notifier path without exposing secrets.",
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
                summary=raw_message[:1000],
                detail="Received non-JSON SNS message.",
            )
        }

    alarm_name = payload.get("AlarmName", subject)
    state = payload.get("NewStateValue", "UNKNOWN")
    previous_state = payload.get("OldStateValue", "UNKNOWN")
    reason = payload.get("NewStateReason", "")
    region = payload.get("Region", "")
    trigger = payload.get("Trigger", {}) or {}
    namespace = trigger.get("Namespace", "")
    metric_name = trigger.get("MetricName", "")
    dimensions = trigger.get("Dimensions", []) or []

    dimension_text = ", ".join(
        f"{item.get('name')}={item.get('value')}"
        for item in dimensions
        if item.get("name") and item.get("value")
    )

    return {
        "text": _format_plain_text(
            title=alarm_name,
            environment=environment,
            source="cloudwatch",
            state=state,
            summary=f"{previous_state} -> {state}",
            detail=reason,
            extra_lines=[
                f"*Region:* {region}" if region else "",
                f"*Metric:* {namespace}/{metric_name}" if namespace or metric_name else "",
                f"*Dimensions:* {dimension_text}" if dimension_text else "",
            ],
        )
    }


def _format_plain_text(title, environment, source, state, summary, detail, extra_lines=None):
    lines = [
        f"*[{state}][{environment}][{source}] {title}*",
        f"*Summary:* {summary}",
    ]

    if detail:
        lines.append(f"*Detail:* {detail}")

    for line in extra_lines or []:
        if line:
            lines.append(line)

    lines.append("*Action:* Check CloudWatch alarm, related AWS resource metrics, and recent deployment/runtime changes.")

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
