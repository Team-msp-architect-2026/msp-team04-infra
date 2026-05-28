variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
  default     = "moment"
}

variable "env" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "primary_region" {
  description = "Primary AWS region"
  type        = string
  default     = "ap-northeast-3"
}

variable "network_vpc_cidr" {
  description = "CIDR block for Network VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "prod_vpc_cidr" {
  description = "CIDR block for Prod VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "dev_vpc_cidr" {
  description = "CIDR block for Dev VPC"
  type        = string
  default     = "10.20.0.0/16"
}
variable "admin_cidr_blocks" {
  description = "Administrator CIDR blocks allowed to access OpenVPN"
  type        = list(string)
  default     = []
}


variable "enable_network_openvpn" {
  description = "Whether to create the Network VPC OpenVPN admin access instance."
  type        = bool
  default     = false
}


variable "openvpn_ami_id" {
  description = "Optional AMI ID for OpenVPN. If empty, the OpenVPN module selects the latest Amazon Linux 2023 x86_64 AMI."
  type        = string
  default     = ""
}

variable "openvpn_instance_type" {
  description = "OpenVPN EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "openvpn_enable_eip" {
  description = "Whether to allocate an Elastic IP for the OpenVPN instance."
  type        = bool
  default     = true
}

variable "openvpn_port" {
  description = "OpenVPN port."
  type        = number
  default     = 1194
}

variable "openvpn_protocol" {
  description = "OpenVPN protocol."
  type        = string
  default     = "udp"
}

variable "openvpn_vpn_cidr" {
  description = "OpenVPN client tunnel CIDR."
  type        = string
  default     = "10.8.0.0/24"
}

variable "openvpn_client_name" {
  description = "Default OpenVPN client profile name generated on the instance."
  type        = string
  default     = "moment-admin"
}


variable "openvpn_client_profile_secret_name" {
  description = "Secrets Manager secret name for generated OpenVPN client profile. If empty, a project-based default name is used."
  type        = string
  default     = ""
}

variable "openvpn_client_profile_secret_recovery_window_in_days" {
  description = "Secrets Manager recovery window in days for OpenVPN client profile. Use 0 for short-lived validation."
  type        = number
  default     = 0
}

variable "openvpn_root_volume_size" {
  description = "OpenVPN EC2 root volume size in GiB."
  type        = number
  default     = 8
}


variable "app_port" {
  description = "Application port exposed by EKS workload"
  type        = number
  default     = 8080
}

variable "enable_prod_vpc_endpoints" {
  description = "Whether to create Prod VPC Endpoints"
  type        = bool
  default     = false
}

variable "enable_dev_vpc_endpoints" {
  description = "Whether to create Dev VPC Endpoints"
  type        = bool
  default     = true
}

variable "enable_dev_eks" {
  description = "Whether to create the Dev EKS cluster by default for practice and validation."
  type        = bool
  default     = true
}

variable "enable_prod_eks" {
  description = "Whether to create the Prod EKS cluster. Disabled by default for cost saving."
  type        = bool
  default     = false
}

variable "dev_eks_cluster_name" {
  description = "Dev EKS cluster name for M2-EKS-01"
  type        = string
  default     = "moment-dev-eks-cluster"
}

variable "dev_eks_public_access_cidrs" {
  description = "CIDR blocks allowed to access the Dev EKS public API endpoint"
  type        = list(string)
  default     = ["115.138.87.55/32"]
}

variable "dev_eks_cluster_admin_principal_arn" {
  description = "IAM principal ARN granted cluster-admin access to the Dev EKS cluster through EKS Access Entry"
  type        = string
  default     = "arn:aws:iam::611058323802:user/student01"
}

variable "prod_eks_cluster_name" {
  description = "Prod EKS cluster name for M2-EKS-01. Disabled by default for cost saving."
  type        = string
  default     = "moment-prod-eks-cluster"
}

variable "prod_eks_kubernetes_version" {
  description = "Kubernetes version for Prod EKS cluster"
  type        = string
  default     = "1.35"
}

