output "project_name" {
  description = "Project name"
  value       = var.project_name
}

output "env" {
  description = "Environment name"
  value       = var.env
}

output "primary_region" {
  description = "Primary AWS region"
  value       = var.primary_region
}

# ── ECR Outputs ───────────────────────────────────────────────────────────────

output "ecr_repository_names" {
  description = "ECR Repository names."
  value       = module.ecr.repository_names
}

output "ecr_repository_urls" {
  description = "ECR Repository URLs for GitHub Actions."
  value       = module.ecr.repository_urls
}

output "ecr_repository_arns" {
  description = "ECR Repository ARNs."
  value       = module.ecr.repository_arns
}

output "backend_repository_url" {
  description = "Backend API ECR Repository URL."
  value       = module.ecr.backend_repository_url
}

output "ai_service_repository_url" {
  description = "AI Service ECR Repository URL."
  value       = module.ecr.ai_service_repository_url
}

output "batch_repository_url" {
  description = "Batch Job ECR Repository URL."
  value       = module.ecr.batch_repository_url
}

# ── Network VPC Outputs ───────────────────────────────────────────────────────

output "network_vpc_id" {
  description = "Network VPC ID."
  value       = module.network_vpc.network_vpc_id
}

output "network_vpc_cidr" {
  description = "Network VPC CIDR block."
  value       = module.network_vpc.network_vpc_cidr
}

output "network_public_subnet_ids" {
  description = "Network VPC public subnet IDs."
  value       = module.network_vpc.public_subnet_ids
}

output "network_tgw_subnet_ids" {
  description = "Network VPC TGW attachment subnet IDs."
  value       = module.network_vpc.tgw_subnet_ids
}

output "network_nat_gateway_id" {
  description = "Network VPC centralized NAT Gateway ID."
  value       = module.network_vpc.nat_gateway_id
}

output "network_igw_id" {
  description = "Network VPC Internet Gateway ID."
  value       = module.network_vpc.igw_id
}

output "network_public_route_table_id" {
  description = "Network VPC public route table ID."
  value       = module.network_vpc.public_route_table_id
}

output "network_tgw_route_table_id" {
  description = "Network VPC TGW subnet route table ID."
  value       = module.network_vpc.tgw_route_table_id
}

# ── Prod VPC Outputs ──────────────────────────────────────────────────────────

output "prod_vpc_id" {
  description = "Prod VPC ID."
  value       = module.prod_vpc.prod_vpc_id
}

output "prod_vpc_cidr" {
  description = "Prod VPC CIDR block."
  value       = module.prod_vpc.prod_vpc_cidr
}

output "prod_public_subnet_ids" {
  description = "Prod public subnet IDs."
  value       = module.prod_vpc.prod_public_subnet_ids
}

output "prod_private_app_subnet_ids" {
  description = "Prod private app subnet IDs."
  value       = module.prod_vpc.prod_private_app_subnet_ids
}

output "prod_private_data_subnet_ids" {
  description = "Prod private data subnet IDs."
  value       = module.prod_vpc.prod_private_data_subnet_ids
}

output "prod_tgw_subnet_ids" {
  description = "Prod TGW attachment subnet IDs."
  value       = module.prod_vpc.prod_tgw_subnet_ids
}

output "prod_igw_id" {
  description = "Prod Internet Gateway ID."
  value       = module.prod_vpc.prod_igw_id
}

output "prod_public_route_table_id" {
  description = "Prod public route table ID."
  value       = module.prod_vpc.prod_public_route_table_id
}

output "prod_private_app_route_table_id" {
  description = "Prod private app route table ID."
  value       = module.prod_vpc.prod_private_app_route_table_id
}

output "prod_private_data_route_table_id" {
  description = "Prod private data route table ID."
  value       = module.prod_vpc.prod_private_data_route_table_id
}

