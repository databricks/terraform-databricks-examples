#metastore creation
resource "databricks_metastore" "databricks-metastore" {
  name = var.metastore_name
  storage_root = format("abfss://%s@%s.dfs.core.windows.net/",
    "${var.metastore_storage_name}-container",
  var.metastore_storage_name)
  force_destroy = false
}

#give access to the access connector that will be assumed by Unity Catalog to access data
resource "databricks_metastore_data_access" "access-connector-data-access" {
  depends_on   = [databricks_metastore.databricks-metastore]
  metastore_id = databricks_metastore.databricks-metastore.id
  name         = var.access_connector_name
  azure_managed_identity {
    access_connector_id = var.access_connector_id
  }
  is_default = true
}
