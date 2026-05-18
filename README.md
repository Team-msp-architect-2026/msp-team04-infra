# MoMent Terraform Infrastructure
 
단일 AWS 계정 제약을 고려한 Primary Region Multi-VPC 논리 분리 아키텍처를  
Terraform으로 관리하는 IaC 레포지토리.
 
---
 
## 아키텍처 개요
 
| 구분 | 값 |
|------|-----|
| Primary Region | `ap-northeast-3` (Osaka) |
| Secondary Region | `us-east-1` (N. Virginia) — CloudFront ACM 전용 |
| 계정 구조 | Single AWS Account / Multi-VPC 논리 분리 |
 
### VPC 구성
 
| VPC | CIDR | 역할 |
|-----|------|------|
| Network VPC | `10.0.0.0/16` | Centralized NAT GW, Transit Gateway Attachment, optional Bastion/VPN |
| Prod App VPC | `10.10.0.0/16` | ALB, EKS (Backend API / AI Service / Batch Job) |
| Prod Data VPC | `10.20.0.0/16` | RDS PostgreSQL, ElastiCache Redis, OpenSearch |
| Dev App VPC | `10.30.0.0/16` | Dev ALB, Dev EKS |
| Dev Data VPC | `10.40.0.0/16` | Dev RDS, Dev Redis, Dev OpenSearch |
 
Transit Gateway를 통해 서비스 트래픽, 데이터 접근, 중앙 egress, 관리자 접근 경로를 분리한다.
 
---
 
## 디렉토리 구조
 
```
msp-team04-terraform/
├── terraform/
│   ├── environments/
│   │   └── dev/                        # Dev 환경 루트 모듈
│   │       ├── main.tf                 # 모듈 호출 (구현 진행에 따라 주석 해제)
│   │       ├── variables.tf            # 공통 변수 정의
│   │       ├── outputs.tf              # 환경 outputs
│   │       ├── provider.tf             # AWS provider 설정 (ap-northeast-3 + use1 alias)
│   │       └── terraform.tfvars.example
│   │
│   └── modules/                        # 재사용 가능한 Terraform 모듈
│       ├── network-vpc/                # Network VPC, NAT GW, Public/Inspection/TGW Subnet
│       ├── app-vpc/                    # App VPC, ALB, Public/Private App/TGW Subnet
│       ├── data-vpc/                   # Data VPC, Private DB/Cache/Search/TGW Subnet
│       ├── transit-gateway/            # Transit Gateway, prod/dev/egress Route Table
│       ├── ecr/                        # ECR Repository (Backend API / AI Service / Batch Job)
│       ├── eks/                        # EKS Cluster, Managed Node Group
│       ├── rds/                        # RDS PostgreSQL
│       ├── redis/                      # ElastiCache Redis / Valkey
│       ├── opensearch/                 # OpenSearch Domain
│       ├── s3/                         # S3 Bucket (Raw Data, Terraform State 등)
│       ├── security-group/             # Security Group 공통 모듈
│       └── vpc-endpoint/               # VPC Endpoint (S3, ECR, SSM 등)
│
├── .gitignore
└── README.md
```
 
---

## Network VPC Module

`modules/network-vpc`는 Multi-VPC Hub-and-Spoke 구조에서 중앙 네트워크 허브 역할을 하는 Network VPC를 생성한다.

생성 리소스:

- Network VPC
- Internet Gateway
- Public Subnet 2개
- TGW Attachment Subnet 2개
- Public Route Table
- Elastic IP
- Centralized NAT Gateway
- TGW Attachment Subnet Route Table

Network VPC는 이후 Transit Gateway와 연결되어 App VPC / Data VPC의 outbound 트래픽이 중앙 NAT Gateway를 통해 외부 인터넷으로 나갈 수 있도록 구성된다.

> 실제 `terraform apply`는 S3 Remote Backend와 State Lock 구성이 완료된 이후 진행한다.

---
 
## Provider 구성
 
```hcl
# Primary: ap-northeast-3
provider "aws" {
  region = var.primary_region   # "ap-northeast-3"
}
 
# Secondary: CloudFront ACM 전용 (us-east-1 필수)
provider "aws" {
  alias  = "use1"
  region = "us-east-1"
}
```
 
CloudFront viewer HTTPS용 ACM 인증서는 반드시 `us-east-1`에 생성해야 한다.  
ALB origin HTTPS용 ACM 인증서는 ALB가 위치한 `ap-northeast-3`에 생성한다.
 
---
 
## 시작하기
 
### 1. 사전 요구사항
 
- Terraform >= 1.7.0
- AWS CLI 설정 완료 (`aws configure` 또는 환경 변수)
- S3 Remote Backend용 버킷 및 DynamoDB 테이블 생성 (또는 S3 native lock 사용)
### 2. 변수 파일 준비
 
```bash
cd terraform/environments/dev
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars 편집: rds_username, rds_password 등 민감 값 입력
```
 
### 3. Backend 설정
 
`provider.tf`의 `backend "s3"` 블록 주석을 해제하고 실제 값을 입력하거나,  
`backend.hcl` 파일을 별도로 작성하여 주입한다.
 
```bash
# backend.hcl 방식 예시
terraform init -backend-config=backend.hcl
```
 
### 4. 초기화 및 검증
 
```bash
terraform init
terraform fmt -recursive
terraform validate
```
 
### 5. Plan / Apply
 
```bash
terraform plan -out=tfplan
terraform apply tfplan
```
 
---
 
## GitHub Actions CI/CD
 
인프라 변경은 Pull Request 기반으로 검토한 뒤 GitHub Actions를 통해 plan 및 apply를 수행한다.
 
- AWS 자격증명: GitHub OIDC → AWS IAM Role Assume (장기 Access Key 미사용)
- State 파일: S3 Remote Backend (로컬 저장 금지)
- State Lock: DynamoDB 또는 S3 native lock
```
Pull Request → GitHub Actions → terraform plan (PR 코멘트)
Merge to main → GitHub Actions → terraform apply
```
 
---
 
## 네이밍 규칙
 
리소스 이름은 `{project_name}-{env}-{resource}` 형식을 사용한다.
 
예시: `moment-dev-app-vpc`, `moment-dev-eks`, `moment-prod-rds`
 
---
 
## 참고
 
- [AWS Centralized Egress Architecture](https://docs.aws.amazon.com/vpc/latest/tgw/transit-gateway-nat-igw.html)
- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)