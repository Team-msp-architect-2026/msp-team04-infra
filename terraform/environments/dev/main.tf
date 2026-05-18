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

# ── Transit Gateway Routing / Network Attachment ──────────────────────────────
# M2-NET-02에서는 기존 Transit Gateway 본체를 삭제하거나 새로 만들지 않는다.
# 이미 생성된 aws_ec2_transit_gateway.this를 기준으로 Network VPC Attachment와
# 중앙 NAT egress 경로를 명시적으로 추가한다.

resource "aws_ec2_transit_gateway_vpc_attachment" "network" {
  subnet_ids         = module.network_vpc.tgw_attachment_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = module.network_vpc.network_vpc_id

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = merge(local.common_tags, {
    Name  = "${local.name_prefix}-network-tgw-attachment"
    Issue = "M2-NET-02"
  })
}

# prod / dev / egress TGW Route Table은 향후 명시적 라우팅 분리를 위한 구조다.
# 기존 App/Data attachment association은 이번 단계에서 변경하지 않아 통신 중단 위험을 줄인다.

resource "aws_ec2_transit_gateway_route_table" "prod" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id

  tags = merge(local.common_tags, {
    Name  = "${local.name_prefix}-tgw-rt-prod"
    Issue = "M2-NET-02"
  })
}

resource "aws_ec2_transit_gateway_route_table" "dev" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id

  tags = merge(local.common_tags, {
    Name  = "${local.name_prefix}-tgw-rt-dev"
    Issue = "M2-NET-02"
  })
}

resource "aws_ec2_transit_gateway_route_table" "egress" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id

  tags = merge(local.common_tags, {
    Name  = "${local.name_prefix}-tgw-rt-egress"
    Issue = "M2-NET-02"
  })
}

# Network VPC Attachment는 egress route table에만 명시적으로 association한다.
# Network VPC에서 App VPC로 돌아가는 return route는 egress RT에서 App CIDR propagation으로 처리한다.

resource "aws_ec2_transit_gateway_route_table_association" "network_egress" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.network.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.egress.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "egress_prod_app" {
  transit_gateway_attachment_id  = module.prod_app_vpc.tgw_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.egress.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "egress_dev_app" {
  transit_gateway_attachment_id  = module.dev_app_vpc.tgw_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.egress.id
}

# prod/dev route table은 App/Data CIDR propagation과 egress static route를 준비한다.
# 단, 기존 App/Data attachment association은 아직 default TGW RT에 유지한다.

resource "aws_ec2_transit_gateway_route_table_propagation" "prod_app" {
  transit_gateway_attachment_id  = module.prod_app_vpc.tgw_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.prod.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "prod_data" {
  transit_gateway_attachment_id  = module.prod_data_vpc.tgw_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.prod.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "dev_app" {
  transit_gateway_attachment_id  = module.dev_app_vpc.tgw_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.dev.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "dev_data" {
  transit_gateway_attachment_id  = module.dev_data_vpc.tgw_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.dev.id
}

resource "aws_ec2_transit_gateway_route" "default_to_network" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.network.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.this.association_default_route_table_id
}

resource "aws_ec2_transit_gateway_route" "prod_default_to_network" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.network.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.prod.id
}

resource "aws_ec2_transit_gateway_route" "dev_default_to_network" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.network.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.dev.id
}

# 중앙 NAT Gateway가 있는 Network VPC public subnet route table에
# App VPC CIDR로 돌아가는 return route를 추가한다.

resource "aws_route" "network_public_to_prod_app_tgw" {
  route_table_id         = module.network_vpc.public_route_table_id
  destination_cidr_block = var.prod_app_vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.this.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.network]
}

resource "aws_route" "network_public_to_dev_app_tgw" {
  route_table_id         = module.network_vpc.public_route_table_id
  destination_cidr_block = var.dev_app_vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.this.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.network]
}
