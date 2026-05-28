output "project_name" {
  description = "Project name."
  value       = var.project_name
}

output "env" {
  description = "Environment name."
  value       = var.env
}

output "primary_region" {
  description = "Primary AWS region."
  value       = var.primary_region
}

output "prod_environment_skeleton_ready" {
  description = "Whether the Prod Terraform environment skeleton exists."
  value       = true
}

output "prod_state_key" {
  description = "Remote state key for the Prod Terraform environment."
  value       = "prod/terraform.tfstate"
}
