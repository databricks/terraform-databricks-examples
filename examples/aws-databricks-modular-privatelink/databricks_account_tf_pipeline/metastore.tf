resource "databricks_metastore" "this" {
  count         = var.deploy_metastore == "true" ? 1 : 0
  provider      = databricks.mws
  owner         = var.metastore_admin_group_name
  name          = "${var.region}-uc-metastore"
  region        = var.region
  force_destroy = true
}
