# Dev ArgoCD Path Contract

M3-ARGO-02에서 Dev App of Apps와 Dev Application manifest를 이 경로 아래에 작성한다.

Dev ArgoCD는 Dev Application만 관리한다.

- Root Application path: `gitops/argocd/dev`
- Destination namespace: `moment-dev`
- Backend API chart path: `gitops/charts/backend-api`
- Backend API valueFiles: `../../values/dev/backend-api-values.yaml`
- AI Service chart path: `gitops/charts/ai-service`
- AI Service valueFiles: `../../values/dev/ai-service-values.yaml`
- Batch Job chart path: `gitops/charts/batch-job`
- Batch Job valueFiles: `../../values/dev/batch-job-values.yaml`

Prod Application은 이 경로에 두지 않는다.
