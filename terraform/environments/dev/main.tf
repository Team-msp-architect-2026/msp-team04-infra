locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.env
    ManagedBy   = "terraform"
    Owner       = "team04"
  }
}

module "ecr" {
  source = "../../modules/ecr"

  repositories = {
    backend = {
      name        = "${var.project_name}-backend-api"
      description = "Backend API container image repository"
    }

    ai-service = {
      name        = "${var.project_name}-ai-service"
      description = "AI Service container image repository"
    }

    batch = {
      name        = "${var.project_name}-batch-job"
      description = "Batch Job container image repository"
    }
  }

  image_tag_mutability = "IMMUTABLE"
  scan_on_push         = true
  encryption_type      = "AES256"

  tags = local.common_tags
}

module "network_vpc" {
  source = "../../modules/network-vpc"

  project_name = var.project_name
  env          = var.env

  vpc_cidr = var.network_vpc_cidr

  availability_zones = [
    "${var.primary_region}a",
    "${var.primary_region}c"
  ]

  public_subnet_cidrs = [
    "10.0.0.0/24",
    "10.0.1.0/24"
  ]

  tgw_subnet_cidrs = [
    "10.0.100.0/28",
    "10.0.100.16/28"
  ]

  tags = local.common_tags
}

module "prod_vpc" {
  source = "../../modules/prod-vpc"

  project_name = var.project_name
  env          = "prod"

  vpc_cidr = var.prod_vpc_cidr

  availability_zones = [
    "${var.primary_region}a",
    "${var.primary_region}c"
  ]

  public_subnet_cidrs = [
    "10.10.0.0/24",
    "10.10.1.0/24"
  ]

  private_app_subnet_cidrs = [
    "10.10.10.0/24",
    "10.10.11.0/24"
  ]

  private_data_subnet_cidrs = [
    "10.10.20.0/24",
    "10.10.21.0/24"
  ]

  tgw_subnet_cidrs = [
    "10.10.100.0/28",
    "10.10.100.16/28"
  ]

  transit_gateway_id = null

  tags = local.common_tags
}

module "dev_vpc" {
  source = "../../modules/dev-vpc"

  project_name = var.project_name
  env          = "dev"

  vpc_cidr = var.dev_vpc_cidr

  availability_zones = [
    "${var.primary_region}a",
    "${var.primary_region}c"
  ]

  public_subnet_cidrs = [
    "10.20.0.0/24",
    "10.20.1.0/24"
  ]

  private_app_subnet_cidrs = [
    "10.20.10.0/24",
    "10.20.11.0/24"
  ]

  private_data_subnet_cidrs = [
    "10.20.20.0/24",
    "10.20.21.0/24"
  ]

  tgw_subnet_cidrs = [
    "10.20.100.0/28",
    "10.20.100.16/28"
  ]

  transit_gateway_id = null

  tags = local.common_tags
}

module "transit_gateway" {
  source = "../../modules/transit-gateway"

  project_name = var.project_name
  env          = var.env

  network_vpc_id                = module.network_vpc.network_vpc_id
  network_vpc_cidr              = module.network_vpc.network_vpc_cidr
  network_tgw_subnet_ids        = module.network_vpc.tgw_subnet_ids
  network_public_route_table_id = module.network_vpc.public_route_table_id

  prod_vpc_id                     = module.prod_vpc.prod_vpc_id
  prod_vpc_cidr                   = module.prod_vpc.prod_vpc_cidr
  prod_tgw_subnet_ids             = module.prod_vpc.prod_tgw_subnet_ids
  prod_private_app_route_table_id = module.prod_vpc.prod_private_app_route_table_id

  dev_vpc_id                     = module.dev_vpc.dev_vpc_id
  dev_vpc_cidr                   = module.dev_vpc.dev_vpc_cidr
  dev_tgw_subnet_ids             = module.dev_vpc.dev_tgw_subnet_ids
  dev_private_app_route_table_id = module.dev_vpc.dev_private_app_route_table_id

  tags = local.common_tags
}

module "prod_security_group" {
  source = "../../modules/security-group"

  name_prefix       = "moment-prod"
  environment       = "prod"
  vpc_id            = module.prod_vpc.prod_vpc_id
  create_service_sg = true
  create_openvpn_sg = false

  app_port          = var.app_port
  admin_cidr_blocks = var.admin_cidr_blocks

  common_tags = {
    Project = "MoMent"
  }
}

module "dev_security_group" {
  source = "../../modules/security-group"

  name_prefix       = "moment-dev"
  environment       = "dev"
  vpc_id            = module.dev_vpc.dev_vpc_id
  create_service_sg = true
  create_openvpn_sg = false

  app_port          = var.app_port
  admin_cidr_blocks = var.admin_cidr_blocks

  common_tags = {
    Project = "MoMent"
  }
}

module "network_security_group" {
  source = "../../modules/security-group"

