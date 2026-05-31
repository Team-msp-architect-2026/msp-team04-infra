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

- Role ARN: `arn:aws:iam::611058323802:role/moment-dev-github-actions-role`
- 허용 레포: `msp-team04-backend`, `msp-team04-ai` (develop 브랜치)
- 권한 범위: ECR 3개 레포 Push/Pull만 허용 (관리자 권한 없음)
- workflow 설정:
```yaml
  permissions:
    id-token: write
    contents: read
```

---

### ECR Repository 매핑

| 서비스 | ECR Repository | 비고 |
|--------|---------------|------|
| Backend API | `moment-dev-backend-api` | Spring Boot |
| AI Service | `moment-dev-ai-service` | FastAPI |
| Batch Job | `moment-dev-batch-job` | Backend와 동일 Dockerfile |

- 태그 정책: **IMMUTABLE** (동일 tag 재Push 불가)
- scan on push: 활성화

---

### Image Tag 정책

| 환경 | tag 형식 | 예시 | 기준 |
|------|---------|------|------|
| Dev | `dev-{short_sha}` | `dev-8e073f4` | develop push 시 |
| Prod | `prod-{version}` | `prod-v1.0.0` | release tag 시 (추후 구성) |

- `latest` 태그 사용 안 함
- short SHA: `${GITHUB_SHA::7}`

---

### Workflow 구조

| 레포 | workflow 파일 | trigger | 동작 |
|------|-------------|---------|------|
| msp-team04-backend | `backend-build-push.yml` | develop push | Backend API + Batch Job 빌드/Push |
| msp-team04-ai | `ai-ci-build-push.yml` | develop push | AI Service 빌드/Push |

- PR 시: Docker Build 미실행 (CI 품질 게이트만 실행)
- develop push 시: Dev ECR Push 실행
- Prod Push: 추후 release tag 기준으로 별도 workflow 구성 예정
- 멀티 레포 구조로 path filter 없이도 서비스별 독립 빌드 가능

---

### Docker Build 설정

#### Backend API / Batch Job

- Dockerfile: `msp-team04-backend/Dockerfile`
- 멀티스테이지 빌드 (Gradle build → eclipse-temurin:17-jre-alpine)
- EXPOSE: 8080
- health endpoint: `/health`
- Docker Buildx + GHA cache 적용 (`scope=backend`, `scope=batch`)

#### AI Service

- Dockerfile: `msp-team04-ai/Dockerfile`
- Python 3.13-slim
- EXPOSE: 8000
- 실행 command: `uvicorn main:app --host 0.0.0.0 --port 8000`
- Docker Buildx + GHA cache 적용 (`scope=ai-service`)
- OpenAI API Key 없이 빌드 가능 (빌드 시 외부 API 호출 없음)

---

### Image Metadata (OCI Label)

모든 이미지에 아래 label 포함:

| Label | 값 |
|-------|-----|
| `org.opencontainers.image.revision` | commit SHA |
| `org.opencontainers.image.source` | GitHub repository URL |
| `org.opencontainers.image.created` | 빌드 시간 |
| `service` | `backend-api` / `ai-service` / `batch-job` |

---

### M3-CICD-03 연계 산출물

각 workflow 실행 후 artifact로 저장됨 (retention: 7일)

| artifact 이름 | 파일 | 변수 |
|--------------|------|------|
| `backend-image-info` | `image-info.env` | `BACKEND_IMAGE_URI`, `BATCH_JOB_IMAGE_URI`, `IMAGE_TAG`, `BACKEND_DIGEST`, `BATCH_DIGEST` |
| `ai-image-info` | `image-info.env` | `AI_SERVICE_IMAGE_URI`, `IMAGE_TAG`, `AI_DIGEST` |

M3-CICD-03에서 사용할 변수명:
- `BACKEND_IMAGE_URI`
- `AI_SERVICE_IMAGE_URI`
- `BATCH_JOB_IMAGE_URI`
- `IMAGE_TAG`

---

### 트러블슈팅

#### OIDC Assume Role 실패 시
1. workflow `permissions: id-token: write` 설정 확인
2. Role trust policy에 해당 레포/브랜치 허용 여부 확인
3. `aws sts get-caller-identity` step 로그 확인
4. GitHub Actions → Settings → OIDC 설정 확인

#### ECR Push 실패 시
1. OIDC 인증 성공 여부 확인
2. ECR Login step 성공 여부 확인
3. IAM Role ECR Push 권한 확인
4. ECR Repository 이름 오타 확인

#### Docker Build 실패 시
1. Dockerfile 경로 확인 (`context: .`)
2. `.dockerignore` 확인
3. 빌드 로그에서 실패 step 확인
4. Backend: Gradle bootJar 성공 여부 확인
5. AI: `requirements.txt` 패키지 설치 오류 확인

#### Tag Immutable 충돌 발생 시
- 동일 commit SHA로 재실행 시 tag 충돌 발생
- 대응 방법: 새 커밋 생성 후 재실행
- 또는 workflow_dispatch로 수동 실행 시 run number를 tag에 포함하는 방식 검토
- 같은 tag 재사용 금지

---

### ECR Scan 결과 확인 방법

1. AWS ECR 콘솔 → 해당 레포지토리 → 이미지 선택
2. **세부 정보** 클릭 → **스캐닝 및 취약성** 섹션 확인
3. 취약성 등급: 중요 / 높음 / 보통 / 낮음 / 정보
4. scan on push로 자동 실행 (24시간 1회 제한)