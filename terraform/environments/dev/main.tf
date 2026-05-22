locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.env
    ManagedBy   = "terraform"
    Owner       = "team04"
  }
}

module "ecr" {
  source = "../../modules/ecr"

  repositories = {
    backend = {
      name        = "${var.project_name}-backend-api"
      description = "Backend API container image repository"
    }

    ai-service = {
      name        = "${var.project_name}-ai-service"
      description = "AI Service container image repository"
    }

    batch = {
      name        = "${var.project_name}-batch-job"
      description = "Batch Job container image repository"
    }
  }

  image_tag_mutability = "IMMUTABLE"
  scan_on_push         = true
  encryption_type      = "AES256"

  tags = local.common_tags
}

module "network_vpc" {
  source = "../../modules/network-vpc"

  project_name = var.project_name
  env          = var.env

  vpc_cidr = "10.0.0.0/16"

  availability_zones = [
    "${var.primary_region}a",
    "${var.primary_region}c"
  ]

  public_subnet_cidrs = [
    "10.0.0.0/24",
    "10.0.1.0/24"
  ]

  tgw_subnet_cidrs = [
    "10.0.100.0/28",
    "10.0.100.16/28"
  ]

  tags = local.common_tags
}