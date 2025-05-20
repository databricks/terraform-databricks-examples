terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    databricks = {
      source = "databricks/databricks"
    }
  }
}

resource "aws_s3_bucket" "logdelivery" {
  bucket        = "${var.resource_prefix}-logdelivery"
  force_destroy = true
  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-logdelivery"
  })
}

resource "aws_s3_bucket_acl" "public_storage" {
  bucket     = aws_s3_bucket.logdelivery.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.public_storage]
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "public_storage" {
  bucket = aws_s3_bucket.logdelivery.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_public_access_block" "logdelivery" {
  bucket             = aws_s3_bucket.logdelivery.id
  ignore_public_acls = true
}

data "databricks_aws_assume_role_policy" "logdelivery" {
  external_id      = var.databricks_account_id
  for_log_delivery = true
}

resource "aws_s3_bucket_versioning" "logdelivery_versioning" {
  bucket = aws_s3_bucket.logdelivery.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_iam_role" "logdelivery" {
  name               = "${var.resource_prefix}-logdelivery"
  description        = "(${var.resource_prefix}) UsageDelivery role"
  assume_role_policy = data.databricks_aws_assume_role_policy.logdelivery.json
  tags               = var.tags
}

data "databricks_aws_bucket_policy" "logdelivery" {
  full_access_role = aws_iam_role.logdelivery.arn
  bucket           = aws_s3_bucket.logdelivery.bucket
}

resource "aws_s3_bucket_policy" "logdelivery" {
  bucket = aws_s3_bucket.logdelivery.id
  policy = data.databricks_aws_bucket_policy.logdelivery.json
}

resource "time_sleep" "wait_logdelivery" {
  depends_on = [
    aws_iam_role.logdelivery
  ]
  create_duration = "10s"
}

resource "databricks_mws_credentials" "log_writer" {
  credentials_name = "${var.resource_prefix}-Usage-Delivery"
  role_arn         = aws_iam_role.logdelivery.arn
  depends_on = [
    time_sleep.wait_logdelivery
  ]
}

resource "databricks_mws_storage_configurations" "log_bucket" {
  account_id                 = var.databricks_account_id
  storage_configuration_name = "${var.resource_prefix}-Usage-Logs"
  bucket_name                = aws_s3_bucket.logdelivery.bucket
}

resource "databricks_mws_log_delivery" "usage_logs" {
  account_id               = var.databricks_account_id
  credentials_id           = databricks_mws_credentials.log_writer.credentials_id
  storage_configuration_id = databricks_mws_storage_configurations.log_bucket.storage_configuration_id
  delivery_path_prefix     = "billable-usage"
  config_name              = "${var.resource_prefix}-Usage-Logs"
  log_type                 = "BILLABLE_USAGE"
  output_format            = "CSV"
}

resource "databricks_mws_log_delivery" "audit_logs" {
  account_id               = var.databricks_account_id
  credentials_id           = databricks_mws_credentials.log_writer.credentials_id
  storage_configuration_id = databricks_mws_storage_configurations.log_bucket.storage_configuration_id
  delivery_path_prefix     = "audit-logs"
  config_name              = "${var.resource_prefix}-Audit-Logs"
  log_type                 = "AUDIT_LOGS"
  output_format            = "JSON"
}
