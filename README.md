# ☁️ MoMent Infrastructure

> Terraform 기반 AWS 인프라 구성 및 Kubernetes 배포 환경

---

## 📌 Overview

MoMent Infrastructure는 AWS 클라우드 환경에서  
애플리케이션을 안정적으로 운영하기 위한 인프라를 코드로 관리합니다.

Terraform을 활용한 IaC(Infrastructure as Code) 방식으로  
VPC, EKS, RDS, Redis 등 모든 리소스를 자동으로 생성 및 관리합니다.

---

## ⚙️ Tech Stack

- **Cloud**: AWS
- **IaC**: Terraform
- **Container Orchestration**: Kubernetes (EKS)
- **CI/CD**: GitHub Actions, ArgoCD
- **Container Registry**: ECR
- **Networking**: VPC (3-Tier Architecture)
- **Database**: RDS PostgreSQL (Multi-AZ)
- **Cache**: ElastiCache Redis Cluster
- **Monitoring**: CloudWatch, Grafana
- **Security**: WAF, IAM, OIDC

---

## 🏗️ Architecture

- Public Subnet → ALB (외부 트래픽 수신)
- Private App Subnet → EKS (애플리케이션 서버)
- Private Data Subnet → RDS, Redis (데이터 계층)

👉 데이터 계층은 외부 접근 불가

---

## 🚀 Getting Started

### 1️⃣ Clone

```bash
git clone https://github.com/your-repo/infra.git
cd infra
```

### 2️⃣ Initialize Terraform

```bash
terraform init
```

### 3️⃣ Plan

```bash
terraform plan
```

### 4️⃣ Apply

```bash
terraform apply
```

## 🔐 Security
- OIDC 기반 GitHub Actions 인증 (Access Key 미사용)
- VPC 3계층 네트워크 분리
- WAF를 통한 외부 트래픽 필터링

## 📊 Monitoring
- CloudWatch → 메트릭 수집
- Grafana → 대시보드 시각화
- SNS → Slack 알림 연동

## 🧠 Notes
- 트래픽 증가 시 EKS HPA를 통한 자동 스케일링
- Redis 분산 락으로 동시성 문제 해결
- Terraform으로 인프라 상태 일관성 유지
