# MoMent GitOps Repository Structure

## 목적

이 디렉토리는 MoMent M3 GitOps + CI/CD 단계에서 ArgoCD가 참조할 Kubernetes 배포 기준 경로를 정의한다.

현재 이 작업은 GitOps Repository 구조와 Dev/Prod Overlay 기준을 잡는 범위이며, 실제 Deployment, Service, Ingress, ConfigMap, Secret, ServiceAccount manifest 작성은 후속 M3-GITOPS-02 및 배포 이슈에서 진행한다.

## 기본 방향

MoMent는 별도 GitOps Repository를 새로 만들지 않고, 현재 infra repository 내부의 gitops/ 디렉토리를 GitOps source path로 사용한다.

이 방식은 M3 초기 단계에서 Terraform, ECR, EKS, ArgoCD, Kubernetes manifest 기준을 한 repository 안에서 함께 확인하기 좋다.

향후 운영 계정 또는 팀 운영 방식이 분리되면 별도 GitOps Repository로 분리할 수 있다.

## 디렉토리 구조

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

## 앱별 역할

| App | 역할 | 기본 배포 환경 |
| --- | --- | --- |
| backend-api | 사용자 요청을 처리하는 Spring Boot API | Dev 우선, Prod 선택 활성화 |
| ai-service | AI 기반 검색/추천 설명/리포트 보조 서비스 | Dev 우선, Prod 선택 활성화 |
| batch-job | 공공데이터 수집 후처리 및 배치성 작업 | Dev 우선, Prod 선택 활성화 |

## 환경 Overlay 기준

| 환경 | Namespace | 이미지 태그 기준 | Sync 전략 |
| --- | --- | --- | --- |
| dev | moment-dev | dev-{short_sha} | 빠른 검증 중심 |
| prod | moment-prod | prod-{version} 또는 release tag | 승인 기반 수동 반영 |

## ECR Repository 기준

Dev ECR:
- moment-dev-backend-api
- moment-dev-ai-service
- moment-dev-batch-job

Prod ECR:
- moment-prod-backend-api
- moment-prod-ai-service
- moment-prod-batch-job

latest 태그는 배포 기준으로 사용하지 않는다.

## 후속 이슈 연결

| 이슈 | 역할 |
| --- | --- |
| M3-GITOPS-02 | 실제 Kubernetes Manifest base/overlay 작성 |
| M3-CICD-03 | ECR Push 이후 GitOps Manifest image tag 자동 업데이트 |
| M3-ARGO-02 | ArgoCD App of Apps 및 Dev/Prod Application 구성 |
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
- *.auto.tfvars
- private key

Secret 값은 Kubernetes Secret 직접 생성, External Secrets, Secrets Manager 연동 등 후속 M3-CONFIG-01 기준에 따라 처리한다.

## Manifest 관리 방식

M3 초기 기준은 Kustomize base/overlay 구조를 우선 사용한다.

- base: 공통 Kubernetes manifest 후보
- overlays/dev: Dev namespace, image tag, replica, config patch 후보
- overlays/prod: Prod namespace, image tag, replica, config patch 후보

Helm chart는 초기 M3 필수 범위가 아니며, 필요 시 후속 이슈에서 확장한다.

## Image Tag 변경 방식

이미지 태그 변경은 M3-CICD-03에서 GitHub Actions가 GitOps overlay 파일을 갱신하는 방식으로 연결한다.

- Dev: dev-{short_sha}
- Prod: prod-{version} 또는 release tag
- latest 태그는 배포 기준으로 사용하지 않음
- Prod 변경은 PR 승인 또는 수동 sync 기준으로 반영

## Repository 접근 권한 기준

- GitOps 변경은 Pull Request 기반으로 반영한다.
- main/develop 직접 push는 금지한다.
- GitHub Actions의 GitOps 변경 권한은 최소 범위로 제한한다.
- Secret, kubeconfig, AWS credential은 GitOps Repository에 저장하지 않는다.
