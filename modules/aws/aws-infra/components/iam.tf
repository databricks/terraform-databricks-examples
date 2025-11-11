# IAM Component
# Creates cross-account roles, Unity Catalog roles, and associated policies

# Databricks-generated Cross-Account Assume Role Policy
data "databricks_aws_assume_role_policy" "cross_account" {
  external_id = var.databricks_config.account_id
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

# Cross-Account Role Policy 
data "aws_iam_policy_document" "cross_account_policy" {
  
  # Databricks standard permissions
  statement {
    sid    = "Databricks"
    effect = "Allow"
    
    actions = [
      "ec2:AssociateIamInstanceProfile",
      "ec2:AttachVolume",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CancelSpotInstanceRequests",
      "ec2:CreateKeyPair",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:DeleteKeyPair",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteTags",
      "ec2:DeleteVolume",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInstanceAttribute",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeInstances",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeKeyPairs",
      "ec2:DescribeNetworkAcls",
      "ec2:DescribePrefixLists",
      "ec2:DescribeReservedInstancesOfferings",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSpotInstanceRequests",
      "ec2:DescribeSpotPriceHistory",
      "ec2:DescribeSubnets",
      "ec2:DescribeVolumes",
      "ec2:DescribeVpcAttribute",
      "ec2:DescribeVpcs",
      "ec2:DetachVolume",
      "ec2:DisassociateIamInstanceProfile",
      "ec2:ModifyVpcAttribute",
      "ec2:ReplaceIamInstanceProfileAssociation",
      "ec2:RequestSpotInstances",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:RunInstances",
      "ec2:TerminateInstances"
    ]
    
    resources = ["*"]
  }
  
  # IAM permissions for instance profiles (only if roles_to_assume is populated)
  dynamic "statement" {
    for_each = length(var.roles_to_assume) > 0 ? [1] : []
    
    content {
      sid    = "AllowPassRoleInstanceProfile"
      effect = "Allow"
      
      actions = [
        "iam:PassRole"
      ]
      
      resources = concat(
        # Allow passing the cross-account role itself
        ["arn:aws:iam::${local.account_id}:role/${local.iam_config.cross_account_role_name}"],
        # Allow passing additional roles specified in variables
        var.roles_to_assume
      )
    }
  }
}

# Attach policy to cross-account role
resource "aws_iam_role_policy" "cross_account_inline" {
  name   = "databricks-cross-account-policy"
  role   = aws_iam_role.cross_account.id
  policy = data.aws_iam_policy_document.cross_account_policy.json
}

# Databricks-generated Unity Catalog Assume Role Policy
data "databricks_aws_unity_catalog_assume_role_policy" "unity_catalog" {
  aws_account_id = local.account_id
  role_name      = local.iam_config.unity_catalog_role_name
  external_id    = var.external_id
}

# Unity Catalog Role (Always created)
resource "aws_iam_role" "unity_catalog" {
  name               = local.iam_config.unity_catalog_role_name
  assume_role_policy = data.databricks_aws_unity_catalog_assume_role_policy.unity_catalog.json
  
  tags = merge(local.common_tags, {
    Name    = local.iam_config.unity_catalog_role_name
    Purpose = "Unity Catalog Metastore Access"
    Type    = "UnityCatalog"
  })
}

# Databricks-generated Unity Catalog IAM Policy
data "databricks_aws_unity_catalog_policy" "unity_catalog" {
  aws_account_id = local.account_id
  role_name      = local.iam_config.unity_catalog_role_name
  bucket_name    = var.create_metastore_bucket ? aws_s3_bucket.metastore[0].bucket : ""
}

# Attach policy to Unity Catalog role
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

# Wait for IAM role propagation (Always runs since roles are always created)
resource "time_sleep" "iam_propagation_wait" {
  create_duration = "20s"
  
  depends_on = [
    aws_iam_role.cross_account,
    aws_iam_role.unity_catalog,
    aws_iam_role_policy.cross_account_inline,
    aws_iam_role_policy.unity_catalog_inline
  ]
}
