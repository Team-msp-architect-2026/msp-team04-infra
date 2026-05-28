locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.env
    ManagedBy   = "terraform"
    Owner       = "team04"
  }
}

module "s3_raw_bucket" {
  count  = var.enable_s3_raw_bucket ? 1 : 0
  source = "../../modules/s3"

  project_name = var.project_name
  environment  = var.raw_bucket_environment
  bucket_name  = var.raw_bucket_name

  force_destroy             = var.raw_bucket_force_destroy
  raw_expiration_days       = var.raw_expiration_days
  processed_expiration_days = var.processed_expiration_days
  failed_expiration_days    = var.failed_expiration_days

  common_tags = local.common_tags
}

module "iam" {
  count  = var.enable_common_iam ? 1 : 0
  source = "../../modules/iam"

  project_name = var.project_name
  environment  = var.iam_resource_environment

  github_repository            = var.github_repository
  github_default_branch        = var.github_default_branch
  github_oidc_allowed_subjects = var.github_oidc_allowed_subjects

  create_github_oidc_provider = var.create_github_oidc_provider
  github_oidc_provider_arn    = var.github_oidc_provider_arn

  create_eks_oidc_provider = false
  enable_irsa_roles        = false

  ecr_repository_arns          = var.ecr_repository_arns
  raw_bucket_access_policy_arn = coalesce(try(module.s3_raw_bucket[0].raw_bucket_access_policy_arn, null), var.raw_bucket_access_policy_arn)

  sqs_queue_arns                               = var.sqs_queue_arns
  enable_sqs_queue_policy_statements           = length(var.sqs_queue_arns) > 0
  opensearch_domain_arns                       = var.opensearch_domain_arns
  attach_lambda_raw_bucket_policy              = var.attach_lambda_raw_bucket_policy
  enable_lambda_collector_secrets_manager_read = var.enable_lambda_collector_secrets_manager_read

  common_tags = local.common_tags
}
