resource "databricks_metastore" "this" {
  name          = local.metastore_name
  region        = var.region
  owner         = var.unity_metastore_owner
  storage_root  = "s3://${aws_s3_bucket.metastore.id}/metastore"
  force_destroy = true
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
