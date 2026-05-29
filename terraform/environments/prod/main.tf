locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.env
    ManagedBy   = "terraform"
    Owner       = "team04"
  }

  prod_tags = merge(local.common_tags, {
    Environment = "prod"
  })
}

module "prod_ecr" {
  count  = var.enable_prod_ecr ? 1 : 0
  source = "../../modules/ecr"

  repositories = {
    backend = {
      name        = "${var.project_name}-prod-backend-api"
      description = "Prod Backend API container image repository"
    }

    ai-service = {
      name        = "${var.project_name}-prod-ai-service"
      description = "Prod AI Service container image repository"
    }

    batch = {
      name        = "${var.project_name}-prod-batch-job"
      description = "Prod Batch Job container image repository"
    }
  }

  image_tag_mutability = "IMMUTABLE"
  scan_on_push         = true
  encryption_type      = "AES256"

  tags = local.prod_tags
}

module "prod_vpc" {
  count  = var.enable_prod_vpc ? 1 : 0
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

  transit_gateway_id = var.prod_transit_gateway_id

  tags = local.prod_tags
}

module "prod_security_group" {
  count  = var.enable_prod_vpc ? 1 : 0
  source = "../../modules/security-group"

  name_prefix       = "moment-prod"
  environment       = "prod"
  vpc_id            = module.prod_vpc[0].prod_vpc_id
  create_service_sg = true
  create_openvpn_sg = false

  app_port          = var.app_port
  admin_cidr_blocks = var.admin_cidr_blocks

  common_tags = local.prod_tags
}

module "prod_vpc_endpoint" {
  count  = var.enable_prod_vpc && var.enable_prod_vpc_endpoints ? 1 : 0
  source = "../../modules/vpc-endpoint"

  name_prefix = "moment-prod"
  environment = "prod"

  vpc_id                      = module.prod_vpc[0].prod_vpc_id
  private_app_subnet_ids      = module.prod_vpc[0].prod_private_app_subnet_ids
  private_app_route_table_ids = [module.prod_vpc[0].prod_private_app_route_table_id]
  endpoint_security_group_id  = module.prod_security_group[0].vpc_endpoint_sg_id

  common_tags = local.prod_tags
}

module "prod_sqs" {
  count  = var.enable_prod_sqs ? 1 : 0
  source = "../../modules/sqs"

  project_name = var.project_name
  environment  = "prod"

  queue_name = "${var.project_name}-prod-public-data-queue"
  dlq_name   = "${var.project_name}-prod-public-data-dlq"

  visibility_timeout_seconds    = var.prod_sqs_visibility_timeout_seconds
  message_retention_seconds     = var.prod_sqs_message_retention_seconds
  dlq_message_retention_seconds = var.prod_sqs_dlq_message_retention_seconds
  max_receive_count             = var.prod_sqs_max_receive_count
  receive_wait_time_seconds     = var.prod_sqs_receive_wait_time_seconds
  delay_seconds                 = var.prod_sqs_delay_seconds
  max_message_size              = var.prod_sqs_max_message_size
  sqs_managed_sse_enabled       = var.prod_sqs_managed_sse_enabled

  common_tags = local.prod_tags
}

module "prod_s3_raw_bucket" {
  count = var.enable_prod_s3_raw_bucket ? 1 : 0

  source = "../../modules/s3"

  project_name = var.project_name
  environment  = "prod"
  bucket_name  = var.prod_raw_bucket_name

  common_tags = local.prod_tags
}


module "prod_iam" {
  count  = var.enable_prod_iam ? 1 : 0
  source = "../../modules/iam"

  project_name = var.project_name
  environment  = "prod"

  github_repository            = var.github_repository
  github_default_branch        = var.github_default_branch
  github_oidc_allowed_subjects = var.github_oidc_allowed_subjects

  create_github_oidc_provider = false
  github_oidc_provider_arn    = var.github_oidc_provider_arn

  create_eks_oidc_provider = false
  enable_irsa_roles        = false

  ecr_repository_arns = var.enable_prod_ecr ? module.prod_ecr[0].repository_arns : {}

  raw_bucket_access_policy_arns = var.enable_prod_s3_raw_bucket ? [
    module.prod_s3_raw_bucket[0].raw_bucket_access_policy_arn
  ] : []

  sqs_queue_arns                     = var.enable_prod_sqs ? [module.prod_sqs[0].queue_arn] : []
  enable_sqs_queue_policy_statements = var.enable_prod_sqs

  opensearch_domain_arns = var.enable_prod_opensearch ? [
    module.prod_opensearch[0].domain_arn,
    "${module.prod_opensearch[0].domain_arn}/*"
  ] : []

