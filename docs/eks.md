# EKS Cluster 구성

## 목적

M2-EKS-01 범위에서 MoMent EKS Cluster와 기본 Add-on 구성을 Terraform으로 관리한다.

이번 구성은 EKS 공통 모듈, Dev EKS Cluster 기본 활성화, Prod EKS Cluster 선택 활성화 구조를 포함한다.

실습/검증은 비용 절감을 위해 Dev EKS에서 진행하고, Prod EKS는 운영 기간 또는 최종 시연 시점에만 명시적으로 활성화한다.

## 기본 활성화 정책

| 항목 | 기본값 | 설명 |
| --- | --- | --- |
| `enable_dev_eks` | `true` | Dev EKS를 기본 생성하여 실습/검증에 사용 |
| `enable_prod_eks` | `false` | Prod EKS는 비용 절감을 위해 기본 미생성 |

기본 Terraform plan/apply에서는 Dev EKS만 생성되어야 한다.

Prod EKS는 다음처럼 명시적으로 활성화한 경우에만 생성한다.

```bash
-var='enable_prod_eks=true'
```

## 범위

### 포함

- EKS 공통 Terraform 모듈 생성
- Dev EKS Cluster 기본 활성화
- Prod EKS Cluster 선택 활성화 구조
- Kubernetes version 명시
- EKS Cluster IAM Role 연결
- EKS API Endpoint 접근 설정
- EKS Access Entry 기반 관리자 접근 설정
- EKS OIDC Provider 생성
- 기본 EKS managed Add-on 구성
  - VPC CNI
  - CoreDNS
  - kube-proxy
  - AWS EBS CSI Driver
- AWS EBS CSI Driver용 IRSA Role 구성
- Terraform outputs 구성

### 제외

다음 항목은 M2-EKS-01 범위가 아니며, 별도 이슈에서 처리한다.

- EKS Managed NodeGroup 생성
- On-Demand / Spot NodeGroup 분리
- Workload label / taint 기반 배치 정책
- Kubernetes Deployment / Service / Ingress 생성
- AWS Load Balancer Controller 설치
- ALB / Target Group / Listener 생성

특히 `aws_eks_node_group` 리소스는 M2-EKS-02 범위이므로 이번 PR에서 생성하지 않는다.

## Terraform 구성

EKS 모듈 경로는 다음과 같다.

```text
terraform/modules/eks
```

Root module 경로는 다음과 같다.

```text
terraform/environments/dev
```

주요 리소스는 다음과 같다.

```text
aws_eks_cluster
aws_eks_access_entry
aws_eks_access_policy_association
aws_iam_openid_connect_provider
aws_iam_role
aws_iam_role_policy_attachment
aws_eks_addon
```

## Cluster 설정

### Dev EKS

| 항목 | 값 |
| --- | --- |
| Cluster Name | moment-dev-eks-cluster |
| Kubernetes Version | 1.35 |
| VPC | Dev VPC |
| Subnet | Dev Private App Subnets |
| Endpoint Private Access | true |
| Endpoint Public Access | true |
| Authentication Mode | API |
| 기본 활성화 | true |

### Prod EKS

| 항목 | 값 |
| --- | --- |
| Cluster Name | moment-prod-eks-cluster |
| Kubernetes Version | 1.35 |
| VPC | Prod VPC |
| Subnet | Prod Private App Subnets |
| Endpoint Private Access | true |
| Endpoint Public Access | true |
| Authentication Mode | API |
| 기본 활성화 | false |

EKS API public endpoint는 제한된 CIDR에서만 접근하도록 구성한다.

기본값은 기존 admin CIDR을 사용한다.

```text
115.138.87.55/32
```

작업자의 현재 공인 IP가 다르면 Terraform plan/apply 시 다음 변수로 override 한다.

```bash
-var='dev_eks_public_access_cidrs=["<현재-public-ip>/32"]'
```

Prod EKS를 명시적으로 활성화하는 경우에는 다음 변수도 같이 override 할 수 있다.

```bash
-var='prod_eks_public_access_cidrs=["<현재-public-ip>/32"]'
```

## Add-on 구성

| Add-on | Version |
| --- | --- |
| vpc-cni | v1.21.1-eksbuild.1 |
| coredns | v1.13.2-eksbuild.4 |
| kube-proxy | v1.35.3-eksbuild.2 |
| aws-ebs-csi-driver | v1.60.0-eksbuild.1 |

AWS EBS CSI Driver는 전용 IRSA Role을 사용한다.

ServiceAccount subject는 다음과 같다.

```text
system:serviceaccount:kube-system:ebs-csi-controller-sa
```

연결 policy는 AWS managed policy를 사용한다.

```text
arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy
```

## NodeGroup 관련 주의사항

M2-EKS-01에서는 EKS Cluster와 기본 Add-on까지만 구성한다.

Managed NodeGroup은 M2-EKS-02 범위이므로 이번 Terraform plan에 다음 리소스가 포함되면 안 된다.

```text
aws_eks_node_group
aws_launch_template
aws_autoscaling_group
helm_release
kubernetes_deployment
kubernetes_service
kubernetes_ingress
aws_lb
aws_lb_listener
aws_lb_target_group
```

NodeGroup이 아직 없으면 `kubectl get nodes` 결과는 노드가 없는 상태로 나올 수 있다.

CoreDNS 등 일부 Add-on Pod는 NodeGroup 생성 전까지 Pending 또는 미스케줄 상태일 수 있다.

실제 Worker Node 생성과 On-Demand / Spot 분리는 M2-EKS-02에서 진행한다.

## 검증 명령

Terraform 검증은 다음 순서로 수행한다.

```bash
terraform -chdir=terraform/environments/dev fmt -check -recursive
terraform -chdir=terraform/environments/dev validate
```

기본 plan에서는 Dev EKS만 생성되어야 한다.

```bash
terraform -chdir=terraform/environments/dev plan \
  -out=/tmp/moment-dev-eks-cluster.tfplan \
  -var='dev_eks_public_access_cidrs=["<현재-public-ip>/32"]' \
  -no-color
```

Plan JSON에서 위험 변경과 범위 침범 리소스를 확인한다.

```bash
terraform -chdir=terraform/environments/dev show \
  -json /tmp/moment-dev-eks-cluster.tfplan \
  > /tmp/moment-dev-eks-cluster.plan.json
```

위험 변경 확인 기준은 다음과 같다.

```text
delete / replace 없음
aws_eks_node_group 없음
helm_release 없음
kubernetes workload 없음
aws_lb 계열 없음
```

## Apply 후 확인 명령

Apply 후에는 kubeconfig를 갱신한다.

```bash
aws eks update-kubeconfig \
  --region ap-northeast-3 \
  --name moment-dev-eks-cluster
```

Cluster와 Add-on 상태를 확인한다.

```bash
aws eks describe-cluster \
  --region ap-northeast-3 \
  --name moment-dev-eks-cluster \
  --query 'cluster.{name:name,status:status,version:version,endpoint:endpoint,oidc:identity.oidc.issuer}' \
  --output table

aws eks list-addons \
  --region ap-northeast-3 \
  --cluster-name moment-dev-eks-cluster \
  --output table
```

Kubernetes 접근 확인은 다음 명령으로 수행한다.

```bash
kubectl get nodes
kubectl get pods -A
```

단, M2-EKS-02 전에는 Managed NodeGroup이 없으므로 node 목록은 비어 있을 수 있다.
