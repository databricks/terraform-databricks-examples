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

resource "null_resource" "previous" {}

// Wait to prevent race condition between IAM role and external location validation
resource "time_sleep" "wait_60_seconds" {
  depends_on      = [null_resource.previous]
  create_duration = "60s"
}

resource "aws_s3_bucket" "uc_demo" {
  bucket        = var.s3_bucket_name
  force_destroy = true // delete all objects in the bucket before deleting the bucket
}

resource "aws_s3_bucket_versioning" "uc_demo_versioning" {
  bucket = aws_s3_bucket.uc_demo.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_public_access_block" "uc_demo" {
  bucket                  = aws_s3_bucket.uc_demo.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.uc_demo]
}

data "aws_caller_identity" "current" {}

data "databricks_aws_unity_catalog_assume_role_policy" "uc_policy" {
  aws_account_id = data.aws_caller_identity.current.account_id
  role_name      = var.iam_role_name
  external_id    = databricks_storage_credential.uc_demo.aws_iam_role[0].external_id
}

data "databricks_aws_unity_catalog_policy" "uc_demo" {
  aws_account_id = data.aws_caller_identity.current.account_id
  bucket_name    = aws_s3_bucket.uc_demo.id
  role_name      = var.iam_role_name
}

resource "aws_iam_policy" "external_data_access" {
  policy = data.databricks_aws_unity_catalog_policy.uc_demo.json
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  policy_arn = aws_iam_policy.external_data_access.arn
  role       = aws_iam_role.uc_demo.name
}

resource "aws_iam_role" "uc_demo" { // create IAM role after storage credential is created
  name               = var.iam_role_name
  assume_role_policy = data.databricks_aws_unity_catalog_assume_role_policy.uc_policy.json
  depends_on         = [databricks_storage_credential.uc_demo]
}

resource "databricks_storage_credential" "uc_demo" {
  name = var.storage_credential_name
  //cannot reference aws_iam_role directly, as it will create circular dependency
  aws_iam_role {
    role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.iam_role_name}"
  }
  comment        = "Managed by Terraform"
  force_destroy  = true
  isolation_mode = "ISOLATION_MODE_ISOLATED"
}

resource "databricks_external_location" "uc_demo" {
  name            = var.external_location_name
  url             = "s3://${aws_s3_bucket.uc_demo.bucket}"
  credential_name = databricks_storage_credential.uc_demo.name
  comment         = "Managed by Terraform"
  isolation_mode  = "ISOLATION_MODE_ISOLATED"
  skip_validation = true
  depends_on      = [aws_iam_role_policy_attachment.policy_attachment, time_sleep.wait_60_seconds]
}

resource "databricks_catalog" "uc_demo" {
  name           = var.catalog_name
  storage_root   = "s3://${aws_s3_bucket.uc_demo.bucket}/${var.catalog_name}/"
  isolation_mode = "ISOLATED"
  comment        = "Default isolated catalog dedicated for this workspace, managed by Terraform"
  depends_on     = [databricks_external_location.uc_demo]
}

resource "databricks_schema" "uc_demo" {
  catalog_name = databricks_catalog.uc_demo.id
  name         = "default"
  comment      = "Default schema for ${var.catalog_name}, managed by Terraform"
}
