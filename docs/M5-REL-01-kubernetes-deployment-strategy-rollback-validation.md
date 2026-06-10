# [M5-REL-01] Kubernetes 배포 전략 / RollingUpdate / Rollback 정합성 검증

## 1. 목적

MoMent의 Backend API, AI Service, Batch Worker가 Kubernetes / Helm / GitOps / ArgoCD 기준으로 어떤 배포 전략을 사용하는지 검증하고, RollingUpdate 및 rollback 정합성을 보완한다.

이번 검증은 단순 문서화가 아니라 실제 repository, Helm rendered manifest, live Kubernetes Deployment 상태를 기준으로 수행한다.

검증 및 보완 대상은 다음과 같다.

- 현재 배포 전략이 RollingUpdate인지 확인
- Blue/Green 또는 Canary 구성이 존재하는지 확인
- Dev / Prod ArgoCD sync policy 차이 확인
- Helm values와 rendered manifest의 정합성 확인
- live Deployment rollout 상태 확인
- Backend API readinessProbe 정확도 보완
- AI Service Pod 분산 유도 정책 보완
- Batch Worker Deployment strategy 렌더링 정합성 보완
- rollback 기준을 GitOps 관점에서 정리
- old/new Pod 공존 시 API, DB migration, mobile app, SQS worker 호환성 리스크 정리

## 2. 검증 기준

검증 기준 브랜치와 커밋은 다음과 같다.

