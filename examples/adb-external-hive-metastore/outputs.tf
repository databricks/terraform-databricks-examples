output "databricks_azure_workspace_resource_id" {
  description = "**Depricated**"
  value       = azurerm_databricks_workspace.this.id
}

output "resource_group" {
  description = "**Depricated**"
  value       = azurerm_resource_group.this.name
}

output "azure_resource_group_id" {
  description = "The Azure resource group ID"
  value       = azurerm_resource_group.this.id
}

output "workspace_id" {
  description = "The Databricks workspace ID"
  value       = azurerm_databricks_workspace.this.workspace_id
}

output "workspace_url" {
  description = "The Databricks workspace URL"
  value       = "https://${azurerm_databricks_workspace.this.workspace_url}/"
}

output "keyvault_id" {
  description = "The Azure KeyVault ID"
  value       = azurerm_key_vault.akv1.id
}