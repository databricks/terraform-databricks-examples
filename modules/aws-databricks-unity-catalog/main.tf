locals {
  iam_role_name = "${var.prefix}-unity-catalog-metastore-access"
  iam_role_arn = "arn:aws:iam::${var.aws_account_id}:role/${local.iam_role_name}"
}

resource "databricks_metastore" "this" {
  name          = local.metastore_name
  region        = var.region
  owner         = var.unity_metastore_owner
  storage_root  = "s3://${aws_s3_bucket.metastore.id}/metastore"
  force_destroy = true
}

resource "databricks_metastore_data_access" "this" {
  metastore_id = databricks_metastore.this.id
  name         = local.iam_role_name
  aws_iam_role {
    role_arn = local.iam_role_arn
  }
  is_default = true
}

resource "databricks_metastore_assignment" "default_metastore" {
  count                = length(var.databricks_workspace_ids)
  workspace_id         = var.databricks_workspace_ids[count.index]
  metastore_id         = databricks_metastore.this.id
  default_catalog_name = "hive_metastore"
}