output "prod_tgw_route_table_id" {
  description = "Prod VPC TGW subnet route table ID."
  value       = module.prod_vpc.prod_tgw_route_table_id
}

# ── Dev VPC Outputs ───────────────────────────────────────────────────────────

output "dev_vpc_id" {
  description = "Dev VPC ID."
  value       = module.dev_vpc.dev_vpc_id
}

output "dev_vpc_cidr" {
  description = "Dev VPC CIDR block."
  value       = module.dev_vpc.dev_vpc_cidr
}

output "dev_public_subnet_ids" {
  description = "Dev public subnet IDs."
  value       = module.dev_vpc.dev_public_subnet_ids
}

output "dev_private_app_subnet_ids" {
  description = "Dev private app subnet IDs."
  value       = module.dev_vpc.dev_private_app_subnet_ids
}

output "dev_private_data_subnet_ids" {
  description = "Dev private data subnet IDs."
  value       = module.dev_vpc.dev_private_data_subnet_ids
}

output "dev_reserved_data_subnet_ids" {
  description = "Dev reserved data subnet IDs."
  value       = module.dev_vpc.dev_reserved_data_subnet_ids
}

output "dev_tgw_subnet_ids" {
  description = "Dev TGW attachment subnet IDs."
  value       = module.dev_vpc.dev_tgw_subnet_ids
}

output "dev_igw_id" {
  description = "Dev Internet Gateway ID."
  value       = module.dev_vpc.dev_igw_id
}

output "dev_public_route_table_id" {
  description = "Dev public route table ID."
  value       = module.dev_vpc.dev_public_route_table_id
}

output "dev_private_app_route_table_id" {
  description = "Dev private app route table ID."
  value       = module.dev_vpc.dev_private_app_route_table_id
}

output "dev_private_data_route_table_id" {
  description = "Dev private data route table ID."
  value       = module.dev_vpc.dev_private_data_route_table_id
}

output "dev_tgw_route_table_id" {
  description = "Dev VPC TGW subnet route table ID."
  value       = module.dev_vpc.dev_tgw_route_table_id
}

# ── Transit Gateway Outputs ───────────────────────────────────────────────────

output "transit_gateway_id" {
  description = "Transit Gateway ID."
  value       = module.transit_gateway.transit_gateway_id
}

output "network_tgw_attachment_id" {
  description = "Network VPC TGW attachment ID."
  value       = module.transit_gateway.network_tgw_attachment_id
}

output "prod_tgw_attachment_id" {
  description = "Prod VPC TGW attachment ID."
  value       = module.transit_gateway.prod_tgw_attachment_id
}

output "dev_tgw_attachment_id" {
  description = "Dev VPC TGW attachment ID."
  value       = module.transit_gateway.dev_tgw_attachment_id
}

output "tgw_network_route_table_id" {
  description = "Network TGW route table ID."
  value       = module.transit_gateway.network_tgw_route_table_id
}

output "tgw_prod_route_table_id" {
  description = "Prod TGW route table ID."
  value       = module.transit_gateway.prod_tgw_route_table_id
}

output "tgw_dev_route_table_id" {
  description = "Dev TGW route table ID."
  value       = module.transit_gateway.dev_tgw_route_table_id
}

output "tgw_attachment_ids" {
  description = "Transit Gateway attachment IDs by VPC role."
  value       = module.transit_gateway.tgw_attachment_ids
}

output "tgw_route_table_ids" {
  description = "Transit Gateway route table IDs by routing domain."
  value       = module.transit_gateway.tgw_route_table_ids
}

output "prod_security_group_ids" {
  description = "Prod security group IDs"
  value       = module.prod_security_group.service_security_group_ids
}

output "dev_security_group_ids" {
  description = "Dev security group IDs"
  value       = module.dev_security_group.service_security_group_ids
}

output "network_openvpn_sg_id" {
  description = "Network OpenVPN security group ID"
  value       = module.network_security_group.openvpn_sg_id
}



