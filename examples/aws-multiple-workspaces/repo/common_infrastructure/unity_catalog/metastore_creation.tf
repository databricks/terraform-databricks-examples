resource "null_resource" "previous" {}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [null_resource.previous]

  create_duration = "30s"
}

// Unity Catalog Trust Policy
data "aws_iam_policy_document" "passrole_for_unity_catalog" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-14S5ZJVKOTYTL"]
      type        = "AWS"
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
      identifiers = ["arn:aws:iam::${var.aws_account_id}:root"]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::${var.aws_account_id}:role/${var.resource_prefix}-unity-catalog"]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.databricks_account_id]
    }
  }
}

// Unity Catalog Role
resource "aws_iam_role" "unity_catalog_role" {
  name               = "${var.resource_prefix}-unity-catalog"
  assume_role_policy = data.aws_iam_policy_document.passrole_for_unity_catalog.json
  tags = {
    Name = "${var.resource_prefix}-unity-catalog"
  }
}

// Unity Catalog IAM Policy
data "aws_iam_policy_document" "unity_catalog_iam_policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      "arn:aws:s3:::${var.ucname}/*",
      "arn:aws:s3:::${var.ucname}"
    ]

    effect = "Allow"
  }

  statement {
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::${var.aws_account_id}:role/${var.resource_prefix}-unity-catalog"]
    effect    = "Allow"
  }
}

// Unity Catalog Policy
resource "aws_iam_role_policy" "unity_catalog" {
  name   = "${var.resource_prefix}-unity-catalog-policy"
  role   = aws_iam_role.unity_catalog_role.id
  policy = data.aws_iam_policy_document.unity_catalog_iam_policy.json
}


// Unity Catalog S3
resource "aws_s3_bucket" "unity_catalog_bucket" {
  bucket        = var.ucname
  force_destroy = true
  tags = {
    Name = var.ucname
  }
}

resource "aws_s3_bucket_versioning" "unity_catalog_versioning" {
  bucket = aws_s3_bucket.unity_catalog_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "unity_catalog" {
  bucket = aws_s3_bucket.unity_catalog_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "unity_catalog" {
  bucket                  = aws_s3_bucket.unity_catalog_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.unity_catalog_bucket]
}

// Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/unity-catalog

// Metastore
resource "databricks_metastore" "this" {
  name          = "unity-catalog-${var.resource_prefix}"
  region        = var.region
  storage_root  = "s3://${var.ucname}/"
  force_destroy = true
}

// Metastore Data Access
resource "databricks_metastore_data_access" "this" {
  metastore_id = databricks_metastore.this.id
  name         = aws_iam_role.unity_catalog_role.name
  aws_iam_role {
    role_arn = aws_iam_role.unity_catalog_role.arn
  }
  is_default = true
  depends_on = [
    databricks_metastore.this, aws_iam_role.unity_catalog_role, time_sleep.wait_30_seconds
  ]
}