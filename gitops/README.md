# MoMent GitOps Repository Structure

## 목적

이 디렉토리는 MoMent M3 GitOps + CI/CD 단계에서 ArgoCD가 참조할 Helm 기반 배포 기준 경로를 정의한다.

M3-GITOPS-01 범위에서는 실제 Deployment, Service, Ingress, ConfigMap, Secret, ServiceAccount template을 완성하지 않는다. 실제 Kubernetes 리소스 template 작성은 M3-GITOPS-02에서 진행한다.

## Repository 전략

MoMent는 M3 초기 단계에서 별도 GitOps Repository를 새로 만들지 않고, 현재 infra repository 내부의 `gitops/` 디렉토리를 GitOps source path로 사용한다.

추후 운영 기준에서 권한 분리나 배포 감사가 더 필요해지면 별도 GitOps Repository로 분리할 수 있다.

## Manifest 관리 방식

M3 Manifest 관리 방식은 Helm Chart 단독으로 확정한다.

- Kustomize base / overlay 구조는 이번 M3에서 사용하지 않는다.
- Helm + Kustomize 병행도 이번 M3에서 사용하지 않는다.
- Dev / Prod 환경 차이는 Helm values 파일로만 분리한다.
- image repository / tag는 각 환경별 values 파일의 `.image.repository`, `.image.tag` 필드에서 관리한다.

## 디렉토리 구조

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

## App 기준

| App | Chart Path | Dev Values | Prod Values |
| --- | --- | --- | --- |
| backend-api | `gitops/charts/backend-api` | `gitops/values/dev/backend-api-values.yaml` | `gitops/values/prod/backend-api-values.yaml` |
| ai-service | `gitops/charts/ai-service` | `gitops/values/dev/ai-service-values.yaml` | `gitops/values/prod/ai-service-values.yaml` |
| batch-job | `gitops/charts/batch-job` | `gitops/values/dev/batch-job-values.yaml` | `gitops/values/prod/batch-job-values.yaml` |

## Namespace 기준

| 환경 | Namespace |
| --- | --- |
| Dev | `moment-dev` |
| Prod | `moment-prod` |
| ArgoCD | `argocd` |

## Image Repository / Tag 계약

| App | Env | Values File | Field | Repository | Tag 예시 |
| --- | --- | --- | --- | --- | --- |
| backend-api | dev | `gitops/values/dev/backend-api-values.yaml` | `.image.tag` | `611058323802.dkr.ecr.ap-northeast-3.amazonaws.com/moment-dev-backend-api` | `dev-{short_sha}` |
| backend-api | prod | `gitops/values/prod/backend-api-values.yaml` | `.image.tag` | `611058323802.dkr.ecr.ap-northeast-3.amazonaws.com/moment-prod-backend-api` | `prod-{release_version}` |
| ai-service | dev | `gitops/values/dev/ai-service-values.yaml` | `.image.tag` | `611058323802.dkr.ecr.ap-northeast-3.amazonaws.com/moment-dev-ai-service` | `dev-{short_sha}` |
| ai-service | prod | `gitops/values/prod/ai-service-values.yaml` | `.image.tag` | `611058323802.dkr.ecr.ap-northeast-3.amazonaws.com/moment-prod-ai-service` | `prod-{release_version}` |
| batch-job | dev | `gitops/values/dev/batch-job-values.yaml` | `.image.tag` | `611058323802.dkr.ecr.ap-northeast-3.amazonaws.com/moment-dev-batch-job` | `dev-{short_sha}` |
| batch-job | prod | `gitops/values/prod/batch-job-values.yaml` | `.image.tag` | `611058323802.dkr.ecr.ap-northeast-3.amazonaws.com/moment-prod-batch-job` | `prod-{release_version}` |

`latest` 태그는 배포 기준으로 사용하지 않는다.

## ArgoCD Source Path 계약

| Application | Chart Path | valueFiles |
| --- | --- | --- |
| backend-api-dev | `gitops/charts/backend-api` | `../../values/dev/backend-api-values.yaml` |
| ai-service-dev | `gitops/charts/ai-service` | `../../values/dev/ai-service-values.yaml` |
| batch-job-dev | `gitops/charts/batch-job` | `../../values/dev/batch-job-values.yaml` |
| backend-api-prod | `gitops/charts/backend-api` | `../../values/prod/backend-api-values.yaml` |
| ai-service-prod | `gitops/charts/ai-service` | `../../values/prod/ai-service-values.yaml` |
| batch-job-prod | `gitops/charts/batch-job` | `../../values/prod/batch-job-values.yaml` |

## 후속 이슈 연결

| 이슈 | 역할 |
| --- | --- |
| M3-GITOPS-02 | Helm Chart template 및 Dev/Prod values 실제 구현 |
| M3-CICD-03 | ECR Push 이후 Helm values image tag 자동 업데이트 |
| M3-ARGO-02 | Dev ArgoCD App of Apps 및 Dev Application 구성 |
| M3-ARGO-03 | Prod ArgoCD 설치 및 Prod Application 구성 |
| M3-CONFIG-01 | ConfigMap, Secret, ServiceAccount, IRSA 기준 구성 |
| M3-DEPLOY-01 | Backend API 실제 배포 검증 |
| M3-DEPLOY-02 | AI Service / Batch Job 실제 배포 검증 |
| M3-PROMOTE-01 | Dev to Prod 승격 및 Rollback 전략 구성 |

## 민감정보 관리 기준

GitOps 디렉토리에는 다음 값을 평문으로 커밋하지 않는다.

- AWS Access Key
- AWS Secret Key
- kubeconfig
- DB password
- JWT secret
- OpenAI API key
- TossPayments secret
- Public Data API key
- Terraform tfstate / tfplan
- `*.auto.tfvars`
- private key

Secret 값은 Kubernetes Secret 직접 생성, External Secrets, Secrets Manager 연동 등 M3-CONFIG-01 기준에 따라 처리한다.
