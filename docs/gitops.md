# GitOps Repository 구조 및 Helm Values 기준

## 1. 목적

M3-GITOPS-01의 목적은 ArgoCD가 참조할 GitOps Repository 구조와 Helm Chart / Dev / Prod values 기준을 확정하는 것이다.

이번 작업에서는 실제 애플리케이션 Deployment, Service, Ingress manifest template을 완성하지 않는다.

실제 Kubernetes 리소스 template 작성은 M3-GITOPS-02에서 진행하고, ArgoCD Application 연결은 M3-ARGO-02와 M3-ARGO-03에서 진행한다.

## 2. Repository 선택 기준

MoMent M3 초기 단계에서는 별도 GitOps Repository를 생성하지 않고 infra repository 내부 `gitops/` 디렉토리를 사용한다.

선택 이유는 다음과 같다.

- Terraform으로 구성한 ECR, EKS, IAM/IRSA, VPC Endpoint 기준과 GitOps 경로를 한 repository에서 확인할 수 있다.
- M3 초기 단계에서 GitHub Actions, ArgoCD, Helm values path 정합성을 빠르게 맞출 수 있다.
- 별도 repository 권한 구성, token 관리, repository credential 관리 복잡도를 줄일 수 있다.
- 추후 운영 단계에서 GitOps repository를 분리하더라도 현재 구조를 거의 그대로 이전할 수 있다.

## 3. Manifest 관리 방식

M3 Manifest 관리 방식은 Helm Chart 단독으로 확정한다.

- Kustomize base / overlay 구조는 이번 M3에서 사용하지 않는다.
- Helm + Kustomize 병행은 이번 M3에서 사용하지 않는다.
- Dev / Prod 환경 차이는 Helm values 파일로 분리한다.
- Chart에는 공통 template을 두고, 환경별 값은 values 파일에서만 관리한다.
- image repository / tag는 `.image.repository`, `.image.tag` 필드로 고정한다.

## 4. GitOps 디렉토리 구조

    gitops/
      charts/
        backend-api/
          Chart.yaml
          values.yaml
          templates/
        ai-service/
          Chart.yaml
          values.yaml
          templates/
        batch-job/
          Chart.yaml
          values.yaml
          templates/
      values/
        dev/
          backend-api-values.yaml
          ai-service-values.yaml
          batch-job-values.yaml
        prod/
          backend-api-values.yaml
          ai-service-values.yaml
          batch-job-values.yaml
      argocd/
        dev/
        prod/

## 5. App 경로 기준

| App | Chart Path | Dev Values | Prod Values |
| --- | --- | --- | --- |
| Backend API | `gitops/charts/backend-api` | `gitops/values/dev/backend-api-values.yaml` | `gitops/values/prod/backend-api-values.yaml` |
| AI Service | `gitops/charts/ai-service` | `gitops/values/dev/ai-service-values.yaml` | `gitops/values/prod/ai-service-values.yaml` |
| Batch Job | `gitops/charts/batch-job` | `gitops/values/dev/batch-job-values.yaml` | `gitops/values/prod/batch-job-values.yaml` |

## 6. ArgoCD 경로 기준

| 구분 | Path | 설명 |
| --- | --- | --- |
| Dev ArgoCD Contract | `gitops/argocd/dev` | M3-ARGO-02에서 Dev App of Apps 및 Dev Application 작성 |
| Prod ArgoCD Contract | `gitops/argocd/prod` | M3-ARGO-03에서 Prod Application 작성 |

## 7. Namespace 기준

| 환경 | Namespace |
| --- | --- |
| Dev | `moment-dev` |
| Prod | `moment-prod` |
| ArgoCD | `argocd` |

## 8. Image Tag 기준

MoMent는 `latest` 태그를 배포 기준으로 사용하지 않는다.

| 환경 | 태그 기준 |
| --- | --- |
| Dev | `dev-{short_sha}` |
| Prod | `prod-{release_version}` 또는 `prod-{git_tag}` |

## 9. ECR Repository 기준

Dev ECR Repository:

| App | Repository |
| --- | --- |
| Backend API | `611058323802.dkr.ecr.ap-northeast-3.amazonaws.com/moment-dev-backend-api` |
| AI Service | `611058323802.dkr.ecr.ap-northeast-3.amazonaws.com/moment-dev-ai-service` |
| Batch Job | `611058323802.dkr.ecr.ap-northeast-3.amazonaws.com/moment-dev-batch-job` |

Prod ECR Repository:

