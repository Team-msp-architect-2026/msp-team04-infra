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
# Centralized NAT Gateway, Transit Gateway Attachment Subnet을 배치한다.
# 모든 spoke VPC의 outbound 트래픽은 Transit Gateway → Network VPC NAT Gateway 경로로 처리한다.

module "network_vpc" {
  source = "../../modules/network-vpc"

  name_prefix        = "${local.name_prefix}-network"
  vpc_cidr           = var.network_vpc_cidr
  availability_zones = var.availability_zones
  enable_nat_gateway = var.enable_nat_gateway
  tags               = local.common_tags
}

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

module "ecr" {
  source = "../../modules/ecr"

  repositories         = var.ecr_repositories
  image_tag_mutability = var.ecr_image_tag_mutability
  scan_on_push         = var.ecr_scan_on_push
  encryption_type      = var.ecr_encryption_type
  tags                 = local.common_tags
}

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
resource "aws_ec2_transit_gateway" "this" {
  description = "MoMent dev transit gateway"

  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  auto_accept_shared_attachments  = "enable"

  dns_support      = "enable"
  vpn_ecmp_support = "enable"

  tags = {
    Name        = "moment-dev-tgw"
    Project     = "MoMent"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Issue       = "M2-NET-03"
  }
}

module "prod_app_vpc" {
  source = "../../modules/app-vpc"

  name_prefix = "moment-dev-prod-app"

  vpc_cidr = "10.10.0.0/16"

  availability_zones = [
    "ap-northeast-3a",
    "ap-northeast-3c"
  ]

  public_subnet_cidrs = [
    "10.10.0.0/24",
    "10.10.1.0/24"
  ]

  private_app_subnet_cidrs = [
    "10.10.10.0/24",
    "10.10.11.0/24"
  ]

  tgw_attachment_subnet_cidrs = [
    "10.10.100.0/28",
    "10.10.100.16/28"
  ]

  # TGW가 이미 있으면 여기에 실제 TGW ID 넣기
  transit_gateway_id = aws_ec2_transit_gateway.this.id

  # Prod Data VPC CIDR 예정값
  data_vpc_cidr = var.data_vpc_cidr

  eks_cluster_name = "moment-dev-eks"

  tags = {
    Project     = "MoMent"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Issue       = "M2-NET-03"
  }
}
# ── Prod Data VPC ──────────────────────────────────────────────────────────────
# RDS PostgreSQL, ElastiCache Redis, OpenSearch를 배치한다.
# Internet Gateway 없이 Transit Gateway를 통해 Prod App VPC에서만 접근한다.

module "prod_data_vpc" {
  source = "../../modules/data-vpc"

  name_prefix        = "${local.name_prefix}-prod-data"
  vpc_cidr           = var.prod_data_vpc_cidr
  availability_zones = var.availability_zones

  private_db_subnet_cidrs = [
    "10.20.10.0/24",
    "10.20.11.0/24"
  ]

  private_cache_subnet_cidrs = [
    "10.20.20.0/24",
    "10.20.21.0/24"
  ]

  private_search_subnet_cidrs = [
    "10.20.30.0/24",
    "10.20.31.0/24"
  ]

  tgw_attachment_subnet_cidrs = [
    "10.20.100.0/28",
    "10.20.100.16/28"
  ]

  transit_gateway_id = aws_ec2_transit_gateway.this.id
  app_vpc_cidr       = var.prod_app_vpc_cidr

  tags = merge(local.common_tags, {
    Issue = "M2-NET-04"
  })
}

# ── Dev App VPC ────────────────────────────────────────────────────────────────
# 개발 환경 애플리케이션 워크로드가 배치될 Dev App VPC를 구성한다.
# Public Subnet에는 Dev ALB를 배치할 수 있고, Private App Subnet에는 향후 Dev EKS Worker Node를 배치한다.

module "dev_app_vpc" {
  source = "../../modules/app-vpc"

  name_prefix        = "${local.name_prefix}-dev-app"
  vpc_cidr           = var.dev_app_vpc_cidr
  availability_zones = var.availability_zones

  public_subnet_cidrs = [
    "10.30.0.0/24",
    "10.30.1.0/24"
  ]

  private_app_subnet_cidrs = [
    "10.30.10.0/24",
    "10.30.11.0/24"
  ]

  tgw_attachment_subnet_cidrs = [
    "10.30.100.0/28",
    "10.30.100.16/28"
  ]

  transit_gateway_id = aws_ec2_transit_gateway.this.id
  data_vpc_cidr      = var.dev_data_vpc_cidr
  eks_cluster_name   = "moment-dev-eks"

  tags = merge(local.common_tags, {
    Issue = "M2-NET-05"
  })
}

# ── Dev Data VPC ───────────────────────────────────────────────────────────────
# 개발 환경의 RDS, Redis, OpenSearch 배치 후보 네트워크를 구성한다.
# Data VPC에는 Internet Gateway를 생성하지 않고, Dev App VPC에서 TGW를 통해서만 접근하도록 구성한다.

module "dev_data_vpc" {
  source = "../../modules/data-vpc"

  name_prefix        = "${local.name_prefix}-dev-data"
  vpc_cidr           = var.dev_data_vpc_cidr
  availability_zones = var.availability_zones

  private_db_subnet_cidrs = [
    "10.40.10.0/24",
    "10.40.11.0/24"
  ]

  private_cache_subnet_cidrs = [
    "10.40.20.0/24",
    "10.40.21.0/24"
  ]

  private_search_subnet_cidrs = [
    "10.40.30.0/24",
    "10.40.31.0/24"
  ]

  tgw_attachment_subnet_cidrs = [
    "10.40.100.0/28",
    "10.40.100.16/28"
  ]

  transit_gateway_id = aws_ec2_transit_gateway.this.id
  app_vpc_cidr       = var.dev_app_vpc_cidr

  tags = merge(local.common_tags, {
    Issue = "M2-NET-05"
  })
}
