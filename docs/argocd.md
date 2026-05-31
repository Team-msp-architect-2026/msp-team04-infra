# Dev ArgoCD 설치 및 접근 구성

## 1. 목적

M3-ARGO-01의 목적은 Dev EKS Cluster에 Dev 전용 ArgoCD를 설치하고, 기본 접근 경로와 GitOps Repository 연결을 검증하는 것이다.

이번 작업에서는 ArgoCD Application, AppProject, App of Apps manifest를 생성하지 않는다.

실제 Dev Application 구성은 M3-ARGO-02에서 진행하고, Prod ArgoCD 설치 및 Prod Application 구성은 M3-ARGO-03에서 별도 진행한다.

## 2. 설치 대상

| 항목 | 값 |
| --- | --- |
| 대상 Cluster | moment-dev-eks-cluster |
| Namespace | argocd |
| 설치 방식 | Helm |
| Helm Release | argocd |
| Helm Chart | argo/argo-cd |
| Chart Version | 9.5.17 |
| ArgoCD App Version | v3.4.3 |
| Server Service Type | ClusterIP |
| 외부 공개 여부 | 외부 LoadBalancer / Ingress 미사용 |
| 기본 접근 방식 | kubectl port-forward |

## 3. Dev 전용 관리 기준

Dev ArgoCD는 Dev 환경만 관리한다.

| 구분 | 기준 |
| --- | --- |
| Dev Application 관리 | 허용 |
| moment-dev namespace 관리 | 허용 |
| Prod Application 관리 | 제외 |
| moment-prod namespace 관리 | 제외 |
| Prod EKS Cluster 관리 | 제외 |

Prod 환경은 M3-ARGO-03에서 별도 Prod ArgoCD를 설치하여 관리한다.

## 4. 접근 방식

ArgoCD UI는 외부 인터넷에 직접 공개하지 않는다.

기본 접근은 다음 방식으로 제한한다.

| 방식 | 설명 |
| --- | --- |
| port-forward | 로컬 검증용 기본 접근 방식 |
| OpenVPN / internal access | 운영 접근 후보 |
| Public LoadBalancer | 이번 범위 제외 |
| Public Ingress | 이번 범위 제외 |

로컬 접근 예시는 다음과 같다.

kubectl port-forward svc/argocd-server -n argocd 8080:443

접속 URL:

https://localhost:8080

## 5. Admin 계정 처리

초기 admin 계정은 설치 직후 검증에 사용한다.

검증 후에는 초기 admin password를 재설정하고, initial admin secret은 삭제한다.

이번 검증에서 수행한 보안 정리는 다음과 같다.

| 항목 | 결과 |
| --- | --- |
| 초기 admin password 확인 | 로컬에서만 확인 |
| admin password 재설정 | 완료 |
| argocd-server 재시작 | 완료 |
| argocd-initial-admin-secret 삭제 | 완료 |
| password / token Git 저장 | 없음 |

admin password, token, kubeconfig, repo credential은 Git에 평문으로 저장하지 않는다.

## 6. GitOps Repository 연결

M3 초기 단계에서는 별도 GitOps Repository를 생성하지 않고 infra repository 내부 gitops/ 디렉토리를 사용한다.

ArgoCD repo connection 검증 결과는 다음과 같다.

| 항목 | 값 |
| --- | --- |
| Repository Name | moment-infra-gitops |
| Repository URL | https://github.com/Team-msp-architect-2026/msp-team04-infra.git |
| Repository Type | git |
| Project | default |
| Connection Status | Successful |
| Credentials 저장 여부 | false |

## 7. 검증 결과

설치 후 다음 항목을 확인했다.

| 검증 항목 | 결과 |
| --- | --- |
| argocd namespace 생성 | 정상 |
| namespace label | app.kubernetes.io/part-of=moment, component=argocd, environment=dev |
| Helm release 상태 | deployed |
| argocd-server pod | Running |
| argocd-repo-server pod | Running |
| argocd-application-controller pod | Running |
| argocd-redis pod | Running |
| argocd-dex-server pod | Running |
| argocd-notifications-controller pod | Running |
| argocd-server service type | ClusterIP |
| ArgoCD CLI login | 성공 |
| Repository connection | Successful |
| Application list | 비어 있음 |
| Public exposure | 없음 |

Application list가 비어 있는 것은 정상이다.

이번 이슈는 설치 및 접근 구성이 범위이고, 실제 Application 생성은 M3-ARGO-02에서 수행한다.

## 8. 운영 명령어

ArgoCD 상태 확인:

helm list -n argocd
kubectl get pods -n argocd
kubectl get svc -n argocd
argocd account get-user-info
argocd repo list
argocd app list

