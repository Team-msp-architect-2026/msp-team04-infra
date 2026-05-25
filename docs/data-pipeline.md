# EventBridge Scheduler + Lambda Collector 데이터 파이프라인

## 개요

MoMent 인프라에서는 공공데이터 수집 파이프라인의 실행 트리거와 수집 실행 계층을 EventBridge Scheduler와 Lambda Collector로 구성한다.

전체 목표 흐름은 다음과 같다.

EventBridge Scheduler
  -> Lambda Collector
  -> Public Data API
  -> S3 Raw Bucket
  -> SQS Main Queue
  -> Spring Batch
  -> RDS / OpenSearch

M2-DATA-01에서는 실제 공공데이터 수집 로직 완성이 아니라, Lambda Collector가 S3 Raw Bucket과 SQS Main Queue로 이어질 수 있는 기본 인프라 골격을 구성한다.

## Dev / Prod 활성화 정책

MoMent Terraform 구성은 Dev-first / Prod-optional 전략을 따른다.

| Environment | 기본값 | 설명 |
| --- | --- | --- |
| dev | enabled | 개발 및 검증용 EventBridge Scheduler + Lambda Collector |
| prod | disabled | 최종 데모 또는 리허설 시점에만 명시적으로 활성화 |

기본 변수는 다음과 같다.

enable_dev_data_pipeline  = true
enable_prod_data_pipeline = false

단, 데이터 파이프라인은 SQS Main Queue URL을 필요로 하므로 다음 조건이 함께 만족되어야 생성된다.

- Dev: enable_dev_data_pipeline && enable_dev_sqs
- Prod: enable_prod_data_pipeline && enable_prod_sqs

## Lambda Collector

Lambda Collector는 다음 환경변수를 사용한다.

| 환경변수 | 설명 |
| --- | --- |
| PROJECT_NAME | 프로젝트 이름 |
| ENVIRONMENT | dev 또는 prod |
| RAW_BUCKET_NAME | S3 Raw Bucket 이름 |
| QUEUE_URL | SQS Main Queue URL |
| PUBLIC_DATA_API_URL | 공공데이터 API URL. 비어 있으면 샘플 payload 모드로 동작 |

현재 Collector skeleton은 실행 시 JSON payload를 S3 `raw/{environment}/public-data/` prefix 아래에 저장하고, 저장된 S3 object 위치를 SQS 메시지로 발행한다.

## IAM 권한

Lambda Collector 실행 Role은 IAM 모듈의 `lambda_collector` Role을 재사용한다.

부여되는 권한은 다음과 같다.

| 대상 | 권한 |
| --- | --- |
| CloudWatch Logs | Lambda 기본 실행 로그 |
| S3 Raw Bucket | raw / processed / failed prefix 접근 |
| SQS Main Queue | SendMessage, GetQueueAttributes |

EventBridge Scheduler는 별도의 invoke role을 사용하여 Lambda Collector를 호출한다.

## Scheduler 상태

Scheduler state 기본값은 `DISABLED`다.

개발 중 예기치 않은 주기 실행과 비용 발생을 막기 위해, 수동 검증 전까지는 DISABLED 상태를 유지한다.

Dev Scheduler를 실제 주기 실행하려면 다음 값을 명시적으로 변경한다.

dev_data_pipeline_schedule_state = "ENABLED"

Prod Scheduler는 최종 데모 또는 리허설 기간 외에는 DISABLED 또는 미생성 상태를 유지한다.

## Destroy 주의사항

삭제 전에는 다음을 확인한다.

- S3 Raw Bucket에 보존해야 할 원본 객체가 있는지 확인
- SQS Main Queue / DLQ에 남은 메시지가 있는지 확인
- Lambda CloudWatch Logs 보존 필요 여부 확인
- Prod 데이터 파이프라인은 활성화 전후로 비용과 데이터 보존 여부를 별도 확인
