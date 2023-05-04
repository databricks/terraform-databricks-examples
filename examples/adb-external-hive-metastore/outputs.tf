output "databricks_azure_workspace_resource_id" {
  // The ID of the Databricks Workspace in the Azure management plane.
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

output "vault_uri" {
  value = azurerm_key_vault.akv1.vault_uri
}

output "key_vault_id" {
  value = azurerm_key_vault.akv1.id
}

output "metastoreserver" {
  value = azurerm_mssql_server.metastoreserver.name
}

output "metastoredbname" {
  value = azurerm_mssql_database.sqlmetastore.name
}