port-forward 시작:

kubectl port-forward svc/argocd-server -n argocd 8080:443

initial admin secret 확인:

kubectl get secret argocd-initial-admin-secret -n argocd

## 9. 후속 이슈 인수인계

| 이슈 | 인수인계 내용 |
| --- | --- |
| M3-ARGO-02 | Dev App of Apps, Dev AppProject, Dev Applications 생성 |
| M3-GITOPS-02 | Helm Chart template 및 Dev/Prod values 실제 구현 |
| M3-CICD-03 | ECR Push 이후 Helm values image tag 자동 업데이트 |
| M3-CONFIG-01 | Secret, ConfigMap, ServiceAccount, IRSA 기준 정리 |
| M3-ARGO-03 | Prod EKS에 별도 Prod ArgoCD 설치 |
| M3-VALID-B | GitOps / ArgoCD / Runtime 검증 Runbook 작성 |

## 10. 범위 제외

이번 이슈에서는 다음을 수행하지 않는다.

- Dev Application 생성
- App of Apps 구성
- AppProject 구성
- Prod Application 생성
- Prod EKS 연결
- Public Ingress 공개
- Public LoadBalancer 공개
- GitOps Secret 평문 저장
- Kubernetes application runtime 배포

## 11. Dev App of Apps 구성 기준

M3-ARGO-02에서는 Dev ArgoCD에 App of Apps 구조를 구성한다.

구성 대상은 다음과 같다.

| 항목 | 값 |
| --- | --- |
| Root Application | moment-dev-root |
| AppProject | moment-dev |
| Dev Namespace | moment-dev |
| Backend Application | backend-api-dev |
| AI Service Application | ai-service-dev |
| Batch Job Application | batch-job-dev |

Root Application은 다음 경로를 바라본다.

| 항목 | 값 |
| --- | --- |
| Repository | https://github.com/Team-msp-architect-2026/msp-team04-infra.git |
| Target Revision | develop |
| Path | gitops/argocd/dev |
| Destination Namespace | argocd |

Dev Application은 Helm Chart와 Dev values 파일을 기준으로 구성한다.

| Application | Chart Path | valueFiles | Destination Namespace |
| --- | --- | --- | --- |
| backend-api-dev | gitops/charts/backend-api | ../../values/dev/backend-api-values.yaml | moment-dev |
| ai-service-dev | gitops/charts/ai-service | ../../values/dev/ai-service-values.yaml | moment-dev |
| batch-job-dev | gitops/charts/batch-job | ../../values/dev/batch-job-values.yaml | moment-dev |

Dev ArgoCD는 Dev Application만 관리한다.

Prod EKS, moment-prod namespace, Prod ArgoCD, Prod Application은 M3-ARGO-03에서 별도로 구성한다.

## 12. M3-ARGO-02 검증 기준

M3-ARGO-02의 검증 기준은 다음과 같다.

- AppProject moment-dev 생성 가능
- Namespace moment-dev 생성 가능
- Root Application moment-dev-root 생성 가능
- Backend API / AI Service / Batch Job Dev Application manifest 작성
- Dev Application source repo / chart path / valueFiles 계약 확인
- Dev ArgoCD가 Prod Application을 만들지 않는지 확인
- GitOps manifest에 민감정보가 없는지 확인

현재 Helm Chart template은 M3-GITOPS-02에서 실제 Deployment, Service, Ingress, Job, ServiceAccount template을 채우기 전까지 비어 있을 수 있다.

따라서 M3-ARGO-02에서는 Runtime Pod Running, ALB Ingress 생성, ImagePull 검증을 완료 조건으로 보지 않는다.

해당 Runtime 검증은 M3-DEPLOY-01과 M3-DEPLOY-02에서 수행한다.

## 13. Pre-merge Root Application 상태 주의

Root Application의 targetRevision은 develop으로 고정한다.

PR 머지 전에는 gitops/argocd/dev 경로에 Root/Application manifest가 아직 develop 브랜치에 없을 수 있으므로, Root Application이 실제 child Application을 생성하지 못할 수 있다.

이 상태는 로컬 feature 브랜치의 child Application manifest가 아직 원격 develop에 반영되지 않았기 때문에 발생한다.

PR이 develop에 머지된 뒤에는 Root Application이 develop 브랜치의 Dev AppProject, moment-dev Namespace, child Application manifest를 읽고 Dev Application을 생성할 수 있다.

검증 목적으로 live cluster에서 targetRevision을 feature branch로 임시 변경할 수는 있으나, Git에 커밋되는 manifest의 targetRevision은 develop으로 유지한다.
