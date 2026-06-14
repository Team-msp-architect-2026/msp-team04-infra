# MoMent Alerting Taxonomy

## Alert routes

- EKS/Application: PrometheusRule -> AlertmanagerConfig -> Slack
- AWS Managed Resource: CloudWatch Alarm -> SNS -> Lambda Slack Notifier -> Slack

## Severity

| Severity | Meaning | Response |
| --- | --- | --- |
| critical | Immediate service outage or customer impact | Start incident response immediately |
| high | High risk of outage or partial service impact | Check within 10-15 minutes |
| medium | Degradation or early warning | Check during operating hours |
| info | Deployment, recovery, or test notification | Record only |

## Standard Slack fields

- 알람명
- 설명
- 심각도
- 환경
- 서비스
- 영역
- 사유
- 현재값
- 기준값
- 담당자
- 조치
- Runbook

## Rules

- Do not store Slack webhook URLs in Git.
- Do not create fake alerts for metrics that are not actually scraped.
- Do not use manual Grafana UI-only configuration as the source of truth.
- CloudWatch alarms and Prometheus alerts must use the same severity and owner taxonomy.
