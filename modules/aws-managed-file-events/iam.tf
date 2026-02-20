data "databricks_aws_unity_catalog_assume_role_policy" "this" {
  aws_account_id = var.aws_account_id
  role_name      = local.iam_role_name
  external_id    = databricks_storage_credential.file_events.aws_iam_role[0].external_id
}

data "databricks_aws_unity_catalog_policy" "this" {
  aws_account_id = var.aws_account_id
  bucket_name    = local.bucket_name
  role_name      = local.iam_role_name
}

resource "aws_iam_policy" "unity_catalog" {
  name   = "${var.prefix}-file-events-policy"
  policy = data.databricks_aws_unity_catalog_policy.this.json
  tags = merge(var.tags, {
    Name = "${var.prefix}-file-events IAM policy"
  })
}

resource "aws_iam_role" "file_events_access" {
  name               = local.iam_role_name
  assume_role_policy = data.databricks_aws_unity_catalog_assume_role_policy.this.json
  tags = merge(var.tags, {
    Name = "${var.prefix}-file-events IAM role"
  })
}

resource "aws_iam_role_policy_attachment" "unity_catalog" {
  role       = aws_iam_role.file_events_access.name
  policy_arn = aws_iam_policy.unity_catalog.arn
}

resource "time_sleep" "wait_role_creation" {
  depends_on      = [aws_iam_role.file_events_access]
  create_duration = "20s"
}
