data "databricks_aws_unity_catalog_assume_role_policy" "this" {
  aws_account_id = var.aws_account_id
  role_name      = local.iam_role_name
  external_id    = databricks_storage_credential.file_events.aws_iam_role[0].external_id
}

data "aws_iam_policy_document" "s3_access" {
  statement {
    sid    = "S3ObjectAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [
      "arn:aws:s3:::${local.bucket_name}",
      "arn:aws:s3:::${local.bucket_name}/*"
    ]
  }

  statement {
    sid    = "S3BucketNotifications"
    effect = "Allow"
    actions = [
      "s3:GetBucketNotification",
      "s3:PutBucketNotification"
    ]
    resources = [
      "arn:aws:s3:::${local.bucket_name}"
    ]
  }
}

data "aws_iam_policy_document" "managed_file_events" {
  statement {
    sid    = "ManagedFileEventsSetupStatement"
    effect = "Allow"
    actions = [
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
    resources = [
      "arn:aws:s3:::${local.bucket_name}",
      "arn:aws:sqs:*:*:csms-*",
      "arn:aws:sns:*:*:csms-*"
    ]
  }

  statement {
    sid    = "ManagedFileEventsListStatement"
    effect = "Allow"
    actions = [
      "sqs:ListQueues",
      "sqs:ListQueueTags",
      "sns:ListTopics"
    ]
    resources = [
      "arn:aws:sqs:*:*:csms-*",
      "arn:aws:sns:*:*:csms-*"
    ]
  }

  statement {
    sid    = "ManagedFileEventsTeardownStatement"
    effect = "Allow"
    actions = [
      "sns:Unsubscribe",
      "sns:DeleteTopic",
      "sqs:DeleteQueue"
    ]
    resources = [
      "arn:aws:sqs:*:*:csms-*",
      "arn:aws:sns:*:*:csms-*"
    ]
  }
}

data "aws_iam_policy_document" "self_assume" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = [local.iam_role_arn]
  }
}

resource "aws_iam_policy" "s3_access" {
  name   = "${var.prefix}-file-events-s3-policy"
  policy = data.aws_iam_policy_document.s3_access.json
  tags = merge(var.tags, {
    Name = "${var.prefix}-file-events S3 policy"
  })
}

resource "aws_iam_policy" "managed_file_events" {
  name   = "${var.prefix}-file-events-managed-policy"
  policy = data.aws_iam_policy_document.managed_file_events.json
  tags = merge(var.tags, {
    Name = "${var.prefix}-file-events managed file events policy"
  })
}

resource "aws_iam_policy" "self_assume" {
  name   = "${var.prefix}-file-events-self-assume-policy"
  policy = data.aws_iam_policy_document.self_assume.json
  tags = merge(var.tags, {
    Name = "${var.prefix}-file-events self-assume policy"
  })
}

resource "aws_iam_role" "file_events_access" {
  name               = local.iam_role_name
  assume_role_policy = data.databricks_aws_unity_catalog_assume_role_policy.this.json
  tags = merge(var.tags, {
    Name = "${var.prefix}-file-events IAM role"
  })
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.file_events_access.name
  policy_arn = aws_iam_policy.s3_access.arn
}

resource "aws_iam_role_policy_attachment" "managed_file_events" {
  role       = aws_iam_role.file_events_access.name
  policy_arn = aws_iam_policy.managed_file_events.arn
}

resource "aws_iam_role_policy_attachment" "self_assume" {
  role       = aws_iam_role.file_events_access.name
  policy_arn = aws_iam_policy.self_assume.arn
}

resource "time_sleep" "wait_role_creation" {
  depends_on      = [aws_iam_role.file_events_access]
  create_duration = "20s"
}
