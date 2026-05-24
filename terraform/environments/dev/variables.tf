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
