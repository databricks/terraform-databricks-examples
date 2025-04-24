# CMK For Managed Services (notebook, sql queries, etc)
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "databricks_managed_services_cmk" {
  version = "2012-10-17"
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
  statement {
    sid    = "Allow Databricks to use KMS key for control plane managed services"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::414351767826:root"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt"
    ]
    resources = ["*"]
  }
}

resource "aws_kms_key" "managed_services_customer_managed_key" {
  policy = data.aws_iam_policy_document.databricks_managed_services_cmk.json
}

resource "aws_kms_alias" "managed_services_customer_managed_key_alias" {
  name          = "alias/managed-services-customer-managed-key-alias-${var.resource_prefix}"
  target_key_id = aws_kms_key.managed_services_customer_managed_key.key_id
}

resource "databricks_mws_customer_managed_keys" "managed_services" {
  provider   = databricks.mws
  account_id = var.databricks_account_id
  aws_key_info {
    key_arn   = aws_kms_key.managed_services_customer_managed_key.arn
    key_alias = aws_kms_alias.managed_services_customer_managed_key_alias.name
  }
  use_cases = ["MANAGED_SERVICES"]
}

# CMK For DBFS and EBS
data "aws_iam_policy_document" "databricks_storage_cmk" {
  version = "2012-10-17"
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
  statement {
    sid    = "Allow Databricks to use KMS key for DBFS"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::414351767826:root"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "Allow Databricks to use KMS key for DBFS (Grants)"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::414351767826:root"]
    }
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    resources = ["*"]
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
  statement {
    sid    = "Allow Databricks to use KMS key for EBS"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [for i in module.workspace_credential : i.cross_account_role_arn] // a list of workspace cross account iam roles
    }
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:CreateGrant",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    condition {
      test     = "ForAnyValue:StringLike"
      variable = "kms:ViaService"
      values   = ["ec2.*.amazonaws.com"]
    }
  }
}

resource "aws_kms_key" "storage_customer_managed_key" {
  policy = data.aws_iam_policy_document.databricks_storage_cmk.json
}

resource "aws_kms_alias" "storage_customer_managed_key_alias" {
  name          = "alias/storage-customer-managed-key-alias-${var.resource_prefix}"
  target_key_id = aws_kms_key.storage_customer_managed_key.key_id
}

resource "databricks_mws_customer_managed_keys" "storage" {
  provider   = databricks.mws
  account_id = var.databricks_account_id
  aws_key_info {
    key_arn   = aws_kms_key.storage_customer_managed_key.arn
    key_alias = aws_kms_alias.storage_customer_managed_key_alias.name
  }
  use_cases = ["STORAGE"]
}
