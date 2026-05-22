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
  description = "Dev TGW subnet route table ID."
  value       = module.dev_vpc.dev_tgw_route_table_id
}