output "network_openvpn_instance_id" {
  description = "Network OpenVPN EC2 instance ID."
  value       = try(module.network_openvpn[0].instance_id, null)
}

output "network_openvpn_private_ip" {
  description = "Network OpenVPN private IP."
  value       = try(module.network_openvpn[0].private_ip, null)
}

output "network_openvpn_public_ip" {
  description = "Network OpenVPN public IP."
  value       = try(module.network_openvpn[0].public_ip, null)
}

output "network_openvpn_public_dns" {
  description = "Network OpenVPN public DNS."
  value       = try(module.network_openvpn[0].public_dns, null)
}

output "network_openvpn_client_config_path" {
  description = "Generated OpenVPN client profile path on the instance."
  value       = try(module.network_openvpn[0].client_config_path, null)
}


output "network_openvpn_client_profile_secret_name" {
  description = "Secrets Manager secret name for generated OpenVPN client profile."
  value       = try(module.network_openvpn[0].client_profile_secret_name, null)
}

output "network_openvpn_client_profile_secret_arn" {
  description = "Secrets Manager secret ARN for generated OpenVPN client profile."
  value       = try(module.network_openvpn[0].client_profile_secret_arn, null)
}

output "prod_s3_gateway_endpoint_id" {
  description = "Prod S3 Gateway Endpoint ID"
  value       = try(module.prod_vpc_endpoint[0].s3_gateway_endpoint_id, null)
}

output "prod_interface_endpoint_ids" {
  description = "Prod Interface Endpoint IDs"
  value       = try(module.prod_vpc_endpoint[0].interface_endpoint_ids, {})
}

output "dev_s3_gateway_endpoint_id" {
  description = "Dev S3 Gateway Endpoint ID"
  value       = try(module.dev_vpc_endpoint[0].s3_gateway_endpoint_id, null)
}

output "dev_interface_endpoint_ids" {
  description = "Dev Interface Endpoint IDs"
  value       = try(module.dev_vpc_endpoint[0].interface_endpoint_ids, {})
}

<<<<<<< Updated upstream

output "raw_bucket_name" {
  description = "Raw data S3 bucket name"
  value       = module.s3_raw_bucket.raw_bucket_name
}

output "raw_bucket_arn" {
  description = "Raw data S3 bucket ARN"
  value       = module.s3_raw_bucket.raw_bucket_arn
}

output "raw_bucket_access_policy_arn" {
  description = "IAM policy ARN for Batch and Collector raw bucket access"
  value       = module.s3_raw_bucket.raw_bucket_access_policy_arn
<<<<<<< Updated upstream
}


# ── SQS Outputs ───────────────────────────────────────────────────────────────

output "dev_sqs_queue_name" {
  description = "Dev SQS main queue name."
  value       = var.enable_dev_sqs ? module.dev_sqs[0].queue_name : null
}

output "dev_sqs_queue_url" {
  description = "Dev SQS main queue URL."
  value       = var.enable_dev_sqs ? module.dev_sqs[0].queue_url : null
}

output "dev_sqs_queue_arn" {
  description = "Dev SQS main queue ARN."
  value       = var.enable_dev_sqs ? module.dev_sqs[0].queue_arn : null
}

output "dev_sqs_dlq_name" {
  description = "Dev SQS dead-letter queue name."
  value       = var.enable_dev_sqs ? module.dev_sqs[0].dlq_name : null
}

output "dev_sqs_dlq_url" {
  description = "Dev SQS dead-letter queue URL."
  value       = var.enable_dev_sqs ? module.dev_sqs[0].dlq_url : null
}

output "dev_sqs_dlq_arn" {
  description = "Dev SQS dead-letter queue ARN."
  value       = var.enable_dev_sqs ? module.dev_sqs[0].dlq_arn : null
}

output "prod_sqs_queue_name" {
  description = "Prod SQS main queue name."
  value       = var.enable_prod_sqs ? module.prod_sqs[0].queue_name : null
}

