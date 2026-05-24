variable "project_name" {
  description = "Project name used for OpenSearch resource naming."
  type        = string
}

variable "environment" {
  description = "Environment name for OpenSearch resources."
  type        = string
}

variable "domain_name" {
  description = "OpenSearch domain name."
  type        = string
}

variable "engine_version" {
  description = "OpenSearch engine version."
  type        = string
  default     = "OpenSearch_2.17"
}

variable "instance_type" {
  description = "OpenSearch data node instance type."
  type        = string
  default     = "t3.small.search"
}

variable "instance_count" {
  description = "Number of OpenSearch data nodes."
  type        = number
  default     = 1
}

variable "zone_awareness_enabled" {
  description = "Whether OpenSearch zone awareness is enabled."
  type        = bool
  default     = false
}

variable "availability_zone_count" {
  description = "Number of availability zones when zone awareness is enabled."
  type        = number
  default     = 2
}

variable "ebs_volume_type" {
  description = "EBS volume type for OpenSearch data nodes."
  type        = string
  default     = "gp3"
}

variable "ebs_volume_size" {
  description = "EBS volume size in GiB for OpenSearch data nodes."
  type        = number
  default     = 10
}

variable "subnet_ids" {
  description = "Private data subnet IDs where OpenSearch VPC endpoints are placed."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs attached to OpenSearch."
  type        = list(string)
}

variable "encrypt_at_rest_enabled" {
  description = "Whether encryption at rest is enabled."
  type        = bool
  default     = true
}

variable "node_to_node_encryption_enabled" {
  description = "Whether node-to-node encryption is enabled."
  type        = bool
  default     = true
}

variable "tls_security_policy" {
  description = "TLS security policy for OpenSearch HTTPS endpoint."
  type        = string
  default     = "Policy-Min-TLS-1-2-2019-07"
}

variable "access_policy_principal_type" {
  description = "Principal type used in the OpenSearch access policy."
  type        = string
  default     = "AWS"
}

variable "access_policy_principal_identifiers" {
  description = "Principal identifiers used in the OpenSearch access policy. VPC access is still restricted by subnet and security group."
  type        = list(string)
  default     = ["*"]
}

variable "create_service_linked_role" {
  description = "Whether to create the account-level OpenSearch service-linked role. Enable this only once per AWS account."
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Common tags applied to OpenSearch resources."
  type        = map(string)
  default     = {}
}
