# Prod ArgoCD Path Contract

M3-ARGO-03에서 Prod ArgoCD와 Prod Application manifest를 이 경로 아래에 작성한다.

Prod ArgoCD는 Prod Application만 관리한다.

- Root Application path: `gitops/argocd/prod`
- Destination namespace: `moment-prod`
- Backend API chart path: `gitops/charts/backend-api`
- Backend API valueFiles: `../../values/prod/backend-api-values.yaml`
- AI Service chart path: `gitops/charts/ai-service`
- AI Service valueFiles: `../../values/prod/ai-service-values.yaml`
- Batch Job chart path: `gitops/charts/batch-job`
- Batch Job valueFiles: `../../values/prod/batch-job-values.yaml`

Dev Application은 이 경로에 두지 않는다.
