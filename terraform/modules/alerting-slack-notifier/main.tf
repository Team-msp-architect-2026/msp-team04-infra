terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  topic_name  = coalesce(var.sns_topic_name, "${local.name_prefix}-monitoring-alert-topic")

  lambda_function_name = coalesce(
    var.lambda_function_name,
    "${local.name_prefix}-cloudwatch-slack-notifier"
  )

  tags = merge(
    var.common_tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Component   = "alerting"
      Purpose     = "cloudwatch-alert-slack-notification"
    }
  )

  alarm_actions = var.enable_alarm_actions ? [aws_sns_topic.alerts.arn] : []
  ok_actions    = var.enable_ok_actions ? [aws_sns_topic.alerts.arn] : []
}

resource "aws_secretsmanager_secret" "slack_webhook" {
  name                    = var.slack_webhook_secret_name
  description             = "MoMent ${var.environment} Slack webhook URL for monitoring alerts. Secret value is managed out-of-band."
  recovery_window_in_days = var.slack_webhook_secret_recovery_window_in_days

  tags = merge(local.tags, {
    Name = var.slack_webhook_secret_name
    Role = "slack-webhook-secret"
  })
}

resource "aws_sns_topic" "alerts" {
  name         = local.topic_name
  display_name = var.sns_display_name

  tags = merge(local.tags, {
    Name = local.topic_name
    Role = "cloudwatch-alert-topic"
  })
}

data "archive_file" "slack_notifier_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/slack_notifier.py"
  output_path = "${path.root}/.terraform/${local.lambda_function_name}.zip"
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    sid     = "AllowLambdaAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "${local.lambda_function_name}-role"
  description        = "IAM role for MoMent ${var.environment} CloudWatch alarm Slack notifier"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = merge(local.tags, {
    Name = "${local.lambda_function_name}-role"
    Role = "cloudwatch-slack-notifier"
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "lambda_secrets_read" {
  statement {
    sid    = "AllowReadSlackWebhookSecret"
    effect = "Allow"

    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue"
    ]

    resources = [
      aws_secretsmanager_secret.slack_webhook.arn
    ]
  }
}

resource "aws_iam_policy" "lambda_secrets_read" {
  name        = "${local.lambda_function_name}-secrets-read-policy"
  description = "Allow Slack notifier Lambda to read only the Slack webhook secret"
  policy      = data.aws_iam_policy_document.lambda_secrets_read.json

  tags = merge(local.tags, {
    Name = "${local.lambda_function_name}-secrets-read-policy"
    Role = "cloudwatch-slack-notifier-secrets-read"
  })
}

resource "aws_iam_role_policy_attachment" "lambda_secrets_read" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_secrets_read.arn
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${local.lambda_function_name}"
  retention_in_days = var.lambda_log_retention_days

  tags = merge(local.tags, {
    Name = "/aws/lambda/${local.lambda_function_name}"
    Role = "lambda-log-group"
  })
}

resource "aws_lambda_function" "slack_notifier" {
  function_name = local.lambda_function_name
  description   = "MoMent ${var.environment} CloudWatch alarm Slack notifier"

  role    = aws_iam_role.lambda.arn
  runtime = var.lambda_runtime
  handler = "slack_notifier.lambda_handler"

  filename         = data.archive_file.slack_notifier_zip.output_path
  source_code_hash = data.archive_file.slack_notifier_zip.output_base64sha256

  timeout     = var.lambda_timeout
  memory_size = var.lambda_memory_size

  environment {
    variables = {
      PROJECT_NAME              = var.project_name
      ENVIRONMENT               = var.environment
      SLACK_WEBHOOK_SECRET_NAME = aws_secretsmanager_secret.slack_webhook.name
    }
  }

  tags = merge(local.tags, {
    Name = local.lambda_function_name
    Role = "cloudwatch-slack-notifier"
  })

  depends_on = [
    aws_cloudwatch_log_group.lambda,
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy_attachment.lambda_secrets_read
  ]
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromAlertSns"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slack_notifier.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alerts.arn
}

resource "aws_sns_topic_subscription" "lambda" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.slack_notifier.arn

  depends_on = [
    aws_lambda_permission.allow_sns
  ]
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  for_each = var.enable_cloudwatch_alarms ? var.rds_instance_identifiers : {}

  alarm_name          = "${local.name_prefix}-rds-${each.key}-cpu-high"
  alarm_description   = "RDS CPUUtilization is high for ${each.value}."
  namespace           = "AWS/RDS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  threshold           = var.rds_cpu_high_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = each.value
  }

  alarm_actions = local.alarm_actions
  ok_actions    = local.ok_actions

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-rds-${each.key}-cpu-high"
    Role = "cloudwatch-alarm"
  })
}

