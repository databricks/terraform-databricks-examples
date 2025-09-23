output "azure_resource_group_id" {
  description = "ID of the created Azure resource group"
  value       = local.rg_id
}

output "workspace_id" {
  description = "The Databricks workspace ID"
  value       = azurerm_databricks_workspace.this.workspace_id
}

output "workspace_url" {
  description = "The Databricks workspace URL"
  value       = azurerm_databricks_workspace.this.workspace_url
}

output "arm_client_id" {
  description = "**Depricated**"
  value       = data.azurerm_client_config.current.client_id
}

output "arm_subscription_id" {
  description = "**Depricated**"
  value       = data.azurerm_client_config.current.subscription_id
}

output "arm_tenant_id" {
  description = "**Depricated**"
  value       = data.azurerm_client_config.current.tenant_id
}

output "azure_region" {
  description = "**Depricated**"
  value       = local.location
}

output "resource_group" {
  description = "**Depricated**"
  value       = local.rg_name
}