# M3-CONFIG-01 Runtime Config / Secret / ServiceAccount 정리

## 1. 대상 Workload

| Workload | Chart Path | Dev Values | Prod Values |
|---|---|---|---|
| Backend API | `gitops/charts/backend-api` | `gitops/values/dev/backend-api-values.yaml` | `gitops/values/prod/backend-api-values.yaml` |
| AI Service | `gitops/charts/ai-service` | `gitops/values/dev/ai-service-values.yaml` | `gitops/values/prod/ai-service-values.yaml` |
| Batch Job | `gitops/charts/batch-job` | `gitops/values/dev/batch-job-values.yaml` | `gitops/values/prod/batch-job-values.yaml` |

---

## 2. Namespace

| Environment | Namespace |
|---|---|
| Dev | `moment-dev` |
| Prod | `moment-prod` |

Dev namespace는 EKS 클러스터에 생성 완료했다.

```bash
kubectl get ns moment-dev
```

Prod namespace는 비용 절감을 위해 prod 인프라를 상시 운영하지 않으므로, prod 활성화 시점에 생성 및 검증한다.

---

## 3. ConfigMap 관리 항목

Secret 값은 ConfigMap에 넣지 않는다.
ConfigMap에는 환경별로 달라지는 non-secret runtime 설정만 둔다.

### Backend API

| Key | Dev 값 | Secret 여부 |
|---|---|---|
| `SPRING_PROFILES_ACTIVE` | `dev` | No |
| `AWS_REGION` | `ap-northeast-3` | No |
| `ENVIRONMENT` | `dev` | No |
| `DB_HOST` | Dev RDS endpoint | No |
| `DB_PORT` | `5432` | No |
| `DB_NAME` | `moment` | No |
| `REDIS_HOST` | Dev Redis endpoint | No |
| `REDIS_PORT` | `6379` | No |
| `OPENSEARCH_HOST` | Dev OpenSearch endpoint | No |
| `S3_PROFILE_IMAGE_BUCKET` | Dev profile image bucket | No |
| `SQS_QUEUE_NAME` | Dev public data queue | No |
| `AI_SERVICE_URL` | `http://ai-service:8000` | No |

### AI Service

| Key | Dev 값 | Secret 여부 |
|---|---|---|
| `ENVIRONMENT` | `dev` | No |
| `AWS_REGION` | `ap-northeast-3` | No |
| `LOG_LEVEL` | `DEBUG` | No |
| `OPENSEARCH_HOST` | Dev OpenSearch endpoint | No |
| `BACKEND_API_URL` | `http://backend-api:8080` | No |

### Batch Job

| Key | Dev 값 | Secret 여부 |
|---|---|---|
| `SPRING_PROFILES_ACTIVE` | `dev` | No |
| `AWS_REGION` | `ap-northeast-3` | No |
| `SQS_QUEUE_NAME` | Dev public data queue | No |
| `SQS_QUEUE_URL` | Dev public data queue URL | No |
| `S3_RAW_BUCKET` | Dev raw data bucket | No |
| `DB_HOST` | Dev RDS endpoint | No |
| `DB_PORT` | `5432` | No |
| `DB_NAME` | `moment` | No |
| `OPENSEARCH_HOST` | Dev OpenSearch endpoint | No |

---

## 4. Secret 관리 항목

Secret 값은 GitOps Repository에 평문으로 저장하지 않는다.
Manifest에는 Secret name과 Secret key name만 참조한다.

### Backend API

| Env Name | Secret Name | Secret Key |
|---|---|---|
| `DB_USERNAME` | `moment-dev-backend-api-secret` | `db-username` |
| `DB_PASSWORD` | `moment-dev-backend-api-secret` | `db-password` |
| `JWT_SECRET` | `moment-dev-backend-api-secret` | `jwt-secret` |
| `TOSS_SECRET` | `moment-dev-backend-api-secret` | `toss-secret` |

### AI Service

| Env Name | Secret Name | Secret Key |
|---|---|---|
| `OPENAI_API_KEY` | `moment-dev-ai-service-secret` | `openai-api-key` |

### Batch Job

