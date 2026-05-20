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