resource "aws_cloudwatch_metric_alarm" "rds_free_storage_low" {
  for_each = var.enable_cloudwatch_alarms ? var.rds_instance_identifiers : {}

  alarm_name          = "${local.name_prefix}-rds-${each.key}-free-storage-low"
  alarm_description   = "RDS FreeStorageSpace is low for ${each.value}."
  namespace           = "AWS/RDS"
  metric_name         = "FreeStorageSpace"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  threshold           = var.rds_free_storage_low_threshold_bytes
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = each.value
  }

  alarm_actions = local.alarm_actions
  ok_actions    = local.ok_actions

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-rds-${each.key}-free-storage-low"
    Role = "cloudwatch-alarm"
  })
}

resource "aws_cloudwatch_metric_alarm" "redis_cpu_high" {
  for_each = var.enable_cloudwatch_alarms ? var.redis_replication_group_ids : {}

  alarm_name          = "${local.name_prefix}-redis-${each.key}-cpu-high"
  alarm_description   = "Redis CPUUtilization is high for ${each.value}."
  namespace           = "AWS/ElastiCache"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  threshold           = var.redis_cpu_high_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ReplicationGroupId = each.value
  }

  alarm_actions = local.alarm_actions
  ok_actions    = local.ok_actions

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-redis-${each.key}-cpu-high"
    Role = "cloudwatch-alarm"
  })
}

resource "aws_cloudwatch_metric_alarm" "redis_evictions" {
  for_each = var.enable_cloudwatch_alarms ? var.redis_replication_group_ids : {}

  alarm_name          = "${local.name_prefix}-redis-${each.key}-evictions"
  alarm_description   = "Redis Evictions detected for ${each.value}."
  namespace           = "AWS/ElastiCache"
  metric_name         = "Evictions"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  threshold           = var.redis_evictions_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ReplicationGroupId = each.value
  }

  alarm_actions = local.alarm_actions
  ok_actions    = local.ok_actions

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-redis-${each.key}-evictions"
    Role = "cloudwatch-alarm"
  })
}

resource "aws_cloudwatch_metric_alarm" "opensearch_cluster_red" {
  for_each = var.enable_cloudwatch_alarms ? var.opensearch_domain_names : {}

  alarm_name          = "${local.name_prefix}-opensearch-${each.key}-cluster-red"
  alarm_description   = "OpenSearch cluster status is red for ${each.value}."
  namespace           = "AWS/ES"
  metric_name         = "ClusterStatus.red"
  statistic           = "Maximum"
  period              = 300
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DomainName = each.value
    ClientId   = data.aws_caller_identity.current.account_id
  }

  alarm_actions = local.alarm_actions
  ok_actions    = local.ok_actions

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-opensearch-${each.key}-cluster-red"
    Role = "cloudwatch-alarm"
  })
}

resource "aws_cloudwatch_metric_alarm" "opensearch_cluster_yellow" {
  for_each = var.enable_cloudwatch_alarms ? var.opensearch_domain_names : {}

  alarm_name          = "${local.name_prefix}-opensearch-${each.key}-cluster-yellow"
  alarm_description   = "OpenSearch cluster status is yellow for ${each.value}."
  namespace           = "AWS/ES"
  metric_name         = "ClusterStatus.yellow"
  statistic           = "Maximum"
  period              = 300
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DomainName = each.value
    ClientId   = data.aws_caller_identity.current.account_id
  }

  alarm_actions = local.alarm_actions
  ok_actions    = local.ok_actions

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-opensearch-${each.key}-cluster-yellow"
    Role = "cloudwatch-alarm"
  })
}

resource "aws_cloudwatch_metric_alarm" "sqs_visible_messages_high" {
  for_each = var.enable_cloudwatch_alarms ? var.sqs_queue_names : {}

  alarm_name          = "${local.name_prefix}-sqs-${each.key}-visible-messages-high"
  alarm_description   = "SQS visible message count is high for ${each.value}."
  namespace           = "AWS/SQS"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  threshold           = var.sqs_visible_messages_high_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = each.value
  }

  alarm_actions = local.alarm_actions
  ok_actions    = local.ok_actions

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-sqs-${each.key}-visible-messages-high"
    Role = "cloudwatch-alarm"
  })
}

resource "aws_cloudwatch_metric_alarm" "sqs_dlq_visible_messages" {
  for_each = var.enable_cloudwatch_alarms ? var.sqs_dlq_names : {}

  alarm_name          = "${local.name_prefix}-sqs-${each.key}-dlq-visible-messages"
  alarm_description   = "SQS DLQ has visible messages for ${each.value}."
  namespace           = "AWS/SQS"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  threshold           = var.sqs_dlq_visible_messages_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = each.value
  }

  alarm_actions = local.alarm_actions
  ok_actions    = local.ok_actions

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-sqs-${each.key}-dlq-visible-messages"
    Role = "cloudwatch-alarm"
  })
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  for_each = var.enable_cloudwatch_alarms ? var.lambda_function_names : {}

  alarm_name          = "${local.name_prefix}-lambda-${each.key}-errors"
  alarm_description   = "Lambda Errors detected for ${each.value}."
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  threshold           = var.lambda_errors_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = each.value
  }

  alarm_actions = local.alarm_actions
  ok_actions    = local.ok_actions

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-lambda-${each.key}-errors"
    Role = "cloudwatch-alarm"
  })
}
