output "adb_ow_main_ws_url" {
  value = var.use_existing_ws ? one(data.azurerm_databricks_workspace.adb-existing-ws[*].workspace_url) : one(azurerm_databricks_workspace.adb-new-ws[*].workspace_url)
}

output "latest_lts" {
  value = data.databricks_spark_version.latest_lts.id
}