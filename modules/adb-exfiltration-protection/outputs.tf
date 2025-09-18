output "databricks_azure_workspace_resource_id" {
  description = "**Deprecated** The ID of the Databricks Workspace in the Azure management plane"
  value       = azurerm_databricks_workspace.this.id
}

output "arm_client_id" {
  description = "**Deprecated**"
  value       = data.azurerm_client_config.current.client_id
}

output "arm_subscription_id" {
  description = "**Deprecated**"
  value       = data.azurerm_client_config.current.subscription_id
}

output "arm_tenant_id" {
  description = "**Deprecated**"
  value       = data.azurerm_client_config.current.tenant_id
}

output "azure_region" {
  description = "**Deprecated**"
  value       = local.location
}

output "resource_group" {
  description = "**Deprecated**"
  value       = local.rg_name
}

output "workspace_url" {
  description = "The Databricks workspace URL"
  value       = "https://${azurerm_databricks_workspace.this.workspace_url}/"
}

output "azure_resource_group_id" {
  description = "ID of the created Azure resource group"
  value       = local.rg_id
}

output "workspace_id" {
  description = "The Databricks workspace ID"
  value       = azurerm_databricks_workspace.this.workspace_id
}