- branch: feature/kubernetes-deployment-strategy-rollback
- base develop HEAD: 3ddeedb [#339] External Secrets / Secrets Manager 운영 정합성 강화
- evidence directory: tmp/m5-rel-01-initial-20260610-231024

검증 대상 workload는 다음과 같다.

- backend-api
- ai-service
- batch-job

검증 대상 환경은 다음과 같다.

- dev
- prod

## 3. 최종 결론

현재 MoMent의 Kubernetes 배포 전략은 Blue/Green 또는 Canary가 아니다.

현재 구조는 다음 방식이다.

1. GitOps values에서 image tag 또는 배포 설정을 변경한다.
2. ArgoCD Application이 Helm Chart를 렌더링한다.
3. Kubernetes Deployment가 RollingUpdate 방식으로 ReplicaSet을 전환한다.
4. readinessProbe를 통과한 Pod만 Service endpoint에 편입된다.
5. rollback은 Git revert 또는 이전 정상 image tag로 GitOps values를 되돌린 뒤 ArgoCD sync하는 방식이 원칙이다.

kubectl rollout undo는 Git desired state와 live state를 어긋나게 만들 수 있으므로 최종 운영 rollback 절차가 아니다. 긴급 containment 후보로만 분리한다.

이번 검증에서 다음 보완을 같은 PR 범위에 포함했다.

- batch-job Deployment template에 `.Values.strategy` 렌더링 추가
- backend-api dev/prod readinessProbe를 `tcpSocket`에서 `httpGet /health`로 변경
- ai-service dev/prod에 preferred podAntiAffinity 추가

## 4. ArgoCD sync policy 검증 결과

### 4.1 Dev

Dev workload Application은 automated sync가 활성화되어 있다.

- backend-api-dev: automated sync, prune false, selfHeal true
- ai-service-dev: automated sync, prune false, selfHeal true
- batch-job-dev: automated sync, prune true, selfHeal true

Dev는 develop 변경을 빠르게 반영하여 검증하는 환경이다.

### 4.2 Prod

Prod workload Application은 automated sync가 없다.

- backend-api-prod: manual sync
- ai-service-prod: manual sync
- batch-job-prod: manual sync, PruneLast true

Prod는 GitOps desired state 변경 후에도 운영자가 ArgoCD sync를 명시적으로 수행해야 반영되는 구조다.

이 구조는 Prod 배포 통제 관점에서 타당하다.

## 5. Blue/Green / Canary 검증 결과

repository static scan 및 runtime read-only check 기준으로 다음 구성이 발견되지 않았다.

- Argo Rollouts Rollout kind
- blueGreen strategy
- canary strategy
- setWeight
- previewService
- activeService
- trafficRouting
- weighted traffic shifting

따라서 현재 MoMent의 Kubernetes 배포 전략은 Blue/Green / Canary가 아니라 RollingUpdate다.

## 6. Helm lint / template 검증 결과

최종 검증에서 다음 6개 조합의 Helm lint 및 Helm template이 모두 성공했다.

- backend-api-dev
- backend-api-prod
- ai-service-dev
- ai-service-prod
- batch-job-dev
- batch-job-prod

최종 결과는 다음과 같다.

- backend-api-dev HELM_LINT_EXIT=0
- backend-api-dev HELM_TEMPLATE_EXIT=0
- backend-api-prod HELM_LINT_EXIT=0
- backend-api-prod HELM_TEMPLATE_EXIT=0
- ai-service-dev HELM_LINT_EXIT=0
- ai-service-dev HELM_TEMPLATE_EXIT=0
- ai-service-prod HELM_LINT_EXIT=0
- ai-service-prod HELM_TEMPLATE_EXIT=0
- batch-job-dev HELM_LINT_EXIT=0
- batch-job-dev HELM_TEMPLATE_EXIT=0
- batch-job-prod HELM_LINT_EXIT=0
- batch-job-prod HELM_TEMPLATE_EXIT=0

## 7. Workload별 배포 전략

### 7.1 backend-api

#### Dev

- HPA enabled
- minReplicas: 1
- maxReplicas: 2
- strategy: RollingUpdate
- maxSurge: 1
- maxUnavailable: 1
- readinessProbe: HTTP GET /health
- livenessProbe: tcpSocket 8080
- PDB disabled

Dev는 replica 1 기반 환경이므로 rollout 중 일시 중단 가능성을 허용한다.

#### Prod

- HPA enabled
- minReplicas: 2
- maxReplicas: 4
- strategy: RollingUpdate
- maxSurge: 1
- maxUnavailable: 0
- readinessProbe: HTTP GET /health
- livenessProbe: tcpSocket 8080
- PDB enabled
- PDB minAvailable: 1

Prod backend-api는 maxUnavailable 0으로 무중단 배포를 지향한다. 새 Pod가 준비되기 전 기존 Pod를 줄이지 않는 방향이다.

기존 backend-api readinessProbe는 tcpSocket 8080이었다. tcpSocket은 포트 open 여부만 확인하므로 HTTP handler가 정상 응답하는지 확인하지 못한다. live read-only check에서 `/health` endpoint가 dev/prod 모두 200으로 확인되어 readinessProbe를 HTTP GET `/health`로 보완했다.

`/actuator/health/readiness`는 dev/prod 모두 401이므로 readinessProbe로 사용하지 않았다. `/actuator/health`는 prod에서는 200이지만 dev에서는 timeout이 발생했으므로 dev/prod 공통 readinessProbe로 사용하지 않았다.

### 7.2 ai-service

#### Dev

- replicaCount: 1
- strategy: RollingUpdate
- maxSurge: 1
- maxUnavailable: 1
- startupProbe: HTTP GET /health
- readinessProbe: HTTP GET /health
- livenessProbe: HTTP GET /health
- PDB disabled
- preferred podAntiAffinity enabled

#### Prod

- replicaCount: 2
- strategy: RollingUpdate
- maxSurge: 1
- maxUnavailable: 0
- startupProbe: HTTP GET /health
- readinessProbe: HTTP GET /health
- livenessProbe: HTTP GET /health
- PDB enabled
- PDB minAvailable: 1
- preferred podAntiAffinity enabled

Prod ai-service는 maxUnavailable 0과 PDB를 통해 중단 위험을 줄인다.

runtime check에서 Prod ai-service Pod 2개가 같은 node에 스케줄된 상태가 확인되었다. 다만 현재 Prod에서 `workload=ai`, `capacity=spot` 조건을 만족하는 node는 1개뿐이다. 따라서 required podAntiAffinity를 적용하면 replica 2 중 하나가 Pending 될 수 있다.

이 PR에서는 required anti-affinity를 적용하지 않고 preferred podAntiAffinity를 적용한다. 이 방식은 현재 capacity 부족 상황에서 Pending을 유발하지 않으며, 향후 AI node가 2개 이상으로 확장되면 hostname 및 zone 기준 분산을 유도한다.

### 7.3 batch-job

batch-job은 현재 CronJob이 아니라 SQS polling worker Deployment mode로 동작한다.

#### Dev

- mode: worker
- replicaCount: 1
- strategy: RollingUpdate
- maxSurge: 1
- maxUnavailable: 1
- PDB disabled

#### Prod

- mode: worker
- replicaCount: 1
- strategy: RollingUpdate
- maxSurge: 1
- maxUnavailable: 1
- PDB disabled

batch-job은 replica 1이고 SQS message 재처리 가능성을 전제로 한다. 따라서 backend-api / ai-service처럼 무중단 serving을 보장하는 것이 아니라 worker replacement와 message retry / idempotency가 핵심이다.

replica 1 worker에 PDB minAvailable 1을 적용하면 node drain이 막힐 수 있으므로 현재 PDB disabled 정책은 타당하다.

## 8. 발견한 정합성 문제 및 보완

### 8.1 batch-job strategy 렌더링 누락

batch-job values에는 strategy 설정이 존재했다.

- gitops/values/dev/batch-job-values.yaml
- gitops/values/prod/batch-job-values.yaml

두 values 모두 다음 의도를 가진다.

- type: RollingUpdate
- maxSurge: 1
- maxUnavailable: 1

하지만 기존 batch-job Deployment template에는 `.Values.strategy`를 렌더링하는 블록이 없었다.

그 결과 수정 전 rendered manifest의 batch-job Deployment에는 strategy가 명시되지 않았다.

Kubernetes Deployment는 strategy가 생략되면 기본 RollingUpdate 값을 사용한다. runtime read-only check에서도 live batch-job은 maxSurge 25%, maxUnavailable 25%로 확인되었다.

즉 values의 의도와 rendered/live manifest가 불일치했다.

보완 내용은 다음과 같다.

- gitops/charts/batch-job/templates/deployment.yaml에 `.Values.strategy` 렌더링 추가

수정 후 Helm template 결과에서 batch-job dev/prod 모두 strategy가 명시적으로 렌더링됨을 확인했다.

- batch-job-dev: RollingUpdate, maxSurge 1, maxUnavailable 1
- batch-job-prod: RollingUpdate, maxSurge 1, maxUnavailable 1

### 8.2 backend-api readinessProbe 정확도 보완

기존 backend-api readinessProbe는 tcpSocket 8080이었다.

검증 결과는 다음과 같다.

- dev `/actuator/health/readiness`: 401
- prod `/actuator/health/readiness`: 401
- dev `/actuator/health`: timeout
- prod `/actuator/health`: 200
- dev `/health`: 200
- prod `/health`: 200

따라서 dev/prod 공통으로 사용 가능한 HTTP readiness endpoint는 `/health`다.

보완 내용은 다음과 같다.

- gitops/values/dev/backend-api-values.yaml readinessProbe를 HTTP GET /health로 변경
- gitops/values/prod/backend-api-values.yaml readinessProbe를 HTTP GET /health로 변경

livenessProbe는 기존 tcpSocket 8080을 유지한다. liveness는 과도하게 application dependency에 민감하게 잡으면 불필요한 restart를 유발할 수 있으므로 이번 범위에서는 readiness만 보완한다.

### 8.3 ai-service preferred podAntiAffinity 보완

기존 ai-service dev/prod affinity는 `{}`였다.

runtime check에서 prod ai-service Pod 2개가 동일 node에 배치되어 있었다. 하지만 현재 prod eligible AI node는 1개뿐이었다.

따라서 required podAntiAffinity는 적용하지 않는다. required로 강제하면 replica 2 중 하나가 Pending 될 수 있다.

보완 내용은 다음과 같다.

- gitops/values/dev/ai-service-values.yaml에 preferred podAntiAffinity 추가
- gitops/values/prod/ai-service-values.yaml에 preferred podAntiAffinity 추가
- hostname 기준 weight 100
- zone 기준 weight 50

이 설정은 현재 capacity에서 Pending을 유발하지 않고, 향후 AI node가 2개 이상이 되면 같은 node / 같은 zone 집중을 줄이도록 스케줄링을 유도한다.

## 9. Runtime read-only 검증 결과

### 9.1 EKS Cluster

Dev / Prod EKS cluster 모두 ACTIVE 상태로 확인했다.

- moment-dev-eks-cluster: ACTIVE, Kubernetes 1.35
- moment-prod-eks-cluster: ACTIVE, Kubernetes 1.35

### 9.2 Dev workload live state

moment-dev namespace에서 다음 상태를 확인했다.

- ai-service: 1/1 Ready
- backend-api: 1/1 Ready
- batch-job: 1/1 Ready
- backend-api HPA: min 1, max 2, cpu target 70%

rollout status는 다음 workload 모두 successfully rolled out 상태다.

- backend-api
- ai-service
- batch-job

live strategy는 다음과 같다.

- backend-api: RollingUpdate, maxSurge 1, maxUnavailable 1
- ai-service: RollingUpdate, maxSurge 1, maxUnavailable 1
- batch-job: RollingUpdate, maxSurge 25%, maxUnavailable 25%

Dev batch-job의 25% / 25% 값은 PR merge / ArgoCD sync 전 기존 live state다.

### 9.3 Prod workload live state

moment-prod namespace에서 다음 상태를 확인했다.

- ai-service: 2/2 Ready
- backend-api: 2/2 Ready
- batch-job: 1/1 Ready
- backend-api HPA: min 2, max 4, cpu target 70%
- backend-api PDB: minAvailable 1
- ai-service PDB: minAvailable 1

rollout status는 다음 workload 모두 successfully rolled out 상태다.

- backend-api
- ai-service
- batch-job

live strategy는 다음과 같다.

- backend-api: RollingUpdate, maxSurge 1, maxUnavailable 0
- ai-service: RollingUpdate, maxSurge 1, maxUnavailable 0
- batch-job: RollingUpdate, maxSurge 25%, maxUnavailable 25%

Prod batch-job의 25% / 25% 값도 PR merge / ArgoCD sync 전 기존 live state다.

### 9.4 Live와 rendered manifest 차이

이번 PR 변경 사항은 아직 live cluster에 반영되지 않았다.

따라서 PR merge 및 ArgoCD sync 전까지 live cluster에서는 다음 차이가 남는다.

- backend-api live readinessProbe는 기존 tcpSocket일 수 있다.
- ai-service live affinity는 기존 `{}`일 수 있다.
- batch-job live strategy는 Kubernetes 기본값 25% / 25%일 수 있다.

Post-merge 검증에서 이 차이가 해소되어야 한다.

## 10. Rollback 운영 원칙

### 10.1 권장 방식

Prod rollback은 GitOps 기준으로 수행한다.

1. 장애가 발생한 배포 commit 또는 image tag를 확인한다.
2. 마지막 정상 image tag를 확인한다.
3. GitOps values의 image tag를 마지막 정상 tag로 되돌린다.
4. PR을 생성하고 리뷰한다.
5. Prod ArgoCD Application을 manual sync한다.
6. rollout status, Pod, endpoint, application smoke를 확인한다.
7. Grafana / CloudWatch / ArgoCD 상태로 회복 여부를 확인한다.

### 10.2 제한 방식

다음 방식은 최종 운영 rollback 절차로 사용하지 않는다.

- kubectl patch
- kubectl set image
- kubectl rollout undo

위 방식은 Git desired state와 live state를 어긋나게 만들 수 있다.

단, 심각 장애 상황에서 긴급 containment로 사용할 수는 있다. 이 경우에도 반드시 GitOps desired state를 같은 상태로 맞춰야 한다.

## 11. Old/New Pod 공존 리스크

RollingUpdate는 old Pod와 new Pod가 일정 시간 공존할 수 있다. 따라서 다음 호환성 원칙이 필요하다.

### 11.1 API compatibility

- 기존 mobile app이 호출하는 API request / response contract를 깨지 않는다.
- response field 삭제 또는 rename을 한 번에 배포하지 않는다.
- 신규 field는 optional하게 추가한다.
- 인증 / 인가 정책 변경은 mobile app 배포 지연을 고려한다.

### 11.2 React Native / Expo Mobile App compatibility

MoMent client는 S3 / CloudFront 정적 웹 호스팅 대상이 아니라 React Native / Expo mobile app이다.

따라서 backend rolling deployment 중 다음 상황을 고려해야 한다.

- 사용자는 구버전 앱을 계속 사용할 수 있다.
- App Store / Google Play 심사 및 배포 지연이 있을 수 있다.
- Expo update channel 사용 여부에 따라 client update 속도가 달라질 수 있다.
- backend는 구버전 app request와 일정 기간 호환되어야 한다.

### 11.3 DB migration compatibility

RollingUpdate 중 old backend와 new backend가 같은 DB를 바라볼 수 있다.

따라서 DB migration은 다음 원칙을 지킨다.

- 컬럼 추가는 nullable 또는 default 기반으로 먼저 배포한다.
- rename / drop / type change는 한 번에 수행하지 않는다.
- destructive migration은 app 배포와 분리하고 단계적으로 수행한다.
- old app이 읽는 field / table을 new migration에서 즉시 제거하지 않는다.
- Flyway migration은 backward compatible하게 작성한다.

### 11.4 SQS worker compatibility

batch-job은 SQS polling worker 구조다.

따라서 다음 원칙을 지킨다.

- message schema 변경은 backward compatible해야 한다.
- worker는 동일 message 재처리에 대해 idempotent해야 한다.
- visibility timeout과 processing time을 고려한다.
- maxUnavailable 1로 worker가 일시 중단되어도 메시지 재처리 가능해야 한다.
- rollout 후 DLQ 증가 여부를 확인한다.

### 11.5 HPA / Node capacity compatibility

RollingUpdate maxSurge는 일시적으로 추가 Pod를 만들 수 있다.

따라서 다음 항목을 함께 확인해야 한다.

- node capacity가 maxSurge 추가 Pod를 수용할 수 있는지
- HPA scale-up과 rollout surge가 동시에 발생해도 Pending이 발생하지 않는지
- Spot node workload는 interruption 가능성을 고려하는지
- Prod maxUnavailable 0 workload는 추가 capacity가 없으면 rollout이 지연될 수 있음을 인지한다

## 12. Post-merge 검증 항목

PR merge 후 다음 read-only 검증을 수행한다.

1. ArgoCD Application sync 상태 확인
2. backend-api dev/prod live readinessProbe가 HTTP GET /health인지 확인
3. ai-service dev/prod live preferred podAntiAffinity가 반영되었는지 확인
4. batch-job dev/prod live Deployment strategy 확인
5. live batch-job에서 maxSurge 1, maxUnavailable 1 확인
6. backend-api / ai-service 기존 RollingUpdate 전략이 변하지 않았는지 확인
7. rollout status successfully rolled out 확인
8. Pod Ready / Endpoint 정상 확인
9. Blue/Green / Canary 리소스가 여전히 없는지 확인

Post-merge 기대 상태는 다음과 같다.

- dev backend-api: readinessProbe HTTP GET /health
- prod backend-api: readinessProbe HTTP GET /health
- dev ai-service: preferred podAntiAffinity rendered/live 반영
- prod ai-service: preferred podAntiAffinity rendered/live 반영
- dev batch-job: RollingUpdate, maxSurge 1, maxUnavailable 1
- prod batch-job: RollingUpdate, maxSurge 1, maxUnavailable 1

## 13. 최종 판단

이번 검증에서 다음을 확인했다.

- backend-api와 ai-service는 Helm values, rendered manifest, live Deployment 기준으로 RollingUpdate 전략이 정합하다.
- Prod backend-api와 ai-service는 maxUnavailable 0 및 PDB 기반으로 운영 중단 위험을 줄인다.
- batch-job은 values.strategy가 존재했으나 기존 chart template이 이를 렌더링하지 않아 values와 rendered/live manifest가 불일치했다.
- 이번 작업에서 batch-job Deployment template에 strategy 렌더링을 추가하여 Helm rendered manifest 정합성을 보완했다.
- backend-api readinessProbe는 tcpSocket에서 HTTP GET /health로 보완했다.
- ai-service는 required anti-affinity가 아니라 preferred anti-affinity로 분산 유도 정책을 보완했다.
- 현재 배포 전략은 Blue/Green 또는 Canary가 아니라 RollingUpdate다.
- 운영 rollback은 kubectl 수동 조작이 아니라 GitOps values rollback 및 ArgoCD sync를 원칙으로 한다.

이 이슈는 PR merge 및 post-merge ArgoCD/live 확인 전까지 최종 완료로 보지 않는다.
