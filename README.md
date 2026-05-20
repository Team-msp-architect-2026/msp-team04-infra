# MoMent Terraform 인프라

## 개요

MoMent 프로젝트의 AWS 인프라를 Terraform으로 관리합니다.
Primary Region은 `ap-northeast-3` (Osaka)를 사용합니다.

## 디렉토리 구조
```
terraform/
├── environments/
│   └── dev/
│       ├── main.tf                  # locals (공통 태그)
│       ├── provider.tf              # AWS provider 설정
│       ├── variables.tf             # 공통 변수 정의
│       ├── outputs.tf               # 출력값
│       └── terraform.tfvars.example # 변수 예시
│
└── modules/
├── network-vpc/     # Network VPC
├── prod-vpc/        # Prod VPC
├── dev-vpc/         # Dev VPC
├── transit-gateway/
├── security-group/
├── vpc-endpoint/
├── ecr/
├── eks/
├── rds/
├── redis/
├── opensearch/
└── s3/
```

## VPC 구조

| VPC | CIDR | 용도 |
|-----|------|------|
| Network VPC | 10.0.0.0/16 | 공통 네트워크 (NAT, IGW 등) |
| Prod VPC | 10.10.0.0/16 | 운영 환경 |
| Dev VPC | 10.20.0.0/16 | 개발 환경 |

## Provider

| Provider | Region | 용도 |
|----------|--------|------|
| aws (default) | ap-northeast-3 | 기본 리소스 |
| aws.use1 | us-east-1 | CloudFront ACM 인증서 |

## 공통 태그

모든 리소스에 아래 태그가 자동 적용됩니다.

| Key | Value |
|-----|-------|
| Project | moment |
| Environment | dev / prod |
| ManagedBy | terraform |
| Owner | team04 |

## 시작하기

```bash
cd terraform/environments/dev

cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars 값 수정 후

terraform init
terraform fmt -recursive
terraform validate
terraform plan
```