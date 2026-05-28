locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.env
    ManagedBy   = "terraform"
    Owner       = "team04"
  }
}

# M2-OPS-01 scope:
# - Create a dedicated Terraform environment skeleton for Prod.
# - Separate Prod remote state from Dev by using prod/terraform.tfstate.
# - Do not migrate existing state in this issue.
# - Do not create Prod resources by default in this issue.
#
# Future Prod resource wiring candidates:
# - Prod VPC
# - Prod Security Groups
# - Prod VPC Endpoints
# - Prod EKS
# - Prod EKS NodeGroups
# - Prod RDS / Redis / OpenSearch
# - Prod SQS / Data Pipeline
# - Edge Layer
#
# Shared/account-level resources must be reviewed before moving:
# - ECR
# - GitHub OIDC Provider
# - IAM roles and policies
# - OpenSearch service-linked role
# - S3 Raw Bucket strategy
