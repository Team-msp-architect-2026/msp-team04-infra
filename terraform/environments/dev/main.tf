# ── Locals ────────────────────────────────────────────────────────────────────
# 리소스 네이밍과 태그에 공통으로 사용하는 값을 locals로 정의한다.
# 형식: {project_name}-{env}-{resource}

locals {
  name_prefix = "${var.project_name}-${var.env}"

  common_tags = {
    Project     = var.project_name
    Environment = var.env
    ManagedBy   = "Terraform"
  }
}

# ── Network VPC ────────────────────────────────────────────────────────────────
# Centralized NAT Gateway, Transit Gateway Attachment, optional Bastion/VPN을 배치한다.
# 모든 spoke VPC의 outbound 트래픽은 Transit Gateway → Network VPC NAT Gateway 경로로 처리한다.
#
# module "network_vpc" {
#   source = "../../modules/network-vpc"
#
#   name_prefix        = local.name_prefix
#   vpc_cidr           = var.network_vpc_cidr
#   availability_zones = var.availability_zones
#   tags               = local.common_tags
# }

# ── Transit Gateway ────────────────────────────────────────────────────────────
# prod / dev / egress TGW Route Table을 각각 생성하여 트래픽 경로를 분리한다.
#
# module "transit_gateway" {
#   source = "../../modules/transit-gateway"
#
#   name_prefix = local.name_prefix
#   tags        = local.common_tags
# }

# ── Dev App VPC ────────────────────────────────────────────────────────────────
# Dev ALB (Public Subnet), Dev EKS Worker Node (Private App Subnet)을 배치한다.
#
# module "dev_app_vpc" {
#   source = "../../modules/app-vpc"
#
#   name_prefix        = "${local.name_prefix}-app"
#   vpc_cidr           = var.dev_app_vpc_cidr
#   availability_zones = var.availability_zones
#   tags               = local.common_tags
# }

# ── Dev Data VPC ───────────────────────────────────────────────────────────────
# Dev RDS, Dev Redis/Valkey, Dev OpenSearch를 배치한다.
# Internet Gateway 없이 Transit Gateway를 통해서만 App VPC에서 접근한다.
#
# module "dev_data_vpc" {
#   source = "../../modules/data-vpc"
#
#   name_prefix        = "${local.name_prefix}-data"
#   vpc_cidr           = var.dev_data_vpc_cidr
#   availability_zones = var.availability_zones
#   tags               = local.common_tags
# }

# ── Dev EKS ────────────────────────────────────────────────────────────────────
# Control Plane: AWS Managed
# Data Plane: Dev App VPC Private App Subnet (Managed Node Group, AZ-A / AZ-C)
#
# module "dev_eks" {
#   source = "../../modules/eks"
#
#   name_prefix            = "${local.name_prefix}-eks"
#   cluster_version        = var.eks_cluster_version
#   node_instance_type     = var.eks_node_instance_type
#   node_desired_size      = var.eks_node_desired_size
#   node_min_size          = var.eks_node_min_size
#   node_max_size          = var.eks_node_max_size
#   tags                   = local.common_tags
# }

# ── Dev RDS PostgreSQL ─────────────────────────────────────────────────────────
#
# module "dev_rds" {
#   source = "../../modules/rds"
#
#   name_prefix    = "${local.name_prefix}-rds"
#   instance_class = var.rds_instance_class
#   db_name        = var.rds_db_name
#   username       = var.rds_username
#   password       = var.rds_password
#   tags           = local.common_tags
# }

# ── Dev ElastiCache Redis/Valkey ───────────────────────────────────────────────
#
# module "dev_redis" {
#   source = "../../modules/redis"
#
#   name_prefix = "${local.name_prefix}-redis"
#   node_type   = var.redis_node_type
#   tags        = local.common_tags
# }

# ── Dev OpenSearch ─────────────────────────────────────────────────────────────
# 데모: 2-AZ, 운영: 3-AZ Multi-AZ with Standby
#
# module "dev_opensearch" {
#   source = "../../modules/opensearch"
#
#   name_prefix     = "${local.name_prefix}-search"
#   instance_type   = var.opensearch_instance_type
#   instance_count  = var.opensearch_instance_count
#   tags            = local.common_tags
# }

# ── ECR ────────────────────────────────────────────────────────────────────────
# Backend API / AI Service / Batch Job 이미지 리포지토리를 ap-northeast-3에 생성한다.
#
# module "ecr" {
#   source = "../../modules/ecr"
#
#   name_prefix = local.name_prefix
#   tags        = local.common_tags
# }

# ── ACM (us-east-1) ────────────────────────────────────────────────────────────
# CloudFront viewer HTTPS용 ACM 인증서는 반드시 us-east-1에 생성해야 한다.
# provider alias "use1"을 사용한다.
#
# module "acm_cloudfront" {
#   source = "../../modules/acm-cloudfront"
#
#   providers = {
#     aws = aws.use1
#   }
#
#   domain_name = "moment.com"
#   tags        = local.common_tags
# }
