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
                    source="manual",
                    state="TEST",
                    summary="Lambda Slack notifier invoked without SNS records.",
                    detail="This message verifies the Slack notifier path without exposing secrets.",
                    service="alerting",
                    severity="INFO",
                    owner="Infra/Observability",
                    action="Confirm Lambda invocation path and Slack webhook secret.",
                    runbook="docs/runbooks/",
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
                source="sns",
                state="UNKNOWN",
                summary=raw_message[:1000],
                detail="Received non-JSON SNS message.",
                service=_service_from_text(subject),
                severity=_severity_from_text(subject),
                owner=_owner_from_text(subject),
                action=_action_from_text(subject),
                runbook=_runbook_from_text(subject),
            )
        }

    if "AlarmName" in payload:
        return _format_cloudwatch_alarm(subject, payload, environment)

    if "Event Source" in payload or "Source ID" in payload or "Event Message" in payload:
        return _format_aws_service_event(subject, payload, environment)

    if "source" in payload or "detail-type" in payload or "detail" in payload:
        return _format_eventbridge_event(subject, payload, environment)

    text = json.dumps(payload, ensure_ascii=False)[:1500]
    return {
        "text": _format_plain_text(
            title=subject,
            environment=environment,
            source="sns",
            state="EVENT",
            summary=subject,
            detail=text,
            service=_service_from_text(subject + text),
            severity=_severity_from_text(subject + text),
            owner=_owner_from_text(subject + text),
            action=_action_from_text(subject + text),
            runbook=_runbook_from_text(subject + text),
        )
    }


def _format_cloudwatch_alarm(subject, payload, environment):
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
            service=_service_from_text(alarm_name),
            severity=_severity_from_text(alarm_name, state),
            owner=_owner_from_text(alarm_name),
            action=_action_from_text(alarm_name),
            runbook=_runbook_from_text(alarm_name),
            extra_lines=[
                f"*Region:* {region}" if region else "",
                f"*Metric:* {namespace}/{metric_name}" if namespace or metric_name else "",
                f"*Dimensions:* {dimension_text}" if dimension_text else "",
            ],
        )
    }


def _format_aws_service_event(subject, payload, environment):
    source = payload.get("Event Source", "aws-service-event")
    source_id = payload.get("Source ID", "")
    message = payload.get("Event Message", payload.get("Message", json.dumps(payload, ensure_ascii=False)))
    event_id = payload.get("Event ID", payload.get("EventID", subject))

    text_seed = f"{subject} {source} {source_id} {message}"
    return {
        "text": _format_plain_text(
            title=event_id or subject,
            environment=environment,
            source=source,
            state="EVENT",
            summary=message,
            detail=json.dumps(payload, ensure_ascii=False)[:1500],
            service=_service_from_text(text_seed),
            severity=_severity_from_text(text_seed),
            owner=_owner_from_text(text_seed),
            action=_action_from_text(text_seed),
            runbook=_runbook_from_text(text_seed),
            extra_lines=[
                f"*Source ID:* {source_id}" if source_id else "",
            ],
        )
    }


def _format_eventbridge_event(subject, payload, environment):
    detail_type = payload.get("detail-type", subject)
    source = payload.get("source", "eventbridge")
    detail = payload.get("detail", {}) or {}
    detail_text = json.dumps(detail, ensure_ascii=False)[:1500]

    text_seed = f"{subject} {detail_type} {source} {detail_text}"
    return {
        "text": _format_plain_text(
            title=detail_type,
            environment=environment,
            source=source,
            state="EVENT",
            summary=detail.get("Message", detail.get("message", detail_type)),
            detail=detail_text,
            service=_service_from_text(text_seed),
            severity=_severity_from_text(text_seed),
            owner=_owner_from_text(text_seed),
            action=_action_from_text(text_seed),
            runbook=_runbook_from_text(text_seed),
        )
    }


def _format_plain_text(title, environment, source, state, summary, detail, service, severity, owner, action, runbook, extra_lines=None):
    display_severity = severity.upper()
    lines = [
        f"*[{display_severity}][{environment}][{service}] {title}*",
        f"*알람명:* {title}",
        f"*설명:* {summary}",
        f"*심각도:* {display_severity}",
        f"*서비스:* {service}",
        f"*환경:* {environment}",
        f"*소스:* {source}",
        f"*상태:* {state}",
    ]

    if detail:
        lines.append(f"*사유:* {detail}")

    for line in extra_lines or []:
        if line:
            lines.append(line)

    lines.extend(
        [
            f"*담당자:* {owner}",
            f"*조치:* {action}",
            f"*Runbook:* {runbook}",
        ]
    )

    return "\n".join(lines)


