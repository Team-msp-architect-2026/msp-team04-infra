# Terraform Environment 분리 전략

## 1. 목적

MoMent Terraform 구성은 Dev와 Prod를 별도 environment와 state key로 분리한다.

초기 M2 구성에서는 빠른 검증을 위해 terraform/environments/dev 안에서 Network, Dev, Prod, Shared 성격 리소스가 함께 관리되었다.

M2-OPS-01에서는 terraform/environments/prod 골격과 prod/terraform.tfstate state key를 만들었다.

M2-OPS-02에서는 Prod 리소스 관리 위치를 terraform/environments/prod 기준으로 옮기기 위한 wiring을 추가하고, Dev environment에 남아 있는 Prod 리소스와 shared/account-level 리소스의 state 처리 전략을 문서화한다.

## 2. Environment 구조

    terraform/
    ├── environments/
    │   ├── dev/
    │   └── prod/
    └── modules/

| Environment | Backend key | 역할 |
| --- | --- | --- |
| dev | dev/terraform.tfstate | Dev 중심 개발/검증 인프라 |
| prod | prod/terraform.tfstate | Prod VPC/EKS/Data/Edge 관리 대상 |

Prod environment는 별도 state key를 사용하므로 Dev state와 논리적으로 분리된다.

## 3. M2-OPS-02 Prod wiring 기준

terraform/environments/prod는 다음 Prod 리소스를 관리 대상으로 wiring한다.

- Prod VPC
- Prod Security Groups
- Prod VPC Endpoints
- Prod EKS Cluster
- Prod RDS PostgreSQL
- Prod Redis
- Prod OpenSearch
- Prod SQS
- Prod Data Pipeline
- Edge Layer

다만 모든 활성화 flag는 기본 false이다.

    enable_prod_vpc            = false
    enable_prod_vpc_endpoints  = false
    enable_prod_eks            = false
    enable_prod_nodegroups     = false
    enable_prod_data_tier      = false
    enable_prod_rds            = false
    enable_prod_redis          = false
    enable_prod_opensearch     = false
    enable_prod_sqs            = false
    enable_prod_data_pipeline  = false
    enable_edge                = false

이 정책은 실수로 Prod 리소스가 생성되어 비용이 발생하는 것을 막기 위한 안전장치이다.

## 4. Dev environment 정리 기준

기존 dev/main.tf에는 Prod module 호출이 남아 있다.

대표 예시는 다음과 같다.

- prod_vpc
- prod_security_group
- prod_vpc_endpoint
- prod_sqs
- prod_data_pipeline
- prod_eks
- prod_redis
- prod_rds
- prod_opensearch
- edge

이 리소스들은 장기적으로 prod environment에서 관리하는 방향이 맞다.

하지만 현재 Network VPC, Transit Gateway, Dev VPC, Prod VPC가 dev/main.tf 안에서 강하게 연결되어 있으므로, Prod module을 단순 삭제하면 TGW 참조와 route table 연결이 깨질 수 있다.

따라서 Dev environment의 Prod module 제거는 다음 순서로만 진행한다.

1. 현재 Dev state에 실제로 관리 중인 Prod 리소스가 있는지 확인
2. Prod 리소스별 state mv 또는 import 대상 분류
3. Shared/Network 리소스 의존성 분리
4. prod environment에서 동일 리소스 address 준비
5. 별도 승인 후 terraform state mv 또는 terraform import 수행
6. state 이동 후 dev/main.tf에서 기존 Prod module 제거
7. dev/prod 각각 plan에서 destroy/replacement 여부 확인

M2-OPS-02에서는 실제 state mv/import/apply를 수행하지 않는다.

## 5. Shared/account-level 리소스 기준

다음 리소스는 Prod environment로 무작정 복제하지 않는다.

