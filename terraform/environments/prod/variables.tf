variable "project_name" {
  description = "Project name used for resource naming and tagging."
  type        = string
  default     = "moment"
}

variable "env" {
  description = "Environment name."
  type        = string
  default     = "prod"
}

variable "primary_region" {
  description = "Primary AWS region."
  type        = string
  default     = "ap-northeast-3"
}

variable "network_vpc_cidr" {
  description = "CIDR block for Network VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "prod_vpc_cidr" {
  description = "CIDR block for Prod VPC."
  type        = string
  default     = "10.10.0.0/16"
}

variable "dev_vpc_cidr" {
  description = "CIDR block for Dev VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "admin_cidr_blocks" {
  description = "Administrator CIDR blocks allowed to access internal resources when explicit admin access rules are added."
  type        = list(string)
  default     = []
}

variable "app_port" {
  description = "Application port exposed by EKS workload."
  type        = number
  default     = 8080
}

variable "prod_transit_gateway_id" {
  description = "Existing Transit Gateway ID for Prod VPC routes. Keep null until shared/network state handoff is defined."
  type        = string
  default     = null
}

variable "enable_prod_ecr" {
  description = "Whether to create Prod ECR repositories. Disabled by default for cost saving and migration safety."
  type        = bool
  default     = false
}

variable "enable_prod_vpc" {
  description = "Whether to preserve/manage existing Prod VPC foundation resources in terraform/environments/prod."
  type        = bool
  default     = true
}

variable "enable_prod_vpc_endpoints" {
  description = "Whether to create Prod VPC endpoints."
  type        = bool
  default     = false
}

variable "enable_prod_eks" {
  description = "Whether to create the Prod EKS cluster."
  type        = bool
  default     = false
}

variable "enable_prod_nodegroups" {
  description = "Whether Prod EKS managed node groups are enabled. Detailed Prod nodegroup implementation is handled by M2-EKS-04."
  type        = bool
  default     = false
}

variable "enable_prod_data_tier" {
  description = "Whether Prod data tier resources can be created. Individual RDS/Redis/OpenSearch flags must also be enabled."
  type        = bool
  default     = false
}

variable "enable_prod_rds" {
  description = "Whether to create Prod RDS PostgreSQL."
  type        = bool
  default     = false
}

variable "enable_prod_rds_read_replica" {
  description = "Whether to create a Prod RDS read replica. Disabled by default and reserved for future scaling."
  type        = bool
  default     = false
}

variable "enable_prod_redis" {
  description = "Whether to create Prod ElastiCache Redis."
  type        = bool
  default     = false
}

variable "enable_prod_opensearch" {
  description = "Whether to create Prod OpenSearch."
  type        = bool
  default     = false
}

variable "enable_prod_sqs" {
  description = "Whether to create Prod SQS queues."
  type        = bool
  default     = false
}

variable "enable_prod_s3_raw_bucket" {
  description = "Whether to manage Prod S3 Raw Bucket in terraform/environments/prod. Keep false until Prod data pipeline activation is approved."
  type        = bool
  default     = false
}

variable "prod_raw_bucket_name" {
  description = "Optional explicit Prod S3 Raw Bucket name. Keep null to use the module naming convention."
  type        = string
  default     = null
}

variable "enable_prod_data_pipeline" {
  description = "Whether to create Prod EventBridge Scheduler and Lambda Collector."
  type        = bool
  default     = false
}

variable "enable_edge" {
  description = "Whether to preserve/manage existing Prod Edge resources already tracked in terraform/environments/prod."
  type        = bool
  default     = true
}

variable "shared_lambda_collector_role_arn" {
  description = "Shared Lambda Collector IAM role ARN. Prod data pipeline uses shared IAM instead of duplicating account-level IAM."
  type        = string
  default     = ""
}

variable "shared_raw_bucket_name" {
  description = "Deprecated. Prod Raw Bucket is now managed by terraform/environments/prod via module.prod_s3_raw_bucket."
  type        = string
  default     = ""
}

variable "prod_eks_cluster_name" {
  description = "Prod EKS cluster name."
  type        = string
  default     = "moment-prod-eks-cluster"
}

variable "prod_eks_kubernetes_version" {
  description = "Kubernetes version for Prod EKS cluster."
  type        = string
  default     = "1.35"
}

variable "prod_eks_cluster_role_arn" {
  description = "Existing shared IAM role ARN for the EKS control plane. Required only when enable_prod_eks is true."
  type        = string
  default     = ""
}

variable "prod_eks_node_role_arn" {
  description = "Existing shared IAM role ARN for Prod EKS node groups. Reserved for M2-EKS-04."
  type        = string
  default     = ""
}

