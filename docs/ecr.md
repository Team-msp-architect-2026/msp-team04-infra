# ECR Repository 및 이미지 태그 전략

## 1. 개요

MoMent 서비스의 컨테이너 이미지를 저장하기 위해 Amazon ECR Repository를 Terraform으로 구성하였다.

ECR은 Dev / Prod 배포 파이프라인에서 공통으로 참조하는 Shared Services 성격의 리소스로 관리한다.

구성한 Repository는 다음과 같다.

| 서비스 | Repository Name | 용도 |
|---|---|---|
| Backend API | moment-backend-api | Spring Boot Backend API 이미지 저장 |
| AI Service | moment-ai-service | FastAPI 기반 AI Service 이미지 저장 |
| Batch Job | moment-batch-job | Spring Batch 기반 Batch Job 이미지 저장 |

---

## 2. Repository URL

```text
Backend API:
611058323802.dkr.ecr.ap-northeast-3.amazonaws.com/moment-backend-api

AI Service:
611058323802.dkr.ecr.ap-northeast-3.amazonaws.com/moment-ai-service

Batch Job:
611058323802.dkr.ecr.ap-northeast-3.amazonaws.com/moment-batch-job
```

---

## 3. 이미지 태그 전략

ECR Repository는 `IMMUTABLE` 설정을 사용하여 동일 태그 재사용을 방지한다.

이미지 태그는 환경명과 Git commit SHA를 조합하여 관리한다.

| 태그 형식 | 설명 |
|---|---|
| dev-{git_sha} | Dev 환경 배포 이미지 |
| prod-{git_sha} | Prod 환경 배포 이미지 |

`latest` 태그를 덮어쓰는 방식은 사용하지 않고, Git SHA 기반 태그를 사용하여 배포 이력 추적과 롤백 기준을 명확히 한다.

---

## 4. ECR 로그인

```bash
aws ecr get-login-password --region ap-northeast-3 | docker login --username AWS --password-stdin 611058323802.dkr.ecr.ap-northeast-3.amazonaws.com
```

---

## 5. Backend API 이미지 build / push

Backend API는 `msp-team04-backend` Repository의 Dockerfile을 사용한다.

```bash
cd msp-team04-backend

BACKEND_TAG=dev-$(git rev-parse --short HEAD)

docker build -t moment-backend-api:$BACKEND_TAG .

docker tag moment-backend-api:$BACKEND_TAG 611058323802.dkr.ecr.ap-northeast-3.amazonaws.com/moment-backend-api:$BACKEND_TAG

docker push 611058323802.dkr.ecr.ap-northeast-3.amazonaws.com/moment-backend-api:$BACKEND_TAG
```

수동 push 확인 태그:

```text
dev-66ad4bc
```

---

## 6. Batch Job 이미지 build / push

현재 Batch Job은 Backend 프로젝트 내부의 Spring Batch 코드로 구성되어 있다.

따라서 동일한 Spring Boot artifact 기반 이미지를 Batch Job용 ECR Repository에도 별도 태그로 push하였다.

추후 Batch 실행 entrypoint 또는 profile 분리가 필요해지면 `Dockerfile.batch` 또는 별도 이미지 빌드 전략으로 분리할 예정이다.

```bash
cd msp-team04-backend

BATCH_TAG=dev-$(git rev-parse --short HEAD)

docker build -t moment-batch-job:$BATCH_TAG .

docker tag moment-batch-job:$BATCH_TAG 611058323802.dkr.ecr.ap-northeast-3.amazonaws.com/moment-batch-job:$BATCH_TAG

docker push 611058323802.dkr.ecr.ap-northeast-3.amazonaws.com/moment-batch-job:$BATCH_TAG
```

수동 push 확인 태그:

```text
dev-66ad4bc
```

---

## 7. AI Service 이미지 build / push

AI Service는 FastAPI 기반 애플리케이션이며, `msp-team04-ai` Repository의 Dockerfile을 사용한다.

컨테이너 실행 시 OpenAI API를 사용하므로 `OPENAI_API_KEY` 환경변수가 필요하다.  
이미지에는 API Key를 포함하지 않고, 실행 시점에 환경변수로 주입한다.

```bash
cd msp-team04-ai

AI_TAG=dev-$(git rev-parse --short HEAD)

docker build -t moment-ai-service:$AI_TAG .

docker run -d \
  --name moment-ai-test \
  -p 8000:8000 \
  -e OPENAI_API_KEY="dummy-key-for-healthcheck" \
  moment-ai-service:$AI_TAG

curl http://127.0.0.1:8000/health

docker tag moment-ai-service:$AI_TAG 611058323802.dkr.ecr.ap-northeast-3.amazonaws.com/moment-ai-service:$AI_TAG

docker push 611058323802.dkr.ecr.ap-northeast-3.amazonaws.com/moment-ai-service:$AI_TAG
```

수동 push 확인 태그:

```text
dev-fb8a0f0
```

---

## 8. Terraform Output

GitHub Actions에서 사용할 Repository URL은 Terraform output으로 확인할 수 있다.

```bash
cd terraform/environments/dev

terraform output ecr_repository_urls
```

출력 예시:

```text
backend    = 611058323802.dkr.ecr.ap-northeast-3.amazonaws.com/moment-backend-api
ai-service = 611058323802.dkr.ecr.ap-northeast-3.amazonaws.com/moment-ai-service
batch      = 611058323802.dkr.ecr.ap-northeast-3.amazonaws.com/moment-batch-job
```

---

## 9. 수동 검증 결과

| 항목 | 결과 |
|---|---|
| Terraform plan | 6 to add, 0 to change, 0 to destroy |
| Terraform apply | 성공 |
| Backend API image push | 성공 |
| Batch Job image push | 성공 |
| AI Service image build | 성공 |
| AI Service health check | 성공 |
| AI Service image push | 성공 |
| ECR repository URL output | 성공 |