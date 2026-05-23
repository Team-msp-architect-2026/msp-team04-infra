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