| App | Repository |
| --- | --- |
| Backend API | `611058323802.dkr.ecr.ap-northeast-3.amazonaws.com/moment-prod-backend-api` |
| AI Service | `611058323802.dkr.ecr.ap-northeast-3.amazonaws.com/moment-prod-ai-service` |
| Batch Job | `611058323802.dkr.ecr.ap-northeast-3.amazonaws.com/moment-prod-batch-job` |

## 10. M3-CICD-03 Image Tag Update 계약

| App | Env | File | Field |
| --- | --- | --- | --- |
| Backend API | dev | `gitops/values/dev/backend-api-values.yaml` | `.image.tag` |
| Backend API | prod | `gitops/values/prod/backend-api-values.yaml` | `.image.tag` |
| AI Service | dev | `gitops/values/dev/ai-service-values.yaml` | `.image.tag` |
| AI Service | prod | `gitops/values/prod/ai-service-values.yaml` | `.image.tag` |
| Batch Job | dev | `gitops/values/dev/batch-job-values.yaml` | `.image.tag` |
| Batch Job | prod | `gitops/values/prod/batch-job-values.yaml` | `.image.tag` |

M3-CICD-03은 Chart template이 아니라 환경별 values 파일만 수정한다.

## 11. ArgoCD Application Source 계약

| Application | Chart Path | valueFiles | Destination Namespace |
| --- | --- | --- | --- |
| `backend-api-dev` | `gitops/charts/backend-api` | `../../values/dev/backend-api-values.yaml` | `moment-dev` |
| `ai-service-dev` | `gitops/charts/ai-service` | `../../values/dev/ai-service-values.yaml` | `moment-dev` |
| `batch-job-dev` | `gitops/charts/batch-job` | `../../values/dev/batch-job-values.yaml` | `moment-dev` |
| `backend-api-prod` | `gitops/charts/backend-api` | `../../values/prod/backend-api-values.yaml` | `moment-prod` |
| `ai-service-prod` | `gitops/charts/ai-service` | `../../values/prod/ai-service-values.yaml` | `moment-prod` |
| `batch-job-prod` | `gitops/charts/batch-job` | `../../values/prod/batch-job-values.yaml` | `moment-prod` |

## 12. Dev / Prod values 분리 기준

Dev values는 빠른 검증을 위한 설정을 둔다.

- namespace: `moment-dev`
- image tag: `dev-{short_sha}`
- replica: 최소값
- resource request / limit: 개발 검증 기준
- sync: 빠른 검증 중심

Prod values는 최종 시연 또는 운영 리허설용 설정을 둔다.

- namespace: `moment-prod`
- image tag: `prod-{release_version}` 또는 `prod-{git_tag}`
- replica: 운영 후보 기준
- resource request / limit: 운영 후보 기준
- sync: 승인 기반 반영

## 13. 후속 이슈 역할 분리

| 이슈 | 역할 |
| --- | --- |
| M3-GITOPS-01 | GitOps Repository 구조 및 Helm Values 기준 확정 |
| M3-GITOPS-02 | Helm Chart 및 Dev/Prod Values 실제 구현 |
| M3-CICD-03 | ECR Push 이후 Helm Values image tag 자동 업데이트 |
| M3-ARGO-01 | Dev ArgoCD 설치 및 접근 구성 |
| M3-ARGO-02 | Dev ArgoCD App of Apps 및 Dev Application 구성 |
| M3-ARGO-03 | Prod ArgoCD 설치 및 Prod Application 구성 |
| M3-CONFIG-01 | ConfigMap, Secret, ServiceAccount, IRSA 기준 구성 |
| M3-DEPLOY-01 | Backend API Runtime 배포 검증 |
| M3-DEPLOY-02 | AI Service / Batch Job Runtime 배포 검증 |
| M3-PROMOTE-01 | Dev to Prod 승격 및 Rollback 전략 구성 |

## 14. 보안 기준

GitOps Repository에는 민감정보를 평문으로 저장하지 않는다.

금지 항목:

- AWS credentials
- kubeconfig
- DB password
- JWT secret
- OpenAI API key
- TossPayments secret
- Public Data API key
- Terraform tfstate
- Terraform tfplan
- `*.auto.tfvars`
- private key

Secret 관리 방식은 M3-CONFIG-01에서 확정한다.

## 15. Workflow 무한 루프 방지 기준

GitHub Actions가 Helm values image tag를 수정하는 경우, 다음 중 하나 이상의 기준을 적용한다.

- `gitops/**` path ignore
- `[skip ci]` commit message
- GitOps update 전용 branch
- PR 기반 GitOps values 변경
- workflow trigger 제한

Dev values 변경과 Prod values 변경은 서로 다른 승인 흐름을 사용한다.
