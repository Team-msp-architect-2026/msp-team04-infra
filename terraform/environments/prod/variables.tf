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

variable "enable_prod_vpc" {
  description = "Whether Prod VPC resources are wired in this environment. Keep false in the skeleton."
  type        = bool
  default     = false
}

variable "enable_prod_eks" {
  description = "Whether Prod EKS resources are wired in this environment. Keep false in the skeleton."
  type        = bool
  default     = false
}

variable "enable_prod_nodegroups" {
  description = "Whether Prod EKS node groups are wired in this environment. Keep false in the skeleton."
  type        = bool
  default     = false
}

variable "enable_prod_data_tier" {
  description = "Whether Prod RDS, Redis, and OpenSearch are wired in this environment. Keep false in the skeleton."
  type        = bool
  default     = false
}

variable "enable_prod_data_pipeline" {
  description = "Whether Prod SQS and data pipeline are wired in this environment. Keep false in the skeleton."
  type        = bool
  default     = false
}

variable "enable_edge" {
  description = "Whether Edge Layer resources are wired in this environment. Keep false until Prod ALB origin is ready."
  type        = bool
  default     = false
}
