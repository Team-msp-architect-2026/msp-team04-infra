output "project_name" {
  description = "Project name"
  value       = var.project_name
}

output "env" {
  description = "Environment name"
  value       = var.env
}

output "primary_region" {
  description = "Primary AWS region"
  value       = var.primary_region
}

# ── ECR Outputs ───────────────────────────────────────────────────────────────

output "ecr_repository_names" {
  description = "ECR Repository names."
  value       = module.ecr.repository_names
}

output "ecr_repository_urls" {
  description = "ECR Repository URLs for GitHub Actions."
  value       = module.ecr.repository_urls
}

output "ecr_repository_arns" {
  description = "ECR Repository ARNs."
  value       = module.ecr.repository_arns
}

output "backend_repository_url" {
  description = "Backend API ECR Repository URL."
  value       = module.ecr.backend_repository_url
}

output "ai_service_repository_url" {
  description = "AI Service ECR Repository URL."
  value       = module.ecr.ai_service_repository_url
}

output "batch_repository_url" {
  description = "Batch Job ECR Repository URL."
  value       = module.ecr.batch_repository_url
}