def _service_from_text(text):
    value = (text or "").lower()
    if "backend" in value:
        return "backend-api"
    if "ai" in value and "service" in value:
        return "ai-service"
    if "batch" in value:
        return "batch-job"
    if "rds" in value or "postgres" in value or "database" in value:
        return "rds-postgres"
    if "elasticache" in value or "redis" in value:
        return "redis"
    if "opensearch" in value or "es/" in value:
        return "opensearch"
    if "lambda" in value:
        return "lambda-collector"
    if "sqs" in value or "queue" in value or "dlq" in value:
        return "sqs"
    if "alb" in value or "loadbalancer" in value or "targetgroup" in value:
        return "alb"
    if "argocd" in value:
        return "argocd"
    return "unknown"


def _severity_from_text(text, state=""):
    value = (text or "").lower()
    if state == "OK":
        return "INFO"
    if any(token in value for token in ["critical", "healthyhostzero", "clusterred", "dlq", "failover"]):
        return "CRITICAL"
    if any(token in value for token in ["high", "5xx", "latency", "crashloop", "degraded", "yellow", "eviction", "error"]):
        return "HIGH"
    if any(token in value for token in ["medium", "backlog", "throttle", "restart", "hpa", "oldmessage"]):
        return "MEDIUM"
    return "INFO"


def _owner_from_text(text):
    service = _service_from_text(text)
    if service in ["backend-api", "alb"]:
        return "Backend/Infra"
    if service == "ai-service":
        return "AI/Infra"
    if service in ["batch-job", "sqs", "lambda-collector"]:
        return "Data/Infra"
    if service in ["rds-postgres", "redis", "opensearch"]:
        return "Data/Infra"
    if service == "argocd":
        return "Infra"
    return "Infra/Observability"


def _action_from_text(text):
    value = (text or "").lower()
    if "failover" in value and ("rds" in value or "database" in value):
        return "Check RDS event timeline, writer endpoint, application reconnect behavior, and DB health."
    if "elasticache" in value or "redis" in value:
        return "Check ElastiCache events, primary endpoint, memory pressure, evictions, and application Redis errors."
    if "crashloop" in value:
        return "Check current and previous pod logs, exit code, env vars, secrets, and dependency errors."
    if "argocd" in value or "degraded" in value:
        return "Run argocd app get, inspect degraded resources, sync errors, events, and reconcile GitOps source."
    if "dlq" in value:
        return "Inspect DLQ messages, identify consumer failure, fix root cause, then replay safely."
    if "alb" in value or "loadbalancer" in value:
        return "Check Ingress, ALB listener/rules, target health, backend endpoints, and pod readiness."
    if "opensearch" in value:
        return "Check OpenSearch cluster health, shards, nodes, JVM pressure, and storage."
    if "lambda" in value:
        return "Check Lambda logs, timeout, IAM permissions, external API response, and retry/DLQ state."
    if "rds" in value or "database" in value:
        return "Check Performance Insights, DB connections, slow queries, storage, and recent deployments."
    return "Check related metrics, logs, events, runbook, and recent deployments."


def _runbook_from_text(text):
    value = (text or "").lower().replace("-", "").replace("_", "")
    mapping = [
        ("rdsfailover", "docs/runbooks/rds-failover-event.md"),
        ("failover", "docs/runbooks/rds-failover-event.md"),
        ("elasticache", "docs/runbooks/redis-failover-event.md"),
        ("redis", "docs/runbooks/redis-failover-event.md"),
        ("crashloop", "docs/runbooks/pod-crashloop.md"),
        ("argocd", "docs/runbooks/argocd-app-degraded.md"),
        ("degraded", "docs/runbooks/argocd-app-degraded.md"),
        ("restart", "docs/runbooks/pod-restart-spike.md"),
        ("rdscpu", "docs/runbooks/rds-cpu-high.md"),
        ("rdsfreestorage", "docs/runbooks/rds-free-storage-low.md"),
        ("dlq", "docs/runbooks/sqs-dlq-messages-visible.md"),
        ("backlog", "docs/runbooks/sqs-backlog-high.md"),
        ("alb5xx", "docs/runbooks/alb-5xx-high.md"),
        ("latency", "docs/runbooks/alb-latency-high.md"),
        ("opensearchclusterred", "docs/runbooks/opensearch-cluster-red.md"),
        ("opensearchclusteryellow", "docs/runbooks/opensearch-cluster-yellow.md"),
        ("lambdaerror", "docs/runbooks/lambda-error-high.md"),
        ("eviction", "docs/runbooks/redis-evictions-detected.md"),
    ]

    for token, runbook in mapping:
        if token in value:
            return runbook

    return "docs/runbooks/"


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
