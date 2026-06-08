# MoMent Grafana Dashboards

This directory stores Grafana dashboards as Kubernetes ConfigMaps.

## Delivery model

Grafana dashboards are managed through GitOps:

1. ArgoCD applies ConfigMaps from this directory.
2. kube-prometheus-stack Grafana sidecar discovers dashboard ConfigMaps.
3. Grafana loads JSON dashboards from ConfigMap data.

## Discovery contract

The kube-prometheus-stack Grafana sidecar discovers ConfigMaps with:

- namespace: monitoring
- label: grafana_dashboard="1"

## Dashboard list

- application-business-overview.json
  - Backend HTTP request rate / error rate / latency
  - Application business events
  - Payment business events
  - Search business metrics
  - Recommendation business metrics
  - Backend JVM / CPU runtime metrics
  - Backend / AI target up status

## Source of truth

Manual Grafana UI imports are allowed only for temporary validation.

The final dashboard source of truth is this GitOps directory.
