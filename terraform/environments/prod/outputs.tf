output "project_name" {
  description = "Project name."
  value       = var.project_name
}

output "env" {
  description = "Environment name."
  value       = var.env
}

output "primary_region" {
  description = "Primary AWS region."
  value       = var.primary_region
}

output "prod_state_key" {
  description = "Remote state key for the Prod Terraform environment."
  value       = "prod/terraform.tfstate"
}

output "prod_vpc_id" {
  description = "Prod VPC ID."
  value       = try(module.prod_vpc[0].prod_vpc_id, null)
}

output "prod_private_app_subnet_ids" {
  description = "Prod private app subnet IDs."
  value       = try(module.prod_vpc[0].prod_private_app_subnet_ids, [])
}

output "prod_private_data_subnet_ids" {
  description = "Prod private data subnet IDs."
  value       = try(module.prod_vpc[0].prod_private_data_subnet_ids, [])
}

output "prod_security_group_ids" {
  description = "Prod service security group IDs."
  value       = try(module.prod_security_group[0].service_security_group_ids, {})
}

output "prod_sqs_queue_url" {
  description = "Prod SQS main queue URL."
  value       = try(module.prod_sqs[0].queue_url, null)
}

output "prod_sqs_queue_arn" {
  description = "Prod SQS main queue ARN."
  value       = try(module.prod_sqs[0].queue_arn, null)
}

output "prod_raw_bucket_name" {
  description = "Prod S3 Raw Bucket name."
  value       = try(module.prod_s3_raw_bucket[0].raw_bucket_name, null)
}

output "prod_raw_bucket_arn" {
  description = "Prod S3 Raw Bucket ARN."
  value       = try(module.prod_s3_raw_bucket[0].raw_bucket_arn, null)
}

output "prod_raw_bucket_access_policy_arn" {
  description = "Prod S3 Raw Bucket access policy ARN."
  value       = try(module.prod_s3_raw_bucket[0].raw_bucket_access_policy_arn, null)
}

output "prod_data_pipeline_lambda_function_name" {
  description = "Prod Lambda Collector function name."
  value       = try(module.prod_data_pipeline[0].lambda_function_name, null)
}

output "prod_eks_cluster_name" {
  description = "Prod EKS cluster name."
  value       = try(module.prod_eks[0].cluster_name, null)
}

output "prod_eks_cluster_endpoint" {
  description = "Prod EKS cluster API endpoint."
  value       = try(module.prod_eks[0].cluster_endpoint, null)
}

output "prod_redis_endpoint" {
  description = "Prod Redis primary endpoint."
  value       = try(module.prod_redis[0].redis_primary_endpoint, null)
}

output "prod_rds_endpoint" {
  description = "Prod RDS endpoint."
  value       = try(module.prod_rds[0].db_endpoint, null)
}

output "prod_opensearch_endpoint" {
  description = "Prod OpenSearch VPC endpoint."
  value       = try(module.prod_opensearch[0].endpoint, null)
}

output "edge_cloudfront_domain_name" {
  description = "CloudFront distribution domain name."
  value       = try(module.edge[0].cloudfront_domain_name, null)
}

output "prod_nodegroups_wiring_deferred_to_m2_eks_04" {
  description = "Prod Managed NodeGroup detailed wiring is intentionally deferred to M2-EKS-04."
  value       = true
}

output "prod_ecr_repository_names" {
  description = "Prod ECR Repository names."
  value       = var.enable_prod_ecr ? module.prod_ecr[0].repository_names : {}
}

output "prod_ecr_repository_urls" {
  description = "Prod ECR Repository URLs."
  value       = var.enable_prod_ecr ? module.prod_ecr[0].repository_urls : {}
}

output "prod_ecr_repository_arns" {
  description = "Prod ECR Repository ARNs."
  value       = var.enable_prod_ecr ? module.prod_ecr[0].repository_arns : {}
}

output "prod_backend_repository_url" {
  description = "Prod Backend API ECR Repository URL."
  value       = var.enable_prod_ecr ? module.prod_ecr[0].backend_repository_url : null
}

output "prod_ai_service_repository_url" {
  description = "Prod AI Service ECR Repository URL."
  value       = var.enable_prod_ecr ? module.prod_ecr[0].ai_service_repository_url : null
}

output "prod_batch_repository_url" {
  description = "Prod Batch Job ECR Repository URL."
  value       = var.enable_prod_ecr ? module.prod_ecr[0].batch_repository_url : null
}

output "prod_lambda_collector_role_arn" {
  description = "Prod Lambda Collector IAM role ARN."
  value       = var.enable_prod_iam ? module.prod_iam[0].lambda_collector_role_arn : null
}

output "prod_eks_cluster_role_arn" {
  description = "Prod EKS cluster IAM role ARN."
  value       = var.enable_prod_iam ? module.prod_iam[0].eks_cluster_role_arn : null
}

output "prod_eks_node_role_arn" {
  description = "Prod EKS node IAM role ARN."
  value       = var.enable_prod_iam ? module.prod_iam[0].eks_node_role_arn : null
}
