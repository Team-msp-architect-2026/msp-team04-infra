variable "name_prefix" {
  description = "리소스 이름 prefix. 예: moment-dev-prod-data"
  type        = string
}

variable "vpc_cidr" {
  description = "Data VPC CIDR block."
  type        = string
}

variable "availability_zones" {
  description = "Subnet을 생성할 Availability Zone 목록."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "Data VPC는 최소 2개 이상의 AZ를 사용해야 합니다."
  }
}

variable "private_db_subnet_cidrs" {
  description = "RDS PostgreSQL 배치용 Private DB Subnet CIDR 목록."
  type        = list(string)
}

variable "private_cache_subnet_cidrs" {
  description = "ElastiCache Redis 배치용 Private Cache Subnet CIDR 목록."
  type        = list(string)
}

variable "private_search_subnet_cidrs" {
  description = "OpenSearch 배치용 Private Search Subnet CIDR 목록."
  type        = list(string)
}

variable "tgw_attachment_subnet_cidrs" {
  description = "Transit Gateway Attachment 전용 Subnet CIDR 목록."
  type        = list(string)
}

variable "transit_gateway_id" {
  description = "Data VPC를 연결할 Transit Gateway ID. 빈 문자열이면 TGW Attachment와 TGW route를 생성하지 않는다."
  type        = string
  default     = ""
}

variable "app_vpc_cidr" {
  description = "Data VPC에서 접근을 허용할 App VPC CIDR. 예: Prod App VPC 10.10.0.0/16"
  type        = string
}

variable "tags" {
  description = "공통 태그."
  type        = map(string)
  default     = {}
}