output "prod_sqs_queue_url" {
  description = "Prod SQS main queue URL."
  value       = var.enable_prod_sqs ? module.prod_sqs[0].queue_url : null
}

output "prod_sqs_queue_arn" {
  description = "Prod SQS main queue ARN."
  value       = var.enable_prod_sqs ? module.prod_sqs[0].queue_arn : null
}

output "prod_sqs_dlq_name" {
  description = "Prod SQS dead-letter queue name."
  value       = var.enable_prod_sqs ? module.prod_sqs[0].dlq_name : null
}

output "prod_sqs_dlq_url" {
  description = "Prod SQS dead-letter queue URL."
  value       = var.enable_prod_sqs ? module.prod_sqs[0].dlq_url : null
}

output "prod_sqs_dlq_arn" {
  description = "Prod SQS dead-letter queue ARN."
  value       = var.enable_prod_sqs ? module.prod_sqs[0].dlq_arn : null
}

# ── IAM / OIDC / IRSA Outputs ─────────────────────────────────────────────────

output "iam_github_oidc_provider_arn" {
  description = "GitHub Actions OIDC Provider ARN"
  value       = module.iam.github_oidc_provider_arn
}

output "iam_eks_oidc_provider_arn" {
  description = "EKS OIDC Provider ARN when configured"
  value       = module.iam.eks_oidc_provider_arn
}

output "iam_role_arns" {
  description = "IAM role ARNs"
  value       = module.iam.role_arns
}

output "iam_policy_arns" {
  description = "IAM policy ARNs"
  value       = module.iam.policy_arns
}

output "iam_irsa_enabled" {
  description = "Whether IRSA roles are currently enabled"
  value       = module.iam.irsa_enabled
}

output "iam_service_account_annotations" {
  description = "Kubernetes ServiceAccount annotations for IRSA"
  value       = module.iam.service_account_annotations
}

# ── Dev EKS Outputs ───────────────────────────────────────────────────────────

output "dev_eks_enabled" {
  description = "Whether Dev EKS cluster creation is enabled"
  value       = var.enable_dev_eks
}

output "dev_eks_cluster_name" {
  description = "Dev EKS cluster name"
  value       = try(module.dev_eks[0].cluster_name, null)
}

output "dev_eks_cluster_arn" {
  description = "Dev EKS cluster ARN"
  value       = try(module.dev_eks[0].cluster_arn, null)
}

output "dev_eks_cluster_endpoint" {
  description = "Dev EKS cluster API endpoint"
  value       = try(module.dev_eks[0].cluster_endpoint, null)
}

output "dev_eks_cluster_ca_certificate" {
  description = "Dev EKS cluster certificate authority data"
  value       = try(module.dev_eks[0].cluster_certificate_authority_data, null)
}

output "dev_eks_cluster_version" {
  description = "Dev EKS Kubernetes version"
  value       = try(module.dev_eks[0].cluster_version, null)
}

output "dev_eks_cluster_status" {
  description = "Dev EKS cluster status"
  value       = try(module.dev_eks[0].cluster_status, null)
}

output "dev_eks_cluster_security_group_id" {
  description = "Dev EKS cluster security group ID"
  value       = try(module.dev_eks[0].cluster_security_group_id, null)
}

output "dev_eks_oidc_issuer_url" {
  description = "Dev EKS OIDC issuer URL"
  value       = try(module.dev_eks[0].cluster_oidc_issuer_url, null)
}

output "dev_eks_oidc_provider_arn" {
  description = "Dev EKS IAM OIDC Provider ARN"
  value       = try(module.dev_eks[0].eks_oidc_provider_arn, null)
}

output "dev_eks_addon_versions" {
  description = "Dev EKS managed add-on versions"
  value       = try(module.dev_eks[0].addon_versions, {})
}

