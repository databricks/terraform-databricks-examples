data "aws_caller_identity" "current" {}

locals {
  iam_role_name           = var.iam_role_name != "" ? var.iam_role_name : "${var.name_prefix}-uc"
  iam_policy_name         = var.iam_policy_name != "" ? var.iam_policy_name : "${local.iam_role_name}-policy"
  storage_credential_name = var.storage_credential_name != "" ? var.storage_credential_name : "${var.name_prefix}-storage-credential"

  role_arn        = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.iam_role_name}"
  credential_name = var.create_storage_credential ? databricks_storage_credential.this[0].name : var.existing_credential_name

  bucket_arns        = [for b in var.bucket_names : "arn:aws:s3:::${b}"]
  bucket_object_arns = [for b in var.bucket_names : "arn:aws:s3:::${b}/*"]

  # Base data-access statements (always present).
  base_statements = [
    {
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:DeleteObject",
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ]
      Resource = concat(local.bucket_arns, local.bucket_object_arns)
    },
    {
      Sid      = "AllowSelfAssume"
      Effect   = "Allow"
      Action   = ["sts:AssumeRole"]
      Resource = [local.role_arn]
    }
  ]

  # Managed file events (Automatic mode): lets Unity Catalog configure S3 bucket
  # notifications, create the SNS topic + SQS queue (csms-* prefixed) and subscribe
  # the queue to the topic. Scoped to the target buckets and the csms-* namespace.
  # Docs: https://docs.databricks.com/aws/en/connect/unity-catalog/cloud-storage/manage-external-locations
  file_event_statements = var.enable_file_events ? [
    {
      Sid    = "ManagedFileEventsSetupStatement"
      Effect = "Allow"
      Action = [
        "s3:GetBucketNotification",
        "s3:PutBucketNotification",
        "sns:ListSubscriptionsByTopic",
        "sns:GetTopicAttributes",
        "sns:SetTopicAttributes",
        "sns:CreateTopic",
        "sns:TagResource",
        "sns:Publish",
        "sns:Subscribe",
        "sqs:CreateQueue",
        "sqs:DeleteMessage",
        "sqs:ReceiveMessage",
        "sqs:SendMessage",
        "sqs:GetQueueUrl",
        "sqs:GetQueueAttributes",
        "sqs:SetQueueAttributes",
        "sqs:TagQueue",
        "sqs:ChangeMessageVisibility",
        "sqs:PurgeQueue"
      ]
      Resource = concat(local.bucket_arns, ["arn:aws:sqs:*:*:csms-*", "arn:aws:sns:*:*:csms-*"])
    },
    {
      Sid      = "ManagedFileEventsListStatement"
      Effect   = "Allow"
      Action   = ["sqs:ListQueues", "sqs:ListQueueTags", "sns:ListTopics"]
      Resource = ["arn:aws:sqs:*:*:csms-*", "arn:aws:sns:*:*:csms-*"]
    },
    {
      Sid      = "ManagedFileEventsTeardownStatement"
      Effect   = "Allow"
      Action   = ["sns:Unsubscribe", "sns:DeleteTopic", "sqs:DeleteQueue"]
      Resource = ["arn:aws:sqs:*:*:csms-*", "arn:aws:sns:*:*:csms-*"]
    }
  ] : []
}

# Self-assuming role trust policy required by Unity Catalog storage credentials:
#   1. The UC master role may assume this role, gated by the external ID.
#   2. The role may assume itself (paired with the AllowSelfAssume permission below).
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [var.uc_master_role_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.databricks_account_id]
    }
  }

  statement {
    sid     = "ExplicitSelfRoleAssumption"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:PrincipalArn"
      values   = [local.role_arn]
    }
  }
}

resource "aws_iam_policy" "this" {
  name = local.iam_policy_name

  policy = jsonencode({
    Version   = "2012-10-17"
    Id        = "${var.bucket_names[0]}-access"
    Statement = concat(local.base_statements, local.file_event_statements)
  })

  tags = merge(var.tags, {
    Name = local.iam_policy_name
  })
}

resource "aws_iam_role" "this" {
  name                = local.iam_role_name
  assume_role_policy  = data.aws_iam_policy_document.assume_role.json
  managed_policy_arns = [aws_iam_policy.this.arn]

  tags = merge(var.tags, {
    Name = local.iam_role_name
  })
}

# Give the IAM role/policy time to propagate before Unity Catalog validates the
# credential and external locations (avoids transient "non self-assuming" / 403s).
resource "time_sleep" "wait_iam" {
  count = var.iam_propagation_delay == "" ? 0 : 1

  create_duration = var.iam_propagation_delay

  triggers = {
    role_arn   = aws_iam_role.this.arn
    policy_arn = aws_iam_policy.this.arn
  }
}

resource "databricks_storage_credential" "this" {
  count = var.create_storage_credential ? 1 : 0

  name    = local.storage_credential_name
  comment = var.storage_credential_comment

  aws_iam_role {
    role_arn = aws_iam_role.this.arn
  }

  force_destroy = var.force_destroy ? true : null

  depends_on = [time_sleep.wait_iam]
}

resource "databricks_external_location" "this" {
  for_each = { for loc in var.external_locations : loc.name => loc }

  name            = each.value.name
  url             = each.value.url
  credential_name = local.credential_name
  comment         = each.value.comment
  read_only       = each.value.read_only

  enable_file_events = var.enable_file_events
  dynamic "file_event_queue" {
    for_each = var.enable_file_events ? [1] : []
    content {
      managed_sqs {}
    }
  }

  force_destroy = var.force_destroy ? true : null

  depends_on = [
    databricks_storage_credential.this,
    time_sleep.wait_iam,
  ]
}

resource "databricks_grants" "credential" {
  count = var.create_storage_credential && length(var.credential_grants) > 0 ? 1 : 0

  storage_credential = databricks_storage_credential.this[0].id

  dynamic "grant" {
    for_each = var.credential_grants
    content {
      principal  = grant.value.principal
      privileges = grant.value.privileges
    }
  }
}

resource "databricks_grants" "location" {
  for_each = length(var.location_grants) > 0 ? databricks_external_location.this : {}

  external_location = each.value.id

  dynamic "grant" {
    for_each = var.location_grants
    content {
      principal  = grant.value.principal
      privileges = grant.value.privileges
    }
  }
}
