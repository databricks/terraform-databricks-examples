resource "aws_kms_key" "workspace_storage_cmk" {
  policy = data.aws_iam_policy_document.databricks_storage_cmk.json
  tags = {
    Name = "${var.resource_prefix}-${var.region}-ws-cmk"
  }
}

resource "aws_kms_alias" "workspace_storage_cmk_alias" {
  name_prefix   = "alias/${var.resource_prefix}-workspace-storage"
  target_key_id = aws_kms_key.workspace_storage_cmk.key_id
}

resource "aws_kms_key" "managed_services_cmk" {
  policy = data.aws_iam_policy_document.databricks_managed_services_cmk.json
  tags = {
    Name = "${var.resource_prefix}-${var.region}-ms-cmk"
  }
}

resource "aws_kms_alias" "managed_services_cmk_alias" {
  name_prefix   = "alias/${var.resource_prefix}-managed-services"
  target_key_id = aws_kms_key.managed_services_cmk.key_id
}