| Env Name | Secret Name | Secret Key |
|---|---|---|
| `DB_USERNAME` | `moment-dev-batch-job-secret` | `db-username` |
| `DB_PASSWORD` | `moment-dev-batch-job-secret` | `db-password` |
| `PUBLIC_DATA_API_KEY` | `moment-dev-batch-job-secret` | `public-data-api-key` |

---

## 5. Prod Secret 기준

Prod는 비용 절감을 위해 상시 운영하지 않고, 발표 또는 최종 검증 기간에만 활성화할 예정이다.
따라서 prod values에는 Secret 구조만 미리 정의하고 실제 Secret 값은 prod 인프라 활성화 시점에 등록한다.

| Workload | Prod Secret Name | 주요 Key |
|---|---|---|
| Backend API | `moment-prod-backend-api-secret` | `db-username`, `db-password`, `jwt-secret`, `toss-secret` |
| AI Service | `moment-prod-ai-service-secret` | `openai-api-key` |
| Batch Job | `moment-prod-batch-job-secret` | `db-username`, `db-password`, `public-data-api-key` |

Prod Secret 값은 Git에 커밋하지 않는다.

---

## 6. ServiceAccount

| Workload | Dev ServiceAccount | Prod ServiceAccount |
|---|---|---|
| Backend API | `moment-dev-backend-api-sa` | `moment-prod-backend-api-sa` |
| AI Service | `moment-dev-ai-service-sa` | `moment-prod-ai-service-sa` |
| Batch Job | `moment-dev-batch-job-sa` | `moment-prod-batch-job-sa` |

각 Deployment / CronJob은 default ServiceAccount를 사용하지 않고, workload별 ServiceAccount를 명시적으로 참조한다.

---

## 7. IRSA 상태

현재 IAM Role 목록에서 확인된 IRSA Role은 다음과 같다.

- `moment-dev-alb-controller-irsa-role`
- `moment-dev-ebs-csi-irsa-role`

아래 workload 전용 IRSA Role은 아직 확인되지 않았다.

- `moment-dev-backend-api-irsa-role`
- `moment-dev-ai-service-irsa-role`
- `moment-dev-batch-job-irsa-role`

따라서 현재 workload ServiceAccount annotation은 비워두었다.

```yaml
annotations: {}
```

후속 Terraform 작업에서 workload별 IRSA Role을 생성한 뒤, 각 values 파일의 ServiceAccount annotation에 Role ARN을 반영해야 한다.

예상 형식은 다음과 같다.

```yaml
serviceAccount:
  create: true
  name: moment-dev-backend-api-sa
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::611058323802:role/moment-dev-backend-api-irsa-role
```

---

## 8. Dev Secret 생성 현황

Dev EKS cluster의 `moment-dev` namespace에 아래 Secret을 생성했다.

| Secret Name | Data 개수 |
|---|---:|
| `moment-dev-backend-api-secret` | 4 |
| `moment-dev-ai-service-secret` | 1 |
| `moment-dev-batch-job-secret` | 3 |

확인 명령어:

```bash
kubectl get secret -n moment-dev
```

Secret 값은 PR, Git diff, 로그, 캡처에 노출하지 않는다.

---

## 9. Node Scheduling 기준

현재 Dev EKS node는 아래 label을 가진다.

| Key | Value |
|---|---|
| `workload` | `core` |
| `capacity` | `on-demand` |

따라서 Dev 환경에서는 Backend API, AI Service, Batch Job 모두 아래 nodeSelector를 사용한다.

```yaml
nodeSelector:
  workload: core
  capacity: on-demand
```

Prod 환경에서는 AI Service와 Batch Job을 별도 spot node로 분리하는 구조를 values에 유지한다.
다만 prod node group은 비용 절감을 위해 prod 인프라 활성화 시점에 검증한다.

---

## 10. Prod 운영 기준

Prod 환경은 비용 절감을 위해 상시 운영하지 않는다.
발표 또는 최종 검증 기간에 약 3일 정도만 활성화하는 운영 방식을 기준으로 한다.

따라서 현재 prod values는 아래 항목을 placeholder로 유지한다.

- RDS endpoint
- Redis endpoint
- OpenSearch endpoint
- ACM certificate ARN
- workload별 IRSA Role ARN
- prod Secret 실제 값

Prod 활성화 시점에 다음을 반영해야 한다.

