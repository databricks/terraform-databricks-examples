output "databricks_azure_workspace_resource_id" {
  value = azurerm_databricks_workspace.this.id
}

output "workspace_url" {
  // The workspace URL which is of the format 'adb-{workspaceId}.{random}.azuredatabricks.net'
  // this is not named as DATABRICKS_HOST, because it affect authentication
  value = "https://${azurerm_databricks_workspace.this.workspace_url}/"
}

output "resource_group" {
  value = azurerm_resource_group.this.name
}
