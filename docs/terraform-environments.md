# Terraform Environment 분리 전략

## 1. 목적

M2-OPS-01에서는 기존 terraform/environments/dev 단일 환경 중심 구조에서 terraform/environments/prod 골격을 분리한다.

이 작업의 목적은 Dev와 Prod의 Terraform state를 분리하여 운영 환경 변경이 개발 환경 state에 섞이지 않도록 하는 것이다.

## 2. 현재 구조

현재 Terraform 구성은 다음 구조를 사용한다.

    terraform/
    ├── environments/
    │   ├── dev/
    │   └── prod/
    └── modules/

dev 환경은 기존 개발 및 검증용 환경이다.

prod 환경은 이번 이슈에서 생성한 운영 환경 골격이며, 기본적으로 실제 Prod 리소스를 생성하지 않는다.

## 3. State 분리 기준

| Environment | Backend key | 용도 |
| --- | --- | --- |
| dev | dev/terraform.tfstate | 개발 및 검증용 인프라 |
| prod | prod/terraform.tfstate | 운영/최종 데모용 Prod 인프라 골격 |

Prod environment는 별도의 state key를 사용하므로 Dev state와 논리적으로 분리된다.

## 4. M2-OPS-01 범위

이번 이슈에서 수행하는 작업은 다음과 같다.

- terraform/environments/prod 디렉토리 생성
- Prod 전용 backend.tf 생성
- Prod 전용 provider.tf 생성
- Prod 전용 main.tf, variables.tf, outputs.tf 생성
- Prod 전용 terraform.tfvars.example 생성
- Prod state key를 prod/terraform.tfstate로 분리
- Prod 리소스 기본 비활성화

## 5. 이번 이슈에서 하지 않는 것

이번 이슈에서는 다음 작업을 하지 않는다.

- 기존 Dev state migration
- 기존 Dev 리소스 삭제
- Prod 전체 리소스 apply
- Prod VPC/EKS/Data/Edge 상세 구현
- Shared/account-level 리소스 이동
- Terraform state mv/import

## 6. Prod 기본 활성화 정책

Prod 환경의 모든 주요 resource wiring flag는 기본적으로 false이다.

    enable_prod_vpc           = false
    enable_prod_eks           = false
    enable_prod_nodegroups    = false
    enable_prod_data_tier     = false
    enable_prod_data_pipeline = false
    enable_edge               = false

이는 실수로 Prod 리소스가 생성되어 비용이 발생하는 것을 방지하기 위한 안전장치이다.

## 7. 향후 Prod wiring 후보

향후 별도 이슈에서 다음 리소스를 Prod environment에 연결할 수 있다.

- Prod VPC
- Prod Security Groups
- Prod VPC Endpoints
- Prod EKS
- Prod EKS NodeGroups
- Prod RDS / Redis / OpenSearch
- Prod SQS / Data Pipeline
- Edge Layer

## 8. Shared/account-level 리소스 주의사항

다음 리소스는 account-level 또는 shared 성격이 있으므로 Prod environment로 이동하기 전에 별도 검토가 필요하다.

- ECR
- GitHub OIDC Provider
- IAM roles and policies
- OpenSearch service-linked role
- S3 Raw Bucket strategy
- Terraform backend bucket and lock table

## 9. 검증 명령어

Prod environment는 backend 연결 없이 정적 검증할 수 있다.

    terraform -chdir=terraform/environments/prod fmt
    terraform -chdir=terraform/environments/prod init -backend=false
    terraform -chdir=terraform/environments/prod validate

Prod 리소스 apply는 이번 이슈 범위가 아니며, 별도 승인과 계획 검토 후 진행한다.

## 10. 운영 주의사항

Prod environment를 실제로 활성화하기 전에는 다음을 확인한다.

- terraform plan에서 의도하지 않은 destroy/replacement가 없는지 확인
- Dev state와 Prod state가 섞이지 않았는지 확인
- Shared/account-level 리소스 중복 생성 여부 확인
- 비용 발생 리소스 활성화 여부 확인
- Edge Layer는 실제 Prod ALB origin 준비 후 활성화
