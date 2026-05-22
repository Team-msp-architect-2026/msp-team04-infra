variable "project_name" {
  description = "Project name."
  type        = string
}

variable "env" {
  description = "Environment name."
  type        = string
}

variable "vpc_cidr" {
  description = "Network VPC CIDR block."
  type        = string
}

variable "availability_zones" {
  description = "Availability zones for subnet creation."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks."
  type        = list(string)
}

variable "tgw_subnet_cidrs" {
  description = "TGW attachment subnet CIDR blocks."
  type        = list(string)
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}