| 리소스 | 기준 |
| --- | --- |
| ECR | Dev/Prod 이미지 저장소는 shared 성격으로 유지하거나 별도 shared environment 후보 |
| GitHub OIDC Provider | account-level provider이므로 중복 생성 금지 |
| 공통 IAM Role/Policy | 서비스 실행 권한은 shared 성격으로 보고 중복 생성 금지 |
| OpenSearch service-linked role | account-level 리소스이므로 한 계정에 한 번만 생성 |
| S3 Raw Bucket | 공공데이터 raw 보관 전략에 따라 shared bucket 유지 가능 |
| Terraform backend bucket / lock table | backend 자체는 별도 관리 대상이며 prod env에서 생성하지 않음 |
| Network VPC / TGW | Dev/Prod 양쪽을 연결하는 shared/network 성격 |

Prod data pipeline은 shared Lambda role ARN과 shared raw bucket name을 변수로 주입받는다.

    shared_lambda_collector_role_arn = ""
    shared_raw_bucket_name           = ""

## 6. Network / TGW 분리 기준

현재 아키텍처는 Network VPC가 OpenVPN, 중앙 NAT egress, Transit Gateway hub 역할을 한다.

TGW는 Network, Dev, Prod VPC를 연결하지만 Dev와 Prod 직접 통신은 허용하지 않는다.

Prod environment에서 Prod VPC를 생성하더라도 TGW 자체를 Prod environment에서 새로 만들지는 않는다.

Prod VPC가 TGW route를 가져야 할 경우에는 다음 기준을 따른다.

- Network/TGW state에서 TGW ID를 output으로 제공
- Prod environment가 remote state 또는 명시적 변수로 TGW ID를 주입받음
- state 이동/import 전략이 승인된 뒤 Prod VPC route를 활성화

현재 prod_transit_gateway_id 기본값은 null이다.

    prod_transit_gateway_id = null

## 7. State 이동 / Import 전략

M2-OPS-02에서는 실제 state 이동을 하지 않는다.

향후 실제 이관이 필요할 경우 후보는 다음과 같이 분류한다.

| 대상 | 전략 |
| --- | --- |
| dev state가 관리 중인 Prod 리소스 | terraform state mv 후보 |
| AWS에는 존재하지만 Terraform state에 없는 Prod 리소스 | terraform import 후보 |
| shared/account-level 리소스 | prod로 이동하지 않고 shared/network 기준 검토 |
| 삭제 예정 legacy local artifact | git rm 또는 .gitignore 정리 |

state 이동 전에는 반드시 다음을 확인한다.

- terraform state list
- terraform plan에서 destroy/replacement 여부
- Prod environment address 준비 여부
- shared/account-level 중복 생성 여부
- 비용 발생 리소스 flag 상태

## 8. Prod NodeGroup 기준

Prod EKS Cluster wiring은 prod environment에 추가한다.

다만 Prod Managed NodeGroup 상세 운영 스펙은 M2-EKS-04에서 별도로 다룬다.

M2-OPS-02에서는 enable_prod_nodegroups flag를 유지하되, 실제 nodegroup 상세 구성은 추가하지 않는다.

## 9. 검증 명령어

Prod environment는 backend 연결 없이 정적 검증한다.

    terraform -chdir=terraform/environments/prod fmt
    terraform -chdir=terraform/environments/prod init -backend=false
    terraform -chdir=terraform/environments/prod validate

Dev environment도 기존 구조 영향 여부를 확인한다.

    terraform -chdir=terraform/environments/dev validate

전체 포맷은 다음으로 확인한다.

    terraform fmt -recursive

## 10. 운영 주의사항

Prod environment를 실제로 활성화하기 전에는 다음을 확인한다.

- Prod 관련 enable flag가 의도한 것만 true인지 확인
- shared IAM/S3/ECR/OIDC를 중복 생성하지 않는지 확인
- OpenSearch service-linked role 중복 생성 여부 확인
- Prod ALB DNS 없이 Edge를 활성화하지 않는지 확인
- terraform plan에서 destroy/replacement가 없는지 확인
- state mv/import는 별도 승인 후 수행
- Prod apply는 별도 승인 후 수행
