# ── 프로젝트 공통 ──────────────────────────────────────────────────────────────

variable "project_name" {
  description = "프로젝트 이름. 리소스 네이밍 및 태그에 사용된다."
  type        = string
  default     = "moment"
}

variable "env" {
  description = "배포 환경 구분자. (dev / prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "prod"], var.env)
    error_message = "env 값은 'dev' 또는 'prod' 이어야 한다."
  }
}

variable "primary_region" {
  description = "Primary AWS 리전. 실습 환경에서는 ap-northeast-3 (Osaka)를 사용한다."
  type        = string
  default     = "ap-northeast-3"
}


# ── VPC CIDR ───────────────────────────────────────────────────────────────────
# Single AWS Account 기반 Multi-VPC 논리 분리 구조.
# CIDR 블록은 VPC 간 겹침이 없도록 /16 단위로 할당한다.

variable "network_vpc_cidr" {
  description = "Network VPC CIDR. Centralized NAT Gateway, Transit Gateway Attachment, optional Bastion/VPN을 배치한다."
  type        = string
  default     = "10.0.0.0/16"
}

variable "prod_app_vpc_cidr" {
  description = "Prod App VPC CIDR. ALB, EKS Worker Node(Backend API / AI Service / Batch Job Pod)를 배치한다."
  type        = string
  default     = "10.10.0.0/16"
}

variable "prod_data_vpc_cidr" {
  description = "Prod Data VPC CIDR. RDS PostgreSQL, ElastiCache Redis/Valkey, OpenSearch를 배치한다."
  type        = string
  default     = "10.20.0.0/16"
}

variable "dev_app_vpc_cidr" {
  description = "Dev App VPC CIDR. Dev ALB, Dev EKS Worker Node를 배치한다."
  type        = string
  default     = "10.30.0.0/16"
}

variable "dev_data_vpc_cidr" {
  description = "Dev Data VPC CIDR. Dev RDS, Dev Redis/Valkey, Dev OpenSearch를 배치한다."
  type        = string
  default     = "10.40.0.0/16"
}

# ── 가용 영역 ──────────────────────────────────────────────────────────────────

variable "availability_zones" {
  description = "사용할 AZ 목록. ap-northeast-3은 AZ-A / AZ-C 2개를 기준으로 한다."
  type        = list(string)
  default     = ["ap-northeast-3a", "ap-northeast-3c"]
}

# ── EKS ───────────────────────────────────────────────────────────────────────

variable "eks_cluster_version" {
  description = "EKS 클러스터 Kubernetes 버전."
  type        = string
  default     = "1.30"
}

variable "eks_node_instance_type" {
  description = "EKS Managed Node Group EC2 인스턴스 타입."
  type        = string
  default     = "t3.medium"
}

variable "eks_node_desired_size" {
  description = "EKS Managed Node Group 기본 노드 수."
  type        = number
  default     = 2
}

variable "eks_node_min_size" {
  description = "EKS Managed Node Group 최소 노드 수."
  type        = number
  default     = 1
}

variable "eks_node_max_size" {
  description = "EKS Managed Node Group 최대 노드 수."
  type        = number
  default     = 4
}

# ── RDS ───────────────────────────────────────────────────────────────────────

variable "rds_instance_class" {
  description = "RDS PostgreSQL 인스턴스 클래스."
  type        = string
  default     = "db.t3.micro"
}

variable "rds_db_name" {
  description = "RDS 초기 데이터베이스 이름."
  type        = string
  default     = "momentdb"
}

variable "rds_username" {
  description = "RDS 마스터 사용자 이름."
  type        = string
  sensitive   = true
}

variable "rds_password" {
  description = "RDS 마스터 비밀번호. 실제 운영에서는 Secrets Manager를 사용한다."
  type        = string
  sensitive   = true
}

# ── ElastiCache ────────────────────────────────────────────────────────────────

variable "redis_node_type" {
  description = "ElastiCache Redis/Valkey 노드 타입."
  type        = string
  default     = "cache.t3.micro"
}

# ── OpenSearch ─────────────────────────────────────────────────────────────────

variable "opensearch_instance_type" {
  description = "OpenSearch 노드 인스턴스 타입."
  type        = string
  default     = "t3.small.search"
}

variable "opensearch_instance_count" {
  description = "OpenSearch 데이터 노드 수. 데모: 2 (2-AZ), 운영: 3 (Multi-AZ with Standby)."
  type        = number
  default     = 2
}

variable "enable_nat_gateway" {
  description = "Network VPC에 Centralized NAT Gateway를 생성할지 여부."
  type        = bool
  default     = true
}

# ── ECR ────────────────────────────────────────────────────────────────────────

variable "ecr_repositories" {
  description = "ECR Repository 목록."
  type = map(object({
    name        = string
    description = string
  }))
  default = {
    backend = {
      name        = "moment-backend"
      description = "MoMent Backend API image repository"
    }
    ai-service = {
      name        = "moment-ai-service"
      description = "MoMent AI Service image repository"
    }
    batch = {
      name        = "moment-batch"
      description = "MoMent Batch Job image repository"
    }
  }
}

variable "ecr_image_tag_mutability" {
  description = "ECR image tag mutability 설정."
  type        = string
  default     = "IMMUTABLE"
}

variable "ecr_scan_on_push" {
  description = "ECR image scan on push 활성화 여부."
  type        = bool
  default     = true
}

variable "ecr_encryption_type" {
  description = "ECR Repository 암호화 방식."
  type        = string
  default     = "AES256"
}

variable "transit_gateway_id" {
  description = "Transit Gateway ID for App VPC private route"
  type        = string
  default     = ""
}

variable "data_vpc_cidr" {
  description = "Prod Data VPC CIDR"
  type        = string
  default     = "10.20.0.0/16"
}