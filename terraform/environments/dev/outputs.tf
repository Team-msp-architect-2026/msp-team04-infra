# ── 공통 ──────────────────────────────────────────────────────────────────────

output "project_name" {
  description = "프로젝트 이름"
  value       = var.project_name
}

output "env" {
  description = "배포 환경"
  value       = var.env
}

output "primary_region" {
  description = "Primary AWS 리전"
  value       = var.primary_region
}

# ── 모듈 outputs는 해당 모듈 구현 후 추가한다 ──────────────────────────────────
#
# output "dev_app_vpc_id" {
#   description = "Dev App VPC ID"
#   value       = module.dev_app_vpc.vpc_id
# }
#
# output "dev_data_vpc_id" {
#   description = "Dev Data VPC ID"
#   value       = module.dev_data_vpc.vpc_id
# }
#
# output "transit_gateway_id" {
#   description = "Transit Gateway ID"
#   value       = module.transit_gateway.tgw_id
# }
#
# output "dev_eks_cluster_name" {
#   description = "Dev EKS 클러스터 이름"
#   value       = module.dev_eks.cluster_name
# }
#
# output "dev_eks_cluster_endpoint" {
#   description = "Dev EKS 클러스터 API 엔드포인트"
#   value       = module.dev_eks.cluster_endpoint
#   sensitive   = true
# }

# ── Network VPC ────────────────────────────────────────────────────────────────

output "network_vpc_id" {
  description = "Network VPC ID"
  value       = module.network_vpc.network_vpc_id
}

output "network_public_subnet_ids" {
  description = "Network VPC Public Subnet IDs"
  value       = module.network_vpc.public_subnet_ids
}

output "network_tgw_attachment_subnet_ids" {
  description = "Network VPC TGW Attachment Subnet IDs"
  value       = module.network_vpc.tgw_attachment_subnet_ids
}

output "network_nat_gateway_id" {
  description = "Centralized NAT Gateway ID"
  value       = module.network_vpc.nat_gateway_id
}

output "network_igw_id" {
  description = "Network VPC Internet Gateway ID"
  value       = module.network_vpc.internet_gateway_id
}

output "network_public_route_table_id" {
  description = "Network VPC Public Route Table ID"
  value       = module.network_vpc.public_route_table_id
}

output "network_tgw_attachment_route_table_id" {
  description = "Network VPC TGW Attachment Route Table ID"
  value       = module.network_vpc.tgw_attachment_route_table_id
}

# ── ECR ────────────────────────────────────────────────────────────────────────

output "ecr_repository_names" {
  description = "ECR Repository 이름 목록"
  value       = module.ecr.repository_names
}

output "ecr_repository_urls" {
  description = "ECR Repository URL 목록"
  value       = module.ecr.repository_urls
}

output "ecr_repository_arns" {
  description = "ECR Repository ARN 목록"
  value       = module.ecr.repository_arns
}

output "backend_repository_url" {
  description = "Backend API ECR Repository URL"
  value       = module.ecr.backend_repository_url
}

output "ai_service_repository_url" {
  description = "AI Service ECR Repository URL"
  value       = module.ecr.ai_service_repository_url
}

output "batch_repository_url" {
  description = "Batch Job ECR Repository URL"
  value       = module.ecr.batch_repository_url
}