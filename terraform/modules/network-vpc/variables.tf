variable "name_prefix" {
  description = "리소스 이름에 사용할 prefix. 예: moment-dev-network"
  type        = string
}

variable "vpc_cidr" {
  description = "Network VPC CIDR block."
  type        = string
}

variable "availability_zones" {
  description = "Subnet을 생성할 Availability Zone 목록."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "Network VPC는 최소 2개 이상의 AZ를 사용해야 합니다."
  }
}

variable "public_subnet_cidrs" {
  description = "Public Subnet CIDR 목록. null이면 vpc_cidr에서 자동 계산한다."
  type        = list(string)
  default     = null
}

variable "tgw_attachment_subnet_cidrs" {
  description = "TGW Attachment Subnet CIDR 목록. null이면 vpc_cidr에서 자동 계산한다."
  type        = list(string)
  default     = null
}

variable "enable_nat_gateway" {
  description = "Centralized NAT Gateway 생성 여부."
  type        = bool
  default     = true
}

variable "tags" {
  description = "공통 태그."
  type        = map(string)
  default     = {}
}