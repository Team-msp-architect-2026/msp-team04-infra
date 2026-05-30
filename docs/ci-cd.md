# CI/CD 구조 문서
 
## 개요
 
M3-CICD-01에서 구성한 GitHub Actions 기반 CI 품질 게이트 문서입니다.
PR 생성 시 자동으로 빌드/테스트/타입체크를 실행하고, 실패 시 merge를 차단합니다.
 
---
 
## 레포 구조
 
| 레포 | 서비스 | 언어/프레임워크 |
|------|--------|----------------|
| msp-team04-backend | Backend API + Batch Job | Java 17 / Spring Boot |
| msp-team04-ai | AI Service | Python 3.13 / FastAPI |
| moment-app-base | Frontend | TypeScript / Expo React Native |
| msp-team04-infra | 인프라/GitOps | - |
 
---
 
## CI 품질 게이트 구조
 
### Backend (msp-team04-backend)
 
- **workflow 파일**: `.github/workflows/backend-ci.yml`
- **trigger**: `pull_request` → develop, main / `push` → develop / `workflow_dispatch`
- **job name**: `Backend API - Build & Test`
- **CI 검증 명령어**:
  ```bash
  ./gradlew clean test
  ./gradlew bootJar
  ```
- **Spring profile**: `ci` (`application-ci.properties` 사용)
- **제외 테스트**: `MomentBackendApplicationTests`, `publicdata/**`, `RecommendationIntegrationTest`, `TestMomentBackendApplication`
- **빌드 산출물**: `build/libs/*.jar`
### AI Service (msp-team04-ai)
 
- **workflow 파일**: `.github/workflows/ai-ci.yml`
- **trigger**: `pull_request` → develop, main / `push` → develop
- **job name**: `AI Service - Install & Import Check`
- **CI 검증 명령어**:
  ```bash
  pip install -r requirements.txt
  python -c "from main import app"
  curl http://localhost:8000/health
  ```
- **환경변수**: `OPENAI_API_KEY=ci-dummy-key` (실제 API 호출 없음)
### Frontend (moment-app-base)
 
- **workflow 파일**: `.github/workflows/frontend-ci.yml`
- **trigger**: `pull_request` → develop, main / `push` → develop
- **job name**: `Frontend - Install & Typecheck & Lint`
- **CI 검증 명령어**:
  ```bash
  npm ci
  npx tsc --noEmit
  npx eslint .
  ```
- **환경변수**: `EXPO_PUBLIC_API_BASE_URL=http://localhost:8080`
---
 
## Branch Protection 설정
 
develop 브랜치에 required status check 등록 완료.
CI 통과 안 하면 merge 불가.
 
| 레포 | Required Status Check |
|------|-----------------------|
| msp-team04-backend | `Backend API - Build & Test` |
| msp-team04-ai | `AI Service - Install & Import Check` |
| moment-app-base | `Frontend - Install & Typecheck & Lint` |
 
---
 
## M3-CICD-02 연결 기준 (Docker Build & ECR Push)
 
| 서비스 | 빌드 산출물 | 비고 |
|--------|------------|------|
| backend-api | `build/libs/*.jar` | `./gradlew bootJar` |
| ai-service | - | `uvicorn main:app` entrypoint |
| batch-job | `build/libs/*.jar` | Backend와 동일 jar 사용 |
 
- **ECR Push workflow**: `.github/workflows/backend-build-push.yml`
- **trigger**: `push` → develop only (PR 시 미실행)
---
 
## M3-CICD-03 연결 기준 (Image Tag)
 
| 구분 | tag 기준 | 예시 |
|------|---------|------|
| dev | short sha | `abc1234` |
| dev latest | latest | `latest` |
| prod | 추후 결정 | `v1.0.0` 또는 `release-sha` |
 
- short sha 추출: `github.sha` 사용 (backend-build-push.yml 참고)
---
 
## M3-GITOPS-02 서비스 이름
 
| 서비스 | 이름 |
|--------|------|
| Backend API | `backend-api` |
| AI Service | `ai-service` |
| Batch Job | `batch-job` |
 
---
 
## M3-VALID-A CI 검증 절차
 
### 로컬 검증 명령어
 
**Backend**
```bash
./gradlew clean test
./gradlew bootJar
```
 
**AI Service**
```bash
pip install -r requirements.txt
python -c "from main import app"
```
 
**Frontend**
```bash
npm ci
npx tsc --noEmit
npx eslint .
```
 
### GitHub Actions 로그 확인 절차
 
1. PR 생성 후 Actions 탭 이동
2. 해당 workflow run 클릭
3. 실패한 step 클릭 → 로그 확인
4. Backend의 경우 Artifacts에서 `backend-gradle-test-report` 다운로드 가능
---
 
## 보안 정책
 
- AWS Access Key, OpenAI API Key, DB password, JWT secret 등 모든 민감정보는 GitHub Secrets 또는 CI용 dummy값 사용
- `.env` 파일 커밋 금지 (`.gitignore` 적용)
- CI에서 실제 외부 API 호출 없음
- Actions 로그에 secret 값 마스킹 처리됨