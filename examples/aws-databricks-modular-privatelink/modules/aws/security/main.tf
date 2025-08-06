# Security Group for Databricks VPC
resource "aws_security_group" "databricks" {
  vpc_id      = var.vpc_id
  name        = "databricks-vpc-security-group-${var.resource_prefix}"
  description = "Databricks VPC security group for ${var.resource_prefix}"

  dynamic "ingress" {
    for_each = var.sg_ingress_protocol
    content {
      from_port = 0
      to_port   = 65535
      protocol  = ingress.value
      self      = true
    }
  }

  dynamic "egress" {
    for_each = var.sg_egress_protocol
    content {
      from_port = 0
      to_port   = 65535
      protocol  = egress.value
      self      = true
    }
  }

  dynamic "egress" {
    for_each = var.sg_egress_ports
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-dataplane-sg"
  })
}

# Security Group for PrivateLink
resource "aws_security_group" "privatelink" {
  vpc_id = var.vpc_id

  ingress {
    description     = "Inbound rules"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.databricks.id]
  }

  ingress {
    description     = "Inbound rules"
    from_port       = 6666
    to_port         = 6666
    protocol        = "tcp"
    security_groups = [aws_security_group.databricks.id]
  }

  egress {
    description     = "Outbound rules"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.databricks.id]
  }

  egress {
    description     = "Outbound rules"
    from_port       = 6666
    to_port         = 6666
    protocol        = "tcp"
    security_groups = [aws_security_group.databricks.id]
  }

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-privatelink-sg"
  })
}

# KMS Keys for Databricks
data "aws_iam_policy_document" "databricks_managed_services_cmk" {
  version = "2012-10-17"
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [var.cmk_admin]
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

data "aws_iam_policy_document" "databricks_storage_cmk" {
  version = "2012-10-17"
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [var.cmk_admin]
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
      identifiers = [var.cross_account_role_arn]
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

resource "aws_kms_key" "workspace_storage_cmk" {
  policy = data.aws_iam_policy_document.databricks_storage_cmk.json
  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-${var.region}-ws-cmk"
  })
}

resource "aws_kms_alias" "workspace_storage_cmk_alias" {
  name_prefix   = "alias/${var.resource_prefix}-workspace-storage"
  target_key_id = aws_kms_key.workspace_storage_cmk.key_id
}

resource "aws_kms_key" "managed_services_cmk" {
  policy = data.aws_iam_policy_document.databricks_managed_services_cmk.json
  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-${var.region}-ms-cmk"
  })
}

resource "aws_kms_alias" "managed_services_cmk_alias" {
  name_prefix   = "alias/${var.resource_prefix}-managed-services"
  target_key_id = aws_kms_key.managed_services_cmk.key_id
}