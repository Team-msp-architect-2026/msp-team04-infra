# ☁️ MoMent Cloud Infrastructure

![Terraform](https://img.shields.io/badge/Terraform-IaC-844FBA?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazonaws&logoColor=white)
![EKS](https://img.shields.io/badge/Amazon%20EKS-Kubernetes-326CE5?logo=kubernetes&logoColor=white)
![GitOps](https://img.shields.io/badge/GitOps-ArgoCD-FE5A1D?logo=argo&logoColor=white)
![Status](https://img.shields.io/badge/status-in%20progress-blue)

> Terraform 기반 AWS 인프라 구성 및 EKS GitOps 운영 환경  
> Multi-VPC, Transit Gateway, EKS, RDS, Redis, OpenSearch, CI/CD, Monitoring을 포함한 MoMent 인프라 레포지토리

---

## 📌 Overview

**MoMent Infrastructure**는  
저출산 시대 부모의 양육 부담을 줄이기 위한 AI 육아지원 플랫폼 **MoMent**의 AWS 인프라를 관리하는 레포지토리입니다.

본 레포지토리는 단순히 AWS 리소스를 생성하는 것을 넘어,  
실제 서비스 운영을 가정한 **Cloud Native Infrastructure** 구조를 설계하고 구현하는 것을 목표로 합니다.

주요 구성은 다음과 같습니다.

- Terraform 기반 Infrastructure as Code
- Multi-VPC 기반 네트워크 분리
- Transit Gateway 중심의 VPC 간 라우팅
- Network VPC 기반 Centralized NAT Gateway
- EKS 기반 애플리케이션 실행 환경
- RDS, Redis, OpenSearch 기반 데이터 계층
- GitHub Actions, ECR, ArgoCD 기반 GitOps 배포 구조
- Prometheus, Grafana, CloudWatch 기반 모니터링 및 알림 구조

---

## 🏗️ Architecture

> 아래 아키텍처는 MoMent 서비스의 AWS 기반 인프라 설계도입니다.

<!-- 
이미지 파일을 레포에 올린 뒤 아래 경로를 실제 이미지 경로로 맞춰주세요.
예: docs/images/moment-infra-architecture.png
-->

<img width="3543" height="2231" alt="최종 인프라 아키텍처 이미지" src="https://github.com/user-attachments/assets/d29ca354-6092-4a3e-a42d-26b029147a74" />


### Architecture Flow

```text
User
  → Route 53
  → CloudFront
  → WAF
  → ALB
  → EKS Cluster
  → Backend / AI Service / Batch Job Pods
  → RDS PostgreSQL / Redis / OpenSearch
```

### Admin & Operator Access Flow

```text
Developer / Infra Operator
  → IAM Role + MFA
  → SSM
  → Private Resources
```

---

## 🌐 Network Design

MoMent 인프라는 단일 AWS 계정 환경에서 여러 VPC를 논리적으로 분리하여 구성합니다.

| VPC | CIDR | 역할 |
|---|---:|---|
| Network VPC | `10.0.0.0/16` | 중앙 NAT Gateway, Transit Gateway 연결, 운영 접근 허브 |
| Prod App VPC | `10.10.0.0/16` | 운영 EKS, ALB, Backend/API/AI/Batch 워크로드 |
| Prod Data VPC | `10.20.0.0/16` | 운영 RDS, Redis, OpenSearch 데이터 계층 |
| Dev App VPC | `10.30.0.0/16` | 개발 EKS 및 테스트 워크로드 |
| Dev Data VPC | `10.40.0.0/16` | 개발 RDS, Redis, OpenSearch 데이터 계층 |

### Network Key Points

- App VPC와 Data VPC를 분리하여 보안 경계를 명확히 설정
- Prod와 Dev 환경을 VPC 단위로 분리
- VPC 간 통신은 Transit Gateway를 통해 중앙에서 제어
- 외부 인터넷 통신은 Network VPC의 Centralized NAT Gateway를 통해 통제
- Data VPC는 외부에서 직접 접근할 수 없도록 구성

---

## 🧩 Infrastructure Components

### 1. Network

- VPC
- Public Subnet
- Private App Subnet
- Private Data Subnet
- Internet Gateway
- NAT Gateway
- Transit Gateway
- Route Table
- Security Group

### 2. Application Platform

- Amazon EKS
- Worker Node Group
- Backend API Pod
- AI Service Pod
- Batch Job Pod
- Kubernetes Service / Ingress
- HPA 기반 Auto Scaling 고려

### 3. Data Layer

- Amazon RDS PostgreSQL
- Amazon ElastiCache Redis
- Amazon OpenSearch / OpenSearch Serverless Vector Collection
- Private Data Subnet 기반 데이터 계층 분리

### 4. CI/CD & GitOps

- GitHub Actions
- Amazon ECR
- Helm
- GitOps Manifest
- ArgoCD
- EKS 자동 배포

```text
GitHub Repository
  → GitHub Actions
  → Docker Build
  → Amazon ECR Push
  → Helm values image tag update
  → GitOps Repository
  → ArgoCD Sync
  → EKS Cluster
```

### 5. Monitoring & Alert

- Prometheus
- Grafana
- CloudWatch
- SNS
- Lambda
- Slack Alert

```text
EKS Workloads
  → Prometheus
  → Grafana Dashboard

AWS Resources
  → CloudWatch Alarm
  → SNS
  → Lambda
  → Slack
```

### 6. Data Collection Batch Pipeline

- EventBridge Scheduler
- Lambda Collector
- Public Data API
- S3 Raw Data
- SQS
- Spring Batch
- RDS / OpenSearch

```text
EventBridge Scheduler
  → Lambda Collector
  → Public Data API
  → S3 Raw Data
  → SQS
  → Spring Batch
  → RDS / OpenSearch
```

---

## ⚙️ Tech Stack

| Category | Stack |
|---|---|
| Cloud | AWS |
| IaC | Terraform |
| Container Orchestration | Amazon EKS |
| Container Registry | Amazon ECR |
| Network | VPC, Subnet, Route Table, NAT Gateway, Transit Gateway |
| Database | Amazon RDS PostgreSQL |
| Cache | Amazon ElastiCache Redis |
| Search | Amazon OpenSearch / OpenSearch Serverless |
| CI/CD | GitHub Actions, ArgoCD, Helm |
| Security | IAM, OIDC, MFA, WAF, ACM, Secrets Manager, Security Group |
| Monitoring | CloudWatch, Prometheus, Grafana, SNS, Slack |
| Batch Pipeline | EventBridge, Lambda, S3, SQS, Spring Batch |

---

## 📂 Repository Structure

현재 인프라 개발은 `develop` 브랜치를 기준으로 진행합니다.

```bash
msp-team04-infra
├── terraform
│   ├── environments
│   │   ├── dev
│   │   └── prod
│   └── modules
│       ├── network-vpc
│       ├── app-vpc
│       ├── data-vpc
│       ├── transit-gateway
│       ├── eks
│       ├── rds
│       ├── redis
│       ├── opensearch
│       ├── ecr
│       ├── s3
│       ├── sqs
│       ├── iam
│       └── security-group
│
├── gitops
├── monitoring
├── scripts
├── docs
├── .github
└── README.md
```

---

## 🌿 Branch Strategy

| Branch | 역할 |
|---|---|
| `main` | 안정 버전, 발표 및 배포 기준 브랜치 |
| `develop` | 인프라 개발 통합 브랜치 |
| `feature/*` | 개별 이슈 작업 브랜치 |
| `fix/*` | 버그 수정 브랜치 |
| `hotfix/*` | 긴급 수정 브랜치 |

### Development Flow

```text
feature/*
  → develop
  → 검증 완료
  → main
```

일반적인 개발 작업은 `develop` 브랜치를 기준으로 진행하며,  
검증이 완료된 안정 버전만 `main` 브랜치에 반영합니다.

---

## 🚀 Getting Started

최신 인프라 코드는 `develop` 브랜치에서 확인할 수 있습니다.

```bash
git clone https://github.com/Team-msp-architect-2026/msp-team04-infra.git
cd msp-team04-infra
git checkout develop
git pull origin develop
```

Terraform 작업은 환경 디렉토리 기준으로 진행합니다.

```bash
cd terraform/environments/dev
terraform init
terraform fmt -recursive
terraform validate
terraform plan
```

실제 리소스 생성은 비용이 발생할 수 있으므로 팀 내 합의 후 진행합니다.

```bash
terraform apply
```

실습 후 사용하지 않는 리소스는 삭제합니다.

```bash
terraform destroy
```

---

## 🔐 Security Design

MoMent 인프라는 다음 보안 원칙을 기준으로 설계합니다.

- AWS Access Key 직접 사용 지양
- GitHub Actions OIDC 기반 AWS 인증
- IAM Role 기반 최소 권한 적용
- MFA 기반 운영자 접근
- SSM 기반 Private Resource 접근
- Public / Private App / Private Data Subnet 분리
- Data VPC 외부 직접 접근 차단
- Security Group 기반 접근 제어
- WAF를 통한 외부 요청 필터링
- Secrets Manager를 통한 민감 정보 관리

---

## 📊 Monitoring Design

운영 가시성을 확보하기 위해 다음 항목을 모니터링 대상으로 설정합니다.

- EKS Pod 상태
- Node 리소스 사용량
- API 요청 수
- API Latency
- 4xx / 5xx Error Rate
- RDS CPU / Connection / Storage
- Redis Memory / Connection
- OpenSearch Query Latency
- Batch Job 성공 / 실패 여부
- CloudWatch Alarm 기반 Slack 알림

---

## 💰 Cost Control

본 프로젝트는 교육 및 포트폴리오 목적의 실습 환경을 포함하므로 비용 최적화를 고려합니다.

- 실습 시간에만 리소스 생성
- 사용 후 Terraform destroy 수행
- Dev 환경은 최소 사양 우선 적용
- Prod 환경은 확장 시나리오 기준으로 설계
- NAT Gateway, RDS, EKS Node 비용 주의
- 불필요한 리소스 장시간 실행 방지

---

## 🧠 Design Notes

### 왜 Multi-VPC 구조인가?

App 계층과 Data 계층을 VPC 단위로 분리하여 보안 경계를 명확히 하고, 장애 영향 범위를 줄이기 위함입니다.

### 왜 Transit Gateway를 사용하는가?

VPC Peering을 여러 개 연결하는 방식보다 중앙에서 라우팅을 제어하기 쉽고, 추후 VPC가 추가되어도 확장성이 좋기 때문입니다.

### 왜 Centralized NAT Gateway를 사용하는가?

각 VPC마다 NAT Gateway를 두는 대신 Network VPC에 중앙 NAT Gateway를 배치하여 외부 통신 경로를 통제하고, 네트워크 운영 구조를 단순화하기 위함입니다.

### 왜 EKS를 사용하는가?

Backend API, AI Service, Batch Job 등 서로 다른 워크로드를 분리 운영하고, HPA와 Node Group을 통해 트래픽 변화에 대응하기 위함입니다.

### 왜 GitOps를 사용하는가?

배포 상태를 Git 기준으로 관리하여 변경 이력을 명확히 남기고, ArgoCD를 통해 실제 클러스터 상태와 선언된 상태를 지속적으로 동기화하기 위함입니다.

---

## 🗂️ Related Repositories

| Repository | Description |
|---|---|
| `msp-team04-frontend` | React Native 기반 MoMent 모바일 앱 |
| `msp-team04-backend` | Spring Boot 기반 MoMent Backend API 서버 |
| `msp-team04-infra` | Terraform 기반 AWS 인프라 및 GitOps 운영 환경 |
| `msp-team04-wiki` | 프로젝트 문서, 회의록, API 명세, 아키텍처 문서 |

---

## 👥 Team

| Role | Name | GitHub |
|---|---|---|
| Team Leader | 정아름 | `@armddi` |
| Team Member | 김민지 | `@cakefeelsgood` |

---

## 📎 Documentation

자세한 설계 문서, 회의록, API 명세, 스프린트 계획은 Wiki에서 관리합니다.

👉 [MoMent Wiki](https://github.com/Team-msp-architect-2026/msp-team04-wiki/wiki)

---

## ✅ Current Status

현재 MoMent 인프라는 M2 Infra Bootstrap 단계로,  
Terraform 기반 Multi-VPC 네트워크와 EKS 중심의 Cloud Native 인프라를 단계적으로 구성하고 있습니다.

최신 개발 작업은 `develop` 브랜치에서 진행 중이며,  
검증이 완료된 안정 버전만 `main` 브랜치에 반영합니다.

---

## 📌 License

This project is developed for educational and portfolio purposes as part of the MSP Cloud Architect Bootcamp.
