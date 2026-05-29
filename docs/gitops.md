# GitOps Repository 구조 및 Dev/Prod Overlay 기준

## 1. 목적

M3-GITOPS-01의 목적은 ArgoCD가 참조할 GitOps Repository 구조와 Dev/Prod Overlay 기준을 정의하는 것이다.

이번 작업에서는 실제 애플리케이션 Deployment, Service, Ingress manifest를 작성하지 않는다.

실제 Kubernetes Manifest 작성은 M3-GITOPS-02에서 진행하고, ArgoCD Application 연결은 M3-ARGO-02에서 진행한다.

## 2. Repository 선택 기준

MoMent M3 초기 단계에서는 별도 GitOps Repository를 생성하지 않고 infra repository 내부 gitops/ 디렉토리를 사용한다.

선택 이유는 다음과 같다.

- Terraform으로 구성한 ECR, EKS, IAM/IRSA, VPC Endpoint 기준과 GitOps 경로를 한 repository에서 확인할 수 있다.
- M3 초기 단계에서 GitHub Actions, ArgoCD, manifest path 정합성을 빠르게 맞출 수 있다.
- 별도 repository 권한 구성, token 관리, repository credential 관리 복잡도를 줄일 수 있다.
- 추후 운영 단계에서 GitOps repository를 분리하더라도 현재 구조를 거의 그대로 이전할 수 있다.

## 3. GitOps 디렉토리 구조

기준 구조는 다음과 같다.

gitops/
  apps/
    backend-api/
      base/
      overlays/
        dev/
        prod/
    ai-service/
      base/
      overlays/
        dev/
        prod/
    batch-job/
      base/
      overlays/
        dev/
        prod/
  argocd/
    app-of-apps/
    applications/
      dev/
      prod/

## 4. App 경로 기준

| App | Base Path | Dev Overlay | Prod Overlay |
| --- | --- | --- | --- |
| Backend API | gitops/apps/backend-api/base | gitops/apps/backend-api/overlays/dev | gitops/apps/backend-api/overlays/prod |
| AI Service | gitops/apps/ai-service/base | gitops/apps/ai-service/overlays/dev | gitops/apps/ai-service/overlays/prod |
| Batch Job | gitops/apps/batch-job/base | gitops/apps/batch-job/overlays/dev | gitops/apps/batch-job/overlays/prod |

## 5. ArgoCD 경로 기준

| 구분 | Path | 설명 |
| --- | --- | --- |
| App of Apps | gitops/argocd/app-of-apps | Root Application manifest 후보 |
| Dev Applications | gitops/argocd/applications/dev | Dev Application manifest 후보 |
| Prod Applications | gitops/argocd/applications/prod | Prod Application manifest 후보 |

## 6. Namespace 기준

| 환경 | Namespace |
| --- | --- |
| Dev | moment-dev |
| Prod | moment-prod |
| ArgoCD | argocd |

## 7. Image Tag 기준

MoMent는 latest 태그를 배포 기준으로 사용하지 않는다.

| 환경 | 태그 기준 |
| --- | --- |
| Dev | dev-{short_sha} |
| Prod | prod-{version} 또는 release tag |

## 8. ECR Repository 기준

Dev ECR Repository:

| App | Repository |
| --- | --- |
| Backend API | moment-dev-backend-api |
| AI Service | moment-dev-ai-service |
| Batch Job | moment-dev-batch-job |

Prod ECR Repository:

| App | Repository |
| --- | --- |
| Backend API | moment-prod-backend-api |
| AI Service | moment-prod-ai-service |
| Batch Job | moment-prod-batch-job |

## 9. Dev/Prod Overlay 분리 기준

Dev Overlay는 빠른 검증을 위한 설정을 둔다.

- namespace: moment-dev
- image tag: dev-{short_sha}
- replica: 최소값
- resource request/limit: 개발 검증 기준
- sync: 빠른 검증 중심

Prod Overlay는 최종 시연 또는 운영 리허설용 설정을 둔다.

- namespace: moment-prod
- image tag: prod-{version} 또는 release tag
- replica: 운영 후보 기준
- resource request/limit: 운영 후보 기준
- sync: 승인 기반 반영

## 10. 후속 이슈 역할 분리

| 이슈 | 역할 |
| --- | --- |
| M3-GITOPS-01 | GitOps Repository 구조 및 Dev/Prod Overlay 경로 정의 |
| M3-GITOPS-02 | Kubernetes Manifest Base/Overlay 실제 작성 |
| M3-CICD-03 | ECR Push 이후 GitOps Manifest image tag 자동 업데이트 |
| M3-ARGO-01 | ArgoCD 설치 및 접근 구성 |
| M3-ARGO-02 | App of Apps 및 Dev/Prod Application 구성 |
| M3-CONFIG-01 | ConfigMap, Secret, ServiceAccount, IRSA 기준 구성 |
| M3-DEPLOY-01 | Backend API Runtime 배포 검증 |
| M3-DEPLOY-02 | AI Service / Batch Job Runtime 배포 검증 |
| M3-PROMOTE-01 | Dev to Prod 승격 및 Rollback 전략 구성 |

## 11. 보안 기준

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
- *.auto.tfvars
- private key

Secret 관리 방식은 M3-CONFIG-01에서 확정한다.

## 12. Manifest 관리 방식

M3 초기 GitOps Manifest 관리는 Kustomize base/overlay 구조를 기본 기준으로 한다.

선택 기준은 다음과 같다.

- GitOps 디렉토리 구조가 apps/{service}/base와 overlays/dev, overlays/prod 형태로 이미 분리되어 있다.
- Dev/Prod 차이는 namespace, image tag, replica, resource, config patch 중심으로 관리할 수 있다.
- Helm chart 작성은 초기 M3 범위에서는 필수로 두지 않는다.
- Helm이 필요한 경우에는 후속 이슈에서 chart 또는 Helm values 구조로 확장할 수 있다.

따라서 M3-GITOPS-02에서는 Kustomize 기준으로 Kubernetes Manifest base/overlay를 우선 작성한다.

## 13. Image Tag 변경 방식

Image tag 변경은 M3-CICD-03에서 GitHub Actions가 GitOps overlay 파일을 갱신하는 방식으로 연결한다.

기본 기준은 다음과 같다.

- Dev: ECR Push 이후 dev overlay의 image tag를 dev-{short_sha}로 갱신
- Prod: release tag 또는 prod-{version} 기준으로 prod overlay image tag를 PR 기반으로 갱신
- latest 태그는 배포 기준으로 사용하지 않음
- ArgoCD Image Updater는 이번 M3 초기 범위에서는 필수로 도입하지 않고 후속 검토 대상으로 둠

Prod overlay 변경은 자동 직반영이 아니라 PR 승인 또는 수동 sync 전략과 연결한다.

## 14. Repository 접근 권한 기준

현재 GitOps source는 infra repository 내부 gitops/ 디렉토리를 사용한다.

접근 권한 기준은 다음과 같다.

- GitOps 경로 변경은 Pull Request 기반으로 반영한다.
- main/develop 직접 push는 금지한다.
- GitHub Actions가 GitOps manifest를 수정하는 경우 최소 권한 token 또는 repository write 권한 범위를 별도로 제한한다.
- 운영 Secret, kubeconfig, AWS credential은 repository에 저장하지 않는다.
- Prod overlay 변경은 리뷰 승인 후 반영한다.