output "dev_eks_ebs_csi_irsa_role_arn" {
  description = "Dev EKS EBS CSI IRSA role ARN"
  value       = try(module.dev_eks[0].ebs_csi_irsa_role_arn, null)
}

# ── Prod EKS Outputs ──────────────────────────────────────────────────────────

output "prod_eks_enabled" {
  description = "Whether Prod EKS cluster creation is enabled"
  value       = var.enable_prod_eks
}

output "prod_eks_cluster_name" {
  description = "Prod EKS cluster name"
  value       = try(module.prod_eks[0].cluster_name, null)
}

output "prod_eks_cluster_arn" {
  description = "Prod EKS cluster ARN"
  value       = try(module.prod_eks[0].cluster_arn, null)
}

output "prod_eks_cluster_endpoint" {
  description = "Prod EKS cluster API endpoint"
  value       = try(module.prod_eks[0].cluster_endpoint, null)
}

output "prod_eks_cluster_ca_certificate" {
  description = "Prod EKS cluster certificate authority data"
  value       = try(module.prod_eks[0].cluster_certificate_authority_data, null)
}

output "prod_eks_cluster_version" {
  description = "Prod EKS Kubernetes version"
  value       = try(module.prod_eks[0].cluster_version, null)
}

output "prod_eks_cluster_status" {
  description = "Prod EKS cluster status"
  value       = try(module.prod_eks[0].cluster_status, null)
}

output "prod_eks_cluster_security_group_id" {
  description = "Prod EKS cluster security group ID"
  value       = try(module.prod_eks[0].cluster_security_group_id, null)
}

output "prod_eks_oidc_issuer_url" {
  description = "Prod EKS OIDC issuer URL"
  value       = try(module.prod_eks[0].cluster_oidc_issuer_url, null)
}

output "prod_eks_oidc_provider_arn" {
  description = "Prod EKS IAM OIDC Provider ARN"
  value       = try(module.prod_eks[0].eks_oidc_provider_arn, null)
}

output "prod_eks_addon_versions" {
  description = "Prod EKS managed add-on versions"
  value       = try(module.prod_eks[0].addon_versions, {})
}

output "prod_eks_ebs_csi_irsa_role_arn" {
  description = "Prod EKS EBS CSI IRSA role ARN"
  value       = try(module.prod_eks[0].ebs_csi_irsa_role_arn, null)
}

# ── Dev EKS NodeGroup Outputs ─────────────────────────────────────────────────

output "dev_eks_node_group_names" {
  description = "Dev EKS managed node group names."
  value       = var.enable_dev_eks && var.enable_dev_nodegroups ? module.dev_eks_nodegroups[0].node_group_names : {}
}

output "dev_eks_node_group_arns" {
  description = "Dev EKS managed node group ARNs."
  value       = var.enable_dev_eks && var.enable_dev_nodegroups ? module.dev_eks_nodegroups[0].node_group_arns : {}
}

output "dev_eks_node_group_statuses" {
  description = "Dev EKS managed node group statuses."
  value       = var.enable_dev_eks && var.enable_dev_nodegroups ? module.dev_eks_nodegroups[0].node_group_statuses : {}
}

output "eks_node_group_role_arn" {
  description = "IAM role ARN used by EKS managed node groups."
  value       = module.iam.role_arns.eks_node
}


# ── Data Pipeline Outputs ─────────────────────────────────────────────────────

output "dev_data_pipeline_enabled" {
  description = "Whether Dev data pipeline resources are enabled."
  value       = var.enable_dev_data_pipeline && var.enable_dev_sqs
}

output "dev_data_pipeline_lambda_function_name" {
  description = "Dev Lambda Collector function name."
  value       = var.enable_dev_data_pipeline && var.enable_dev_sqs ? module.dev_data_pipeline[0].lambda_function_name : null
}

output "dev_data_pipeline_lambda_function_arn" {
  description = "Dev Lambda Collector function ARN."
  value       = var.enable_dev_data_pipeline && var.enable_dev_sqs ? module.dev_data_pipeline[0].lambda_function_arn : null
}