variable "prod_eks_public_access_cidrs" {
  description = "CIDR blocks allowed to access the Prod EKS public API endpoint when Prod EKS is enabled."
  type        = list(string)
  default     = []
}

variable "prod_eks_cluster_admin_principal_arn" {
  description = "IAM principal ARN granted cluster-admin access through EKS Access Entry."
  type        = string
  default     = ""
}

variable "sqs_visibility_timeout_seconds" {
  description = "Visibility timeout for SQS messages in seconds."
  type        = number
  default     = 300
}

variable "sqs_message_retention_seconds" {
  description = "Message retention period for the main SQS queue in seconds."
  type        = number
  default     = 345600
}

variable "sqs_dlq_message_retention_seconds" {
  description = "Message retention period for the SQS dead-letter queue in seconds."
  type        = number
  default     = 1209600
}

variable "sqs_max_receive_count" {
  description = "Number of receives before moving a message to the DLQ."
  type        = number
  default     = 3
}

variable "sqs_receive_wait_time_seconds" {
  description = "Long polling wait time for SQS receive calls in seconds."
  type        = number
  default     = 10
}

variable "sqs_delay_seconds" {
  description = "Delay for new SQS messages in seconds."
  type        = number
  default     = 0
}

variable "sqs_max_message_size" {
  description = "Maximum SQS message size in bytes."
  type        = number
  default     = 262144
}

variable "sqs_managed_sse_enabled" {
  description = "Whether SQS managed server-side encryption is enabled."
  type        = bool
  default     = true
}

variable "data_pipeline_public_data_api_url" {
  description = "Legacy single Public Data API URL. Prefer data_pipeline_public_data_sources_json or secret name."
  type        = string
  default     = ""
}

variable "data_pipeline_public_data_sources_json" {
  description = "Legacy inline JSON array of public data source configs. Prefer data_pipeline_public_data_sources_secret_name."
  type        = string
  default     = "[]"

  validation {
    condition     = can(jsondecode(var.data_pipeline_public_data_sources_json))
    error_message = "data_pipeline_public_data_sources_json must be valid JSON."
  }
}

variable "data_pipeline_public_data_sources_secret_name" {
  description = "Secrets Manager secret name containing public data source configs."
  type        = string
  default     = ""
}

variable "data_pipeline_schedule_expression" {
  description = "EventBridge Scheduler expression for public data collection."
  type        = string
  default     = "rate(1 day)"
}

variable "prod_data_pipeline_schedule_state" {
  description = "Prod EventBridge Scheduler state. Keep DISABLED outside final demo or rehearsal."
  type        = string
  default     = "DISABLED"
}

variable "data_pipeline_lambda_runtime" {
  description = "Lambda Collector runtime."
  type        = string
  default     = "python3.12"
}

variable "data_pipeline_lambda_timeout" {
  description = "Lambda Collector timeout in seconds."
  type        = number
  default     = 30
}

variable "data_pipeline_lambda_memory_size" {
  description = "Lambda Collector memory size in MB."
  type        = number
  default     = 128
}

variable "data_pipeline_log_retention_days" {
  description = "CloudWatch Logs retention days for Lambda Collector."
  type        = number
  default     = 14
}

variable "redis_engine_version" {
  description = "Redis engine version."
  type        = string
  default     = "7.0"
}

variable "prod_redis_node_type" {
  description = "Prod Redis node type."
  type        = string
  default     = "cache.t3.micro"
}

variable "prod_redis_automatic_failover_enabled" {
  description = "Whether Prod Redis automatic failover is enabled."
  type        = bool
  default     = false
}

variable "prod_redis_multi_az_enabled" {
  description = "Whether Prod Redis Multi-AZ is enabled."
  type        = bool
  default     = false
}

variable "prod_redis_snapshot_retention_limit" {
  description = "Number of days to retain Prod Redis snapshots."
  type        = number
  default     = 0
}

variable "rds_engine_version" {
  description = "PostgreSQL engine version for RDS."
  type        = string
  default     = "17.10"
}

variable "rds_parameter_group_family" {
  description = "PostgreSQL parameter group family for RDS."
  type        = string
  default     = "postgres17"
}

variable "rds_database_name" {
  description = "Initial PostgreSQL database name."
  type        = string
  default     = "moment"
}

variable "rds_master_username" {
  description = "PostgreSQL master username."
  type        = string
  default     = "moment_admin"
}

variable "prod_rds_instance_class" {
  description = "Prod RDS instance class."
  type        = string
  default     = "db.t4g.small"
}

variable "prod_rds_allocated_storage" {
  description = "Allocated Prod RDS storage size in GiB."
  type        = number
  default     = 50
}

variable "prod_rds_max_allocated_storage" {
  description = "Maximum Prod RDS storage size in GiB for autoscaling."
  type        = number
  default     = 200
}

