terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
  }

  backend "s3" {
    # bucket         = "moment-terraform-state-<account-id>"
    # key            = "dev/terraform.tfstate"
    # region         = "ap-northeast-3"
    # dynamodb_table = "moment-terraform-lock"
    # encrypt        = true
  }
}

# Primary Region: ap-northeast-3 (Osaka)
provider "aws" {
  region = var.primary_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.env
      ManagedBy   = "Terraform"
    }
  }
}

# Secondary Region: us-east-1 (N. Virginia)
# CloudFront viewer HTTPS용 ACM 인증서는 반드시 us-east-1에 생성해야 한다.
provider "aws" {
  alias  = "use1"
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.env
      ManagedBy   = "Terraform"
    }
  }
}