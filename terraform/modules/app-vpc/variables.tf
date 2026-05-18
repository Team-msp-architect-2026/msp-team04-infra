variable "name_prefix" {
  description = "리소스 이름 prefix"
  type        = string
}

variable "vpc_cidr" {
  description = "App VPC CIDR"
  type        = string
}

variable "availability_zones" {
  description = "사용할 AZ 목록"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Public Subnet CIDR 목록"
  type        = list(string)
}

variable "private_app_subnet_cidrs" {
  description = "Private App Subnet CIDR 목록"
  type        = list(string)
}

variable "tgw_attachment_subnet_cidrs" {
  description = "TGW Attachment Subnet CIDR 목록"
  type        = list(string)
}

variable "transit_gateway_id" {
  description = "Transit Gateway ID"
  type        = string
  default     = ""
}

variable "data_vpc_cidr" {
  description = "Data VPC CIDR"
  type        = string
}

variable "eks_cluster_name" {
  description = "EKS Cluster Name"
  type        = string
}

variable "tags" {
  description = "공통 태그"
  type        = map(string)
  default     = {}
}