  name_prefix       = "moment-network"
  environment       = "network"
  vpc_id            = module.network_vpc.network_vpc_id
  create_service_sg = false
  create_openvpn_sg = true
  admin_cidr_blocks = ["115.138.87.55/32"]

  common_tags = {
    Project = "MoMent"
  }
}


module "prod_vpc_endpoint" {
  count  = var.enable_prod_vpc_endpoints ? 1 : 0
  source = "../../modules/vpc-endpoint"

  name_prefix = "moment-prod"
  environment = "prod"

  vpc_id                      = module.prod_vpc.prod_vpc_id
  private_app_subnet_ids      = module.prod_vpc.prod_private_app_subnet_ids
  private_app_route_table_ids = [module.prod_vpc.prod_private_app_route_table_id]
  endpoint_security_group_id  = module.prod_security_group.vpc_endpoint_sg_id

  common_tags = {
    Project = "MoMent"
  }
}

module "dev_vpc_endpoint" {
  count  = var.enable_dev_vpc_endpoints ? 1 : 0
  source = "../../modules/vpc-endpoint"

  name_prefix = "moment-dev"
  environment = "dev"

  vpc_id                      = module.dev_vpc.dev_vpc_id
  private_app_subnet_ids      = module.dev_vpc.dev_private_app_subnet_ids
  private_app_route_table_ids = [module.dev_vpc.dev_private_app_route_table_id]
  endpoint_security_group_id  = module.dev_security_group.vpc_endpoint_sg_id

  common_tags = {
    Project = "MoMent"
  }
}

module "s3_raw_bucket" {
  source = "../../modules/s3"

  project_name = var.project_name
  environment  = var.env

  force_destroy = false

  raw_expiration_days       = 90
  processed_expiration_days = 180
  failed_expiration_days    = 30

  common_tags = local.common_tags
}

module "iam" {
  source = "../../modules/iam"

  project_name = var.project_name
  environment  = var.env

  github_repository = "Team-msp-architect-2026/msp-team04-infra"

  github_oidc_allowed_subjects = [
    "repo:Team-msp-architect-2026/msp-team04-infra:ref:refs/heads/develop"
  ]

  ecr_repository_arns          = module.ecr.repository_arns
  raw_bucket_access_policy_arn = module.s3_raw_bucket.raw_bucket_access_policy_arn

  create_github_oidc_provider = false
  github_oidc_provider_arn    = "arn:aws:iam::611058323802:oidc-provider/token.actions.githubusercontent.com"

  create_eks_oidc_provider = false
  enable_irsa_roles        = false

  common_tags = local.common_tags
}

module "dev_eks" {
  count = var.enable_dev_eks ? 1 : 0

  source = "../../modules/eks"

  project_name = var.project_name
  environment  = "dev"

  cluster_name       = var.dev_eks_cluster_name
  cluster_role_arn   = module.iam.role_arns.eks_cluster
  kubernetes_version = var.prod_eks_kubernetes_version

  subnet_ids                 = module.dev_vpc.dev_private_app_subnet_ids
  cluster_security_group_ids = []

  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs     = var.dev_eks_public_access_cidrs

  authentication_mode                         = "API"
  bootstrap_cluster_creator_admin_permissions = false
  cluster_admin_principal_arn                 = var.dev_eks_cluster_admin_principal_arn

  addons = {
    vpc-cni = {
      addon_version = "v1.21.1-eksbuild.1"
    }

    coredns = {
      addon_version = "v1.13.2-eksbuild.4"
    }

    kube-proxy = {
      addon_version = "v1.35.3-eksbuild.2"
    }

    aws-ebs-csi-driver = {
      addon_version = "v1.60.0-eksbuild.1"
    }
  }

  common_tags = merge(local.common_tags, {
    Environment = "dev"
  })
}

module "prod_eks" {
  count = var.enable_prod_eks ? 1 : 0

  source = "../../modules/eks"

  project_name = var.project_name
  environment  = "prod"

  cluster_name       = var.prod_eks_cluster_name
  cluster_role_arn   = module.iam.role_arns.eks_cluster
  kubernetes_version = var.prod_eks_kubernetes_version

  subnet_ids                 = module.prod_vpc.prod_private_app_subnet_ids
  cluster_security_group_ids = []

  endpoint_private_access = true
  endpoint_public_access  = true
  public_access_cidrs     = var.prod_eks_public_access_cidrs

  authentication_mode                         = "API"
  bootstrap_cluster_creator_admin_permissions = false
  cluster_admin_principal_arn                 = var.prod_eks_cluster_admin_principal_arn

  addons = {
    vpc-cni = {
      addon_version = "v1.21.1-eksbuild.1"
    }

    coredns = {
      addon_version = "v1.13.2-eksbuild.4"
    }

    kube-proxy = {
      addon_version = "v1.35.3-eksbuild.2"
    }

    aws-ebs-csi-driver = {
      addon_version = "v1.60.0-eksbuild.1"
    }
  }

  common_tags = merge(local.common_tags, {
    Environment = "prod"
  })
}
