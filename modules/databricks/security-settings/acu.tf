resource "databricks_automatic_cluster_update_workspace_setting" "this" {
  count = var.enable_automatic_cluster_update ? 1 : 0

  automatic_cluster_update_workspace {
    enabled = true
  }
}