output "dev_data_pipeline_scheduler_schedule_group_name" {
  description = "Dev EventBridge Scheduler schedule group name."
  value       = var.enable_dev_data_pipeline && var.enable_dev_sqs ? module.dev_data_pipeline[0].scheduler_schedule_group_name : null
}

output "dev_data_pipeline_scheduler_schedule_name" {
  description = "Dev EventBridge Scheduler schedule name."
  value       = var.enable_dev_data_pipeline && var.enable_dev_sqs ? module.dev_data_pipeline[0].scheduler_schedule_name : null
}

output "dev_data_pipeline_scheduler_schedule_arn" {
  description = "Dev EventBridge Scheduler schedule ARN."
  value       = var.enable_dev_data_pipeline && var.enable_dev_sqs ? module.dev_data_pipeline[0].scheduler_schedule_arn : null
}

output "prod_data_pipeline_enabled" {
  description = "Whether Prod data pipeline resources are enabled."
  value       = var.enable_prod_data_pipeline && var.enable_prod_sqs
}

output "prod_data_pipeline_lambda_function_name" {
  description = "Prod Lambda Collector function name."
  value       = var.enable_prod_data_pipeline && var.enable_prod_sqs ? module.prod_data_pipeline[0].lambda_function_name : null
}

output "prod_data_pipeline_lambda_function_arn" {
  description = "Prod Lambda Collector function ARN."
  value       = var.enable_prod_data_pipeline && var.enable_prod_sqs ? module.prod_data_pipeline[0].lambda_function_arn : null
}

output "prod_data_pipeline_scheduler_schedule_group_name" {
  description = "Prod EventBridge Scheduler schedule group name."
  value       = var.enable_prod_data_pipeline && var.enable_prod_sqs ? module.prod_data_pipeline[0].scheduler_schedule_group_name : null
}

output "prod_data_pipeline_scheduler_schedule_name" {
  description = "Prod EventBridge Scheduler schedule name."
  value       = var.enable_prod_data_pipeline && var.enable_prod_sqs ? module.prod_data_pipeline[0].scheduler_schedule_name : null
}

output "prod_data_pipeline_scheduler_schedule_arn" {
  description = "Prod EventBridge Scheduler schedule ARN."
  value       = var.enable_prod_data_pipeline && var.enable_prod_sqs ? module.prod_data_pipeline[0].scheduler_schedule_arn : null
}

# ── Redis Outputs ─────────────────────────────────────────────────────────────

output "dev_redis_endpoint" {
  description = "Dev Redis primary endpoint."
  value       = var.enable_dev_redis ? module.dev_redis[0].redis_primary_endpoint : null
}

output "dev_redis_port" {
  description = "Dev Redis port."
  value       = var.enable_dev_redis ? module.dev_redis[0].redis_port : null
}

output "dev_redis_subnet_group_name" {
  description = "Dev Redis subnet group name."
  value       = var.enable_dev_redis ? module.dev_redis[0].redis_subnet_group_name : null
}

output "prod_redis_endpoint" {
  description = "Prod Redis primary endpoint."
  value       = var.enable_prod_redis ? module.prod_redis[0].redis_primary_endpoint : null
}

output "prod_redis_port" {
  description = "Prod Redis port."
  value       = var.enable_prod_redis ? module.prod_redis[0].redis_port : null
}

# ── RDS Outputs ───────────────────────────────────────────────────────────────

output "dev_rds_endpoint" {
  description = "Dev RDS PostgreSQL endpoint."
  value       = var.enable_dev_rds ? module.dev_rds[0].db_endpoint : null
}

output "dev_rds_port" {
  description = "Dev RDS PostgreSQL port."
  value       = var.enable_dev_rds ? module.dev_rds[0].db_port : null
}