  attach_lambda_raw_bucket_policy              = var.enable_prod_s3_raw_bucket
  enable_lambda_collector_secrets_manager_read = var.enable_lambda_collector_secrets_manager_read

  common_tags = local.prod_tags

  depends_on = [
    module.prod_sqs,
    module.prod_s3_raw_bucket
  ]
}

module "prod_data_pipeline" {
  count = var.enable_prod_iam && var.enable_prod_data_pipeline && var.enable_prod_sqs && var.enable_prod_s3_raw_bucket ? 1 : 0

  source = "../../modules/data-pipeline"

  project_name = var.project_name
  environment  = "prod"

  lambda_function_name = "${var.project_name}-prod-public-data-collector"
  lambda_role_arn      = module.prod_iam[0].lambda_collector_role_arn

  raw_bucket_name                 = module.prod_s3_raw_bucket[0].raw_bucket_name
  queue_url                       = module.prod_sqs[0].queue_url
  public_data_api_url             = var.data_pipeline_public_data_api_url
  public_data_sources_json        = var.data_pipeline_public_data_sources_json
  public_data_sources_secret_name = var.data_pipeline_public_data_sources_secret_name

  schedule_expression = var.data_pipeline_schedule_expression
  schedule_state      = var.prod_data_pipeline_schedule_state

  lambda_runtime     = var.data_pipeline_lambda_runtime
  lambda_timeout     = var.data_pipeline_lambda_timeout
  lambda_memory_size = var.data_pipeline_lambda_memory_size
  log_retention_days = var.data_pipeline_log_retention_days

  common_tags = local.prod_tags

  depends_on = [
    module.prod_sqs,
    module.prod_s3_raw_bucket
  ]
}

module "prod_eks" {
  count  = var.enable_prod_iam && var.enable_prod_vpc && var.enable_prod_eks ? 1 : 0
  source = "../../modules/eks"

  project_name = var.project_name
  environment  = "prod"

  cluster_name       = var.prod_eks_cluster_name
  cluster_role_arn   = module.prod_iam[0].eks_cluster_role_arn
  kubernetes_version = var.prod_eks_kubernetes_version

  subnet_ids                 = module.prod_vpc[0].prod_private_app_subnet_ids
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

  common_tags = local.prod_tags
}

module "prod_redis" {
  count  = var.enable_prod_vpc && var.enable_prod_data_tier && var.enable_prod_redis ? 1 : 0
  source = "../../modules/redis"

  project_name = var.project_name
  environment  = "prod"

  replication_group_id = "${var.project_name}-prod-redis"
  description          = "MoMent Prod Redis for distributed lock and recommendation cache"

  subnet_ids         = module.prod_vpc[0].prod_private_data_subnet_ids
  security_group_ids = [module.prod_security_group[0].redis_sg_id]

  engine_version     = var.redis_engine_version
  node_type          = var.prod_redis_node_type
  num_cache_clusters = var.prod_redis_num_cache_clusters
  port               = 6379

  automatic_failover_enabled = var.prod_redis_automatic_failover_enabled
  multi_az_enabled           = var.prod_redis_multi_az_enabled
  snapshot_retention_limit   = var.prod_redis_snapshot_retention_limit

  common_tags = local.prod_tags
}

module "prod_rds" {
  count  = var.enable_prod_vpc && var.enable_prod_data_tier && var.enable_prod_rds ? 1 : 0
  source = "../../modules/rds"

  project_name = var.project_name
  environment  = "prod"

  identifier      = "${var.project_name}-prod-postgres"
  database_name   = var.rds_database_name
  master_username = var.rds_master_username

  subnet_ids         = module.prod_vpc[0].prod_private_data_subnet_ids
  security_group_ids = [module.prod_security_group[0].rds_sg_id]

  engine_version         = var.rds_engine_version
  parameter_group_family = var.rds_parameter_group_family
  instance_class         = var.prod_rds_instance_class

  allocated_storage     = var.prod_rds_allocated_storage
  max_allocated_storage = var.prod_rds_max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  multi_az                = var.prod_rds_multi_az
  backup_retention_period = var.prod_rds_backup_retention_period
  backup_window           = var.prod_rds_backup_window
  maintenance_window      = var.prod_rds_maintenance_window

  deletion_protection       = var.prod_rds_deletion_protection
  skip_final_snapshot       = var.prod_rds_skip_final_snapshot
  final_snapshot_identifier = coalesce(var.prod_rds_final_snapshot_identifier, "${var.project_name}-prod-postgres-final-snapshot")

  common_tags = local.prod_tags
}

