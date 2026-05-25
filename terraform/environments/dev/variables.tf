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
  default     = "arn:aws:iam::611058323802:user/student06"
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