output "dev_rds_database_name" {
  description = "Dev RDS initial database name."
  value       = var.enable_dev_rds ? module.dev_rds[0].db_name : null
}

output "dev_rds_subnet_group_name" {
  description = "Dev RDS subnet group name."
  value       = var.enable_dev_rds ? module.dev_rds[0].db_subnet_group_name : null
}

output "dev_rds_master_user_secret_arn" {
  description = "Dev RDS master user password secret ARN managed by RDS."
  value       = var.enable_dev_rds ? module.dev_rds[0].master_user_secret_arn : null
  sensitive   = true
}

output "prod_rds_endpoint" {
  description = "Prod RDS PostgreSQL endpoint."
  value       = var.enable_prod_rds ? module.prod_rds[0].db_endpoint : null
}

output "prod_rds_port" {
  description = "Prod RDS PostgreSQL port."
  value       = var.enable_prod_rds ? module.prod_rds[0].db_port : null
}

output "prod_rds_database_name" {
  description = "Prod RDS initial database name."
  value       = var.enable_prod_rds ? module.prod_rds[0].db_name : null
}

output "prod_rds_subnet_group_name" {
  description = "Prod RDS subnet group name."
  value       = var.enable_prod_rds ? module.prod_rds[0].db_subnet_group_name : null
}

output "prod_rds_master_user_secret_arn" {
  description = "Prod RDS master user password secret ARN managed by RDS."
  value       = var.enable_prod_rds ? module.prod_rds[0].master_user_secret_arn : null
  sensitive   = true
}

# ── OpenSearch Outputs ────────────────────────────────────────────────────────

output "dev_opensearch_domain_name" {
  description = "Dev OpenSearch domain name."
  value       = var.enable_dev_opensearch ? module.dev_opensearch[0].domain_name : null
}

output "dev_opensearch_domain_arn" {
  description = "Dev OpenSearch domain ARN."
  value       = var.enable_dev_opensearch ? module.dev_opensearch[0].domain_arn : null
}

output "dev_opensearch_endpoint" {
  description = "Dev OpenSearch VPC endpoint."
  value       = var.enable_dev_opensearch ? module.dev_opensearch[0].endpoint : null
}

output "dev_opensearch_dashboard_endpoint" {
  description = "Dev OpenSearch Dashboards endpoint."
  value       = var.enable_dev_opensearch ? module.dev_opensearch[0].dashboard_endpoint : null
}

output "prod_opensearch_domain_name" {
  description = "Prod OpenSearch domain name."
  value       = var.enable_prod_opensearch ? module.prod_opensearch[0].domain_name : null
}

output "prod_opensearch_domain_arn" {
  description = "Prod OpenSearch domain ARN."
  value       = var.enable_prod_opensearch ? module.prod_opensearch[0].domain_arn : null
}

output "prod_opensearch_endpoint" {
  description = "Prod OpenSearch VPC endpoint."
  value       = var.enable_prod_opensearch ? module.prod_opensearch[0].endpoint : null
}

# ─── Edge Layer ──────────────────────────────────────────────────────────────
output "cloudfront_domain_name" {
  description = "CloudFront 도메인명"
  value       = var.enable_edge ? module.edge[0].cloudfront_domain_name : null
}

output "cloudfront_distribution_id" {
  description = "CloudFront 배포 ID"
  value       = var.enable_edge ? module.edge[0].cloudfront_distribution_id : null
}

output "waf_web_acl_id" {
  description = "WAF Web ACL ID"
  value       = var.enable_edge ? module.edge[0].waf_web_acl_id : null
}

output "waf_web_acl_arn" {
  description = "WAF Web ACL ARN"
  value       = var.enable_edge ? module.edge[0].waf_web_acl_arn : null
}

output "acm_certificate_arn" {
  description = "CloudFront용 ACM 인증서 ARN (us-east-1)"
  value       = var.enable_edge ? module.edge[0].acm_certificate_arn : null
}