module "prod_opensearch" {
  count  = var.enable_prod_vpc && var.enable_prod_data_tier && var.enable_prod_opensearch ? 1 : 0
  source = "../../modules/opensearch"

  project_name = var.project_name
  environment  = "prod"

  domain_name    = "${var.project_name}-prod-opensearch"
  engine_version = var.opensearch_engine_version

  instance_type  = var.prod_opensearch_instance_type
  instance_count = var.prod_opensearch_instance_count

  dedicated_master_enabled = var.prod_opensearch_dedicated_master_enabled
  dedicated_master_type    = var.prod_opensearch_dedicated_master_type
  dedicated_master_count   = var.prod_opensearch_dedicated_master_count

  zone_awareness_enabled        = var.prod_opensearch_zone_awareness_enabled
  availability_zone_count       = var.prod_opensearch_availability_zone_count
  multi_az_with_standby_enabled = var.prod_opensearch_multi_az_with_standby_enabled

  ebs_volume_type = var.opensearch_ebs_volume_type
  ebs_volume_size = var.prod_opensearch_ebs_volume_size

  subnet_ids         = module.prod_vpc[0].prod_private_data_subnet_ids
  security_group_ids = [module.prod_security_group[0].opensearch_sg_id]

  create_service_linked_role = var.create_opensearch_service_linked_role

  common_tags = local.prod_tags
}

module "prod_eks_nodegroups" {
  count  = var.enable_prod_iam && var.enable_prod_eks && var.enable_prod_nodegroups ? 1 : 0
  source = "../../modules/eks-nodegroup"

  project_name  = var.project_name
  environment   = "prod"
  cluster_name  = module.prod_eks[0].cluster_name
  node_role_arn = module.prod_iam[0].eks_node_role_arn
  subnet_ids    = module.prod_vpc[0].prod_private_app_subnet_ids

  node_groups = {
    core_on_demand = {
      name           = "${var.project_name}-prod-core-on-demand-ng"
      capacity_type  = "ON_DEMAND"
      instance_types = ["t3.medium"]
      min_size       = 2
      desired_size   = 2
      max_size       = 4
      disk_size      = 30
      labels = {
        workload = "core"
        capacity = "on-demand"
      }
      taints = []
    }

    batch_on_demand = {
      name           = "${var.project_name}-prod-batch-on-demand-ng"
      capacity_type  = "ON_DEMAND"
      instance_types = ["t3.medium"]
      min_size       = 0
      desired_size   = 1
      max_size       = 2
      disk_size      = 30
      labels = {
        workload = "batch"
        capacity = "on-demand"
      }
      taints = [{
        key    = "workload"
        value  = "batch"
        effect = "NO_SCHEDULE"
      }]
    }

    batch_spot = {
      name           = "${var.project_name}-prod-batch-spot-ng"
      capacity_type  = "SPOT"
      instance_types = ["t3.medium", "t3.large"]
      min_size       = 0
      desired_size   = 0
      max_size       = 3
      disk_size      = 30
      labels = {
        workload = "batch"
        capacity = "spot"
      }
      taints = [{
        key    = "spot"
        value  = "true"
        effect = "NO_SCHEDULE"
      }]
    }

    ai_spot = {
      name           = "${var.project_name}-prod-ai-spot-ng"
      capacity_type  = "SPOT"
      instance_types = ["t3.large", "t3.xlarge"]
      min_size       = 0
      desired_size   = 1
      max_size       = 3
      disk_size      = 30
      labels = {
        workload = "ai"
        capacity = "spot"
      }
      taints = [{
        key    = "spot"
        value  = "true"
        effect = "NO_SCHEDULE"
      }]
    }

    ops_on_demand = {
      name           = "${var.project_name}-prod-ops-on-demand-ng"
      capacity_type  = "ON_DEMAND"
      instance_types = ["t3.medium"]
      min_size       = 1
      desired_size   = 1
      max_size       = 2
      disk_size      = 30
      labels = {
        workload = "ops"
        capacity = "on-demand"
      }
      taints = []
    }
  }

  common_tags = local.prod_tags
}

module "edge" {
  count  = var.enable_edge ? 1 : 0
  source = "../../modules/edge"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  name_prefix = "moment-prod"

  domain_name                = var.edge_domain_name
  subject_alternative_names  = var.edge_subject_alternative_names
  create_route53_hosted_zone = var.create_route53_hosted_zone

  alb_dns_name      = var.prod_alb_dns_name
  alb_https_enabled = var.prod_alb_https_enabled

  price_class                    = var.cloudfront_price_class
  enable_waf                     = var.enable_waf
  cloudfront_secret_header_value = var.cloudfront_secret_header_value

  tags = local.prod_tags
}