variable "prod_eks_public_access_cidrs" {
  description = "CIDR blocks allowed to access the Prod EKS public API endpoint when Prod EKS is enabled"
  type        = list(string)
  default     = ["115.138.87.55/32"]
}

variable "prod_eks_cluster_admin_principal_arn" {
  description = "IAM principal ARN granted cluster-admin access through EKS Access Entry"
  type        = string
  default     = "arn:aws:iam::611058323802:user/student06"
}

variable "enable_dev_nodegroups" {
  description = "Whether to create Dev EKS managed node groups."
  type        = bool
  default     = true
}

variable "enable_prod_nodegroups" {
  description = "Whether to create Prod EKS managed node groups. Disabled by default for cost saving."
  type        = bool
  default     = false
}


variable "enable_dev_sqs" {
  description = "Whether to create Dev SQS queues for public data pipeline validation."
  type        = bool
  default     = true
}

variable "enable_prod_sqs" {
  description = "Whether to create Prod SQS queues. Disabled by default for cost saving."
  type        = bool
  default     = false
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


variable "enable_dev_s3_raw_bucket" {
  description = "Whether to manage Dev S3 Raw Bucket in terraform/environments/dev."
  type        = bool
  default     = true
}

variable "dev_raw_bucket_name" {
  description = "Optional explicit Dev S3 Raw Bucket name. Keep null to use the module naming convention."
  type        = string
  default     = null
}

variable "enable_dev_data_pipeline" {
  description = "Whether to create Dev EventBridge Scheduler and Lambda Collector for public data pipeline validation."
  type        = bool
  default     = true
}

variable "enable_prod_data_pipeline" {
  description = "Whether to create Prod EventBridge Scheduler and Lambda Collector. Disabled by default for cost saving."
  type        = bool
  default     = false
}

variable "data_pipeline_public_data_api_url" {
  description = "Legacy single Public Data API URL. Prefer data_pipeline_public_data_sources_json for M2-DATA-02."
  type        = string
  default     = ""
}

variable "data_pipeline_public_data_sources_json" {
  description = "JSON array of public data source configs for Lambda Collector."
  type        = string
  default     = "[]"

  validation {
    condition     = can(jsondecode(var.data_pipeline_public_data_sources_json))
    error_message = "data_pipeline_public_data_sources_json must be valid JSON."
  }
}

variable "enable_lambda_collector_secrets_manager_read" {
  description = "Whether Lambda Collector can read public data API keys from Secrets Manager."
  type        = bool
  default     = true
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

variable "dev_data_pipeline_schedule_state" {
  description = "Dev EventBridge Scheduler state. Keep DISABLED unless scheduled execution is intentionally required."
  type        = string
  default     = "DISABLED"
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

variable "enable_dev_redis" {
  description = "Whether to create Dev ElastiCache Redis by default for development validation."
  type        = bool
  default     = true
}

variable "enable_prod_redis" {
  description = "Whether to create Prod ElastiCache Redis. Disabled by default for cost saving."
  type        = bool
  default     = false
}

variable "redis_engine_version" {
  description = "Redis engine version."
  type        = string
  default     = "7.0"
}

variable "redis_node_type" {
  description = "Redis node type for practice and validation."
  type        = string
  default     = "cache.t3.micro"
}

variable "enable_dev_rds" {
  description = "Whether to create Dev RDS PostgreSQL by default for development validation."
  type        = bool
  default     = true
}

variable "enable_prod_rds" {
  description = "Whether to create Prod RDS PostgreSQL. Disabled by default for cost saving."
  type        = bool
  default     = false
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

variable "rds_instance_class" {
  description = "RDS instance class for practice and validation."
  type        = string
  default     = "db.t4g.micro"
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

variable "rds_allocated_storage" {
  description = "Allocated RDS storage size in GiB."
  type        = number
  default     = 20
}

variable "rds_max_allocated_storage" {
  description = "Maximum RDS storage size in GiB for autoscaling."
  type        = number
  default     = 100
}

variable "prod_rds_multi_az" {
  description = "Whether Prod RDS PostgreSQL uses Multi-AZ Primary/Standby deployment when Prod RDS is enabled."
  type        = bool
  default     = true
}

variable "prod_rds_backup_retention_period" {
  description = "Backup retention period in days for Prod RDS PostgreSQL."
  type        = number
  default     = 7
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

variable "enable_dev_opensearch" {
  description = "Whether to create Dev OpenSearch by default for development validation."
  type        = bool
  default     = true
}

variable "enable_prod_opensearch" {
  description = "Whether to create Prod OpenSearch. Disabled by default for cost saving."
  type        = bool
  default     = false
}

variable "create_opensearch_service_linked_role" {
  description = "Whether to create the account-level OpenSearch service-linked role. Keep true only when the role does not already exist in the AWS account."
  type        = bool
  default     = true
}

variable "opensearch_engine_version" {
  description = "OpenSearch engine version."
  type        = string
  default     = "OpenSearch_2.17"
}

variable "dev_opensearch_instance_type" {
  description = "Dev OpenSearch instance type for cost-optimized validation."
  type        = string
  default     = "t3.small.search"
}

variable "prod_opensearch_instance_type" {
  description = "Prod OpenSearch instance type used only when Prod OpenSearch is explicitly enabled."
  type        = string
  default     = "t3.small.search"
}

variable "prod_opensearch_instance_count" {
  description = "Number of Prod OpenSearch data nodes when Prod OpenSearch is enabled."
  type        = number
  default     = 2
}

variable "prod_opensearch_zone_awareness_enabled" {
  description = "Whether Prod OpenSearch uses zone awareness when explicitly enabled."
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

variable "dev_opensearch_ebs_volume_size" {
  description = "Dev OpenSearch EBS volume size in GiB."
  type        = number
  default     = 10
}

variable "prod_opensearch_ebs_volume_size" {
  description = "Prod OpenSearch EBS volume size in GiB when Prod OpenSearch is enabled."
  type        = number
  default     = 20
}

# ─── Edge Layer ──────────────────────────────────────────────────────────────
variable "enable_edge" {
  description = "Edge 계층(CloudFront/WAF/ACM) 생성 여부"
  type        = bool
  default     = false
}

variable "enable_waf" {
  description = "WAF Web ACL 생성 여부"
  type        = bool
  default     = true
}

variable "edge_domain_name" {
  description = "커스텀 도메인명 (없으면 빈 문자열)"
  type        = string
  default     = ""
}

variable "edge_subject_alternative_names" {
  description = "ACM 추가 도메인 목록"
  type        = list(string)
  default     = []
}

variable "create_route53_hosted_zone" {
  description = "Route53 Hosted Zone 신규 생성 여부"
  type        = bool
  default     = false
}

variable "prod_alb_dns_name" {
  description = "Prod ALB DNS명 (CloudFront Origin). Prod ALB 생성 전엔 빈 문자열"
  type        = string
  default     = ""
}

variable "prod_alb_https_enabled" {
  description = "CloudFront → Prod ALB HTTPS 사용 여부"
  type        = bool
  default     = false
}

variable "cloudfront_secret_header_value" {
  description = "X-CloudFront-Secret 헤더 값 (ALB 직접 접근 차단용)"
  type        = string
  sensitive   = true
  default     = "moment-cf-secret-change-me"
}

variable "cloudfront_price_class" {
  description = "CloudFront 요금제 클래스"
  type        = string
  default     = "PriceClass_All"
}

# ──────────────────────────────────────────────────────────────────────────────
# Shared environment dependency inputs
# ──────────────────────────────────────────────────────────────────────────────


variable "shared_raw_bucket_name" {
  description = "Deprecated. Dev Raw Bucket is now managed by terraform/environments/dev via module.dev_s3_raw_bucket."
  type        = string
  default     = ""
}



variable "enable_dev_iam" {
  description = "Whether to manage Dev environment IAM roles and policies from terraform/environments/dev."
  type        = bool
  default     = true
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
