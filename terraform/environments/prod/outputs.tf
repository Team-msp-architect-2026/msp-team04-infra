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
