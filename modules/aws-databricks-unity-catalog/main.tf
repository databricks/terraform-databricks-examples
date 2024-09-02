locals {
  iam_role_name = "${var.prefix}-unity-catalog-metastore-access"
  iam_role_arn = "arn:aws:iam::${var.aws_account_id}:role/${local.iam_role_name}"
}

resource "databricks_storage_credential" "this" {
  name = "unity_catalog_storage_credential"
  aws_iam_role {
    role_arn = local.iam_role_arn
  }
  comment = "Managed by TF"
  skip_validation = true  # the IAM role is not yet created
}

resource "databricks_metastore" "this" {
  name          = local.metastore_name
  region        = var.region
  owner         = var.unity_metastore_owner
  storage_root  = "s3://${aws_s3_bucket.metastore.id}/metastore"
  storage_root_credential_id = databricks_storage_credential.this.id
  force_destroy = true

  # The IAM role referenced in the storage credential must exist before creating the metastore.
  depends_on = [ aws_iam_role.metastore_data_access ]
}

resource "databricks_metastore_data_access" "this" {
  metastore_id = databricks_metastore.this.id
  name         = aws_iam_role.metastore_data_access.name
  aws_iam_role {
    role_arn = aws_iam_role.metastore_data_access.arn
  }
  is_default = true
  depends_on = [
    resource.time_sleep.wait_role_creation
  ]
}

# Sleeping for 20s to wait for the workspace to enable identity federation
resource "time_sleep" "wait_role_creation" {
  depends_on = [
    resource.aws_iam_role.metastore_data_access,
    resource.databricks_metastore.this
  ]
  create_duration = "20s"
}

resource "databricks_metastore_assignment" "default_metastore" {
  count                = length(var.databricks_workspace_ids)
  workspace_id         = var.databricks_workspace_ids[count.index]
  metastore_id         = databricks_metastore.this.id
  default_catalog_name = "hive_metastore"
}
