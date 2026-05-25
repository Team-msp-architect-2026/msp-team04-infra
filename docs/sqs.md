# SQS + DLQ 구성

## 개요

MoMent 인프라에서는 공공데이터 수집 이후 비동기 배치 처리를 위해 SQS Main Queue와 DLQ를 구성한다.

SQS는 EventBridge Scheduler와 Lambda Collector, Spring Batch 사이의 비동기 메시지 전달 계층으로 사용한다.

기본 흐름은 다음과 같다.

EventBridge Scheduler
  -> Lambda Collector
  -> S3 Raw Bucket 저장
  -> SQS Main Queue 메시지 전송
  -> Spring Batch Job 메시지 소비
  -> RDS / OpenSearch 적재

처리에 반복 실패한 메시지는 DLQ로 이동하여 실패 원인을 분리 확인할 수 있도록 한다.

## Dev / Prod 활성화 정책

MoMent Terraform 구성에서는 Dev 환경을 기본 검증 대상으로 설정한다.

| Environment | 기본값 | Queue |
| --- | --- | --- |
| dev | enabled | moment-dev-public-data-queue |
| prod | disabled | moment-prod-public-data-queue |

Prod SQS는 최종 데모 또는 리허설 시점에 명시적으로 활성화한다.

enable_dev_sqs  = true
enable_prod_sqs = false

## Queue 구성

| 항목 | 기본값 |
| --- | --- |
| Visibility Timeout | 300초 |
| Main Queue Retention | 345600초, 4일 |
| DLQ Retention | 1209600초, 14일 |
| Max Receive Count | 3 |
| Receive Wait Time | 10초 |
| Message Size | 262144 bytes |
| Server Side Encryption | SQS Managed SSE enabled |

## DLQ Redrive 정책

Main Queue는 DLQ를 대상으로 redrive policy를 가진다.

기본 maxReceiveCount는 3이다.

즉, Batch Job이 메시지를 반복 처리하지 못하고 visibility timeout 이후 다시 수신되는 흐름이 3회 누적되면 해당 메시지는 DLQ로 이동한다.

## IAM 연결

SQS Queue ARN은 IAM 모듈의 sqs_queue_arns 입력으로 전달한다.

| 대상 | 권한 |
| --- | --- |
| Batch Job Pod | ReceiveMessage, DeleteMessage, ChangeMessageVisibility, GetQueueAttributes |
| Lambda Collector | SendMessage, GetQueueAttributes |

DLQ는 실패 메시지 격리용으로 두며, 기본 Batch/Lambda 권한에는 Main Queue ARN만 연결한다.

## Destroy 주의사항

SQS Queue 삭제 전에는 Main Queue와 DLQ에 남아 있는 메시지를 확인해야 한다.

특히 DLQ에 메시지가 남아 있으면 수집 또는 배치 처리 실패 증거일 수 있으므로, 삭제 전 원인 확인 또는 캡처가 필요하다.
