# IAM Component
# Creates cross-account roles, Unity Catalog roles, and associated policies

# Databricks-generated Cross-Account Assume Role Policy
data "databricks_aws_assume_role_policy" "cross_account" {
  external_id = var.databricks_account_id
}

# Cross-Account Role for Databricks (Always created)
resource "aws_iam_role" "cross_account" {
  name               = local.iam_config.cross_account_role_name
  assume_role_policy = data.databricks_aws_assume_role_policy.cross_account.json

  tags = merge(local.common_tags, {
    Name    = local.iam_config.cross_account_role_name
    Purpose = "Databricks Cross-Account Access"
    Type    = "CrossAccount"
  })
}

# Databricks-generated Cross-Account Policy
# policy_type options: "managed" (default), "restricted", "customer-managed"
data "databricks_aws_crossaccount_policy" "cross_account" {
  policy_type = var.cross_account_policy_type
  pass_roles  = length(var.roles_to_assume) > 0 ? var.roles_to_assume : null
}

# Attach policy to cross-account role
resource "aws_iam_role_policy" "cross_account_inline" {
  name   = "databricks-cross-account-policy"
  role   = aws_iam_role.cross_account.id
  policy = data.databricks_aws_crossaccount_policy.cross_account.json
}

# Unity Catalog IAM role is always created.
# When external_id is not yet known, a basic trust policy (no ExternalId condition) is used.
# Once you have the external_id from the Databricks Account Console, set it and re-apply —
# Terraform will update the trust policy in-place without recreating the role.

data "databricks_aws_unity_catalog_assume_role_policy" "unity_catalog" {
  count          = var.external_id != null ? 1 : 0
  aws_account_id = local.account_id
  role_name      = local.iam_config.unity_catalog_role_name
  external_id    = var.external_id
}

# Fallback trust policy used when external_id is not yet available
data "aws_iam_policy_document" "unity_catalog_assume_role_basic" {
  count = var.external_id == null ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-14S5ZJVKOTYTL"]
    }
  }
}

resource "aws_iam_role" "unity_catalog" {
  name = local.iam_config.unity_catalog_role_name
  assume_role_policy = var.external_id != null ? (
    data.databricks_aws_unity_catalog_assume_role_policy.unity_catalog[0].json
    ) : (
    data.aws_iam_policy_document.unity_catalog_assume_role_basic[0].json
  )

  tags = merge(local.common_tags, {
    Name    = local.iam_config.unity_catalog_role_name
    Purpose = "Unity Catalog Metastore Access"
    Type    = "UnityCatalog"
  })
}

data "databricks_aws_unity_catalog_policy" "unity_catalog" {
  aws_account_id = local.account_id
  role_name      = local.iam_config.unity_catalog_role_name
  bucket_name    = var.create_metastore_bucket ? aws_s3_bucket.metastore[0].bucket : aws_s3_bucket.data.bucket
}

resource "aws_iam_role_policy" "unity_catalog_inline" {
  name   = "unity-catalog-metastore-policy"
  role   = aws_iam_role.unity_catalog.id
  policy = data.databricks_aws_unity_catalog_policy.unity_catalog.json
}

# Instance Profiles (optional)
resource "aws_iam_instance_profile" "databricks" {
  count = var.create_instance_profiles ? 1 : 0

  name = "${var.prefix}-databricks-instance-profile"
  role = aws_iam_role.cross_account.name

  tags = merge(local.common_tags, {
    Name    = "${var.prefix}-databricks-instance-profile"
    Purpose = "Databricks Compute Instance Profile"
  })
}

# Wait for IAM role propagation before dependent resources use the roles
resource "time_sleep" "iam_propagation_wait" {
  create_duration = "20s"

  depends_on = [
    aws_iam_role.cross_account,
    aws_iam_role_policy.cross_account_inline,
    aws_iam_role.unity_catalog,
    aws_iam_role_policy.unity_catalog_inline,
  ]
}