1. Prod RDS endpoint
2. Prod Redis endpoint
3. Prod OpenSearch endpoint
4. Prod ACM certificate ARN
5. Prod backend / AI / batch Secret 생성
6. Prod backend / AI / batch IRSA Role ARN 연결
7. Prod namespace 생성
8. Prod Helm render 및 server dry-run
9. ArgoCD Sync 및 Pod Running 검증

---

## 11. 검증 명령어

### Dev Helm Render

```bash
helm template backend-api gitops/charts/backend-api -f gitops/values/dev/backend-api-values.yaml
helm template ai-service gitops/charts/ai-service -f gitops/values/dev/ai-service-values.yaml
helm template batch-job gitops/charts/batch-job -f gitops/values/dev/batch-job-values.yaml
```

### Dev Kubernetes Server Dry-run

```bash
helm template backend-api gitops/charts/backend-api -f gitops/values/dev/backend-api-values.yaml | kubectl apply --dry-run=server -f -
helm template ai-service gitops/charts/ai-service -f gitops/values/dev/ai-service-values.yaml | kubectl apply --dry-run=server -f -
helm template batch-job gitops/charts/batch-job -f gitops/values/dev/batch-job-values.yaml | kubectl apply --dry-run=server -f -
```

검증 결과:

```text
serviceaccount/moment-dev-backend-api-sa created (server dry run)
configmap/backend-api-config created (server dry run)
service/backend-api created (server dry run)
deployment.apps/backend-api created (server dry run)
ingress.networking.k8s.io/backend-api created (server dry run)

serviceaccount/moment-dev-ai-service-sa created (server dry run)
configmap/ai-service-config created (server dry run)
service/ai-service created (server dry run)
deployment.apps/ai-service created (server dry run)

serviceaccount/moment-dev-batch-job-sa created (server dry run)
configmap/batch-job-config created (server dry run)
cronjob.batch/batch-job created (server dry run)
```

### Prod Helm Render

```bash
helm template backend-api gitops/charts/backend-api -f gitops/values/prod/backend-api-values.yaml
helm template ai-service gitops/charts/ai-service -f gitops/values/prod/ai-service-values.yaml
helm template batch-job gitops/charts/batch-job -f gitops/values/prod/batch-job-values.yaml
```

Prod는 인프라 비활성 상태이므로, 현재 단계에서는 Helm render 기준으로 구조만 검증한다.

---

## 12. 장애 대응 기준

### ConfigMap 누락

- Pod describe에서 `configmap not found` 이벤트 확인
- values 파일의 `config` 항목 확인
- Helm render 결과의 ConfigMap name과 Deployment/CronJob의 configMapRef name 일치 여부 확인

### Secret 누락

- Pod describe에서 `secret not found` 이벤트 확인
- Secret name / key name 확인
- Secret 값은 출력하지 않고 `kubectl get secret`으로 존재 여부와 DATA 개수만 확인

### ServiceAccount 누락

- Pod describe에서 `serviceaccount not found` 이벤트 확인
- values 파일의 `serviceAccount.name` 확인
- Helm render 결과의 ServiceAccount name과 workload의 `serviceAccountName` 일치 여부 확인

### IRSA 권한 문제

- ServiceAccount annotation의 `eks.amazonaws.com/role-arn` 확인
- IAM Role trust policy의 namespace/serviceAccount subject 확인
- AWS API 호출 실패 시 `AccessDenied` 로그 확인

### Node Scheduling 문제

- Pod가 Pending이면 `kubectl describe pod`로 scheduling event 확인
- nodeSelector와 실제 node label이 일치하는지 확인
- Dev 기준 현재 node label은 `workload=core`, `capacity=on-demand`

---

## 13. M3-DEPLOY 인수인계

M3-DEPLOY-01에서는 Backend API가 아래 조건을 만족하는지 확인한다.

- Pod Running
- ConfigMap env 로드
- Secret env 로드
- ServiceAccount 적용
- Health check 통과
- Service/Ingress 생성

M3-DEPLOY-02에서는 AI Service와 Batch Job이 아래 조건을 만족하는지 확인한다.

- AI Service Pod Running
- Batch CronJob 생성
- ConfigMap env 로드
- Secret env 로드
- ServiceAccount 적용
- 필요한 AWS 접근 권한은 IRSA 생성 후 검증