variable "prod_rds_multi_az" {
  description = "Whether Prod RDS PostgreSQL uses Multi-AZ Primary/Standby deployment."
  type        = bool
  default     = true
}

variable "prod_rds_backup_retention_period" {
  description = "Backup retention period in days for Prod RDS PostgreSQL."
  type        = number
  default     = 14
}

variable "prod_rds_backup_window" {
  description = "Preferred backup window for Prod RDS PostgreSQL."
  type        = string
  default     = "18:00-19:00"
}

variable "prod_rds_maintenance_window" {
  description = "Preferred maintenance window for Prod RDS PostgreSQL."
  type        = string
  default     = "sun:19:00-sun:20:00"
}

variable "prod_rds_deletion_protection" {
  description = "Whether deletion protection is enabled for Prod RDS PostgreSQL."
  type        = bool
  default     = true
}

variable "prod_rds_skip_final_snapshot" {
  description = "Whether to skip final snapshot on Prod RDS destroy."
  type        = bool
  default     = false
}

variable "prod_rds_final_snapshot_identifier" {
  description = "Final snapshot identifier for Prod RDS. If null, a default project-based name is used."
  type        = string
  default     = null
}

variable "create_opensearch_service_linked_role" {
  description = "Whether to create the account-level OpenSearch service-linked role. Keep false unless the role does not already exist."
  type        = bool
  default     = false
}

variable "opensearch_engine_version" {
  description = "OpenSearch engine version."
  type        = string
  default     = "OpenSearch_2.17"
}

variable "prod_opensearch_instance_type" {
  description = "Prod OpenSearch instance type."
  type        = string
  default     = "t3.small.search"
}

variable "prod_opensearch_instance_count" {
  description = "Number of Prod OpenSearch data nodes."
  type        = number
  default     = 2
}

variable "prod_opensearch_zone_awareness_enabled" {
  description = "Whether Prod OpenSearch uses zone awareness."
  type        = bool
  default     = true
}

variable "prod_opensearch_availability_zone_count" {
  description = "Availability zone count for Prod OpenSearch zone awareness."
  type        = number
  default     = 2
}

variable "opensearch_ebs_volume_type" {
  description = "OpenSearch EBS volume type."
  type        = string
  default     = "gp3"
}

variable "prod_opensearch_ebs_volume_size" {
  description = "Prod OpenSearch EBS volume size in GiB."
  type        = number
  default     = 20
}

variable "enable_waf" {
  description = "Whether to create WAF Web ACL."
  type        = bool
  default     = true
}

variable "edge_domain_name" {
  description = "Custom domain name. Empty string uses CloudFront default domain."
  type        = string
  default     = ""
}

variable "edge_subject_alternative_names" {
  description = "ACM subject alternative names."
  type        = list(string)
  default     = []
}

variable "create_route53_hosted_zone" {
  description = "Whether to create a new Route53 Hosted Zone."
  type        = bool
  default     = false
}

variable "prod_alb_dns_name" {
  description = "Prod ALB DNS name used as CloudFront origin. Keep empty until Prod ALB is ready."
  type        = string
  default     = ""
}

variable "prod_alb_https_enabled" {
  description = "Whether CloudFront to Prod ALB uses HTTPS."
  type        = bool
  default     = false
}

variable "cloudfront_secret_header_value" {
  description = "X-CloudFront-Secret header value for ALB direct access restriction."
  type        = string
  sensitive   = true
  default     = "moment-cf-secret-change-me"
}

variable "cloudfront_price_class" {
  description = "CloudFront price class."
  type        = string
  default     = "PriceClass_All"
}

variable "enable_prod_iam" {
  description = "Whether to manage Prod environment IAM roles and policies from terraform/environments/prod. Keep false until Prod IAM activation is approved."
  type        = bool
  default     = false
}

variable "github_repository" {
  description = "GitHub repository allowed to assume GitHub Actions role."
  type        = string
  default     = "Team-msp-architect-2026/msp-team04-infra"
}

variable "github_default_branch" {
  description = "Default branch allowed to assume GitHub Actions role."
  type        = string
  default     = "develop"
}

variable "github_oidc_allowed_subjects" {
  description = "GitHub OIDC sub conditions allowed to assume the GitHub Actions role."
  type        = list(string)
  default = [
    "repo:Team-msp-architect-2026/msp-team04-infra:ref:refs/heads/develop"
  ]
}

variable "github_oidc_provider_arn" {
  description = "Existing account-level GitHub Actions OIDC Provider ARN."
  type        = string
  default     = "arn:aws:iam::611058323802:oidc-provider/token.actions.githubusercontent.com"
}

variable "enable_lambda_collector_secrets_manager_read" {
  description = "Whether Prod Lambda Collector can read public data API keys from Secrets Manager."
  type        = bool
  default     = false
}
