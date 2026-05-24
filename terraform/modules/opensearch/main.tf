data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  domain_arn = "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.domain_name}"

  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Component   = "opensearch"
    }
  )
}

resource "aws_iam_service_linked_role" "opensearch" {
  count = var.create_service_linked_role ? 1 : 0

  aws_service_name = "opensearchservice.amazonaws.com"
  description      = "Service linked role for Amazon OpenSearch Service"
}

data "aws_iam_policy_document" "domain_access" {
  statement {
    sid    = "AllowOpenSearchHttpAccess"
    effect = "Allow"

    principals {
      type        = var.access_policy_principal_type
      identifiers = var.access_policy_principal_identifiers
    }

    actions = [
      "es:ESHttpDelete",
      "es:ESHttpGet",
      "es:ESHttpHead",
      "es:ESHttpPatch",
      "es:ESHttpPost",
      "es:ESHttpPut"
    ]

    resources = [
      local.domain_arn,
      "${local.domain_arn}/*"
    ]
  }
}

resource "aws_opensearch_domain" "this" {
  domain_name    = var.domain_name
  engine_version = var.engine_version

  cluster_config {
    instance_type            = var.instance_type
    instance_count           = var.instance_count
    dedicated_master_enabled = false
    zone_awareness_enabled   = var.zone_awareness_enabled

    dynamic "zone_awareness_config" {
      for_each = var.zone_awareness_enabled ? [1] : []

      content {
        availability_zone_count = var.availability_zone_count
      }
    }
  }

  ebs_options {
    ebs_enabled = true
    volume_type = var.ebs_volume_type
    volume_size = var.ebs_volume_size
  }

  vpc_options {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  encrypt_at_rest {
    enabled = var.encrypt_at_rest_enabled
  }

  node_to_node_encryption {
    enabled = var.node_to_node_encryption_enabled
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = var.tls_security_policy
  }

  advanced_security_options {
    enabled                        = false
    internal_user_database_enabled = false
  }

  access_policies = data.aws_iam_policy_document.domain_access.json

  depends_on = [aws_iam_service_linked_role.opensearch]

  tags = merge(local.tags, {
    Name = var.domain_name
    Role = "opensearch-domain"
  })
}
