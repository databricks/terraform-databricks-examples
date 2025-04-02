output "rg_name" {
  value       = local.rg_name
  description = "**Depricated** Name of the resource group"
}

output "rg_id" {
  value       = local.rg_id
  description = "**Depricated** ID of the resource group"
}

output "vnet_id" {
  value       = azurerm_virtual_network.this.id
  description = "**Depricated** ID of the new Vnet"
}

output "nsg_id" {
  value       = azurerm_network_security_group.this.id
  description = "**Depricated** ID of the new NSG"
}

output "route_table_id" {
  value       = azurerm_route_table.this.id
  description = "**Depricated** ID of the new route table"
}

output "workspace_name" {
  value       = azurerm_databricks_workspace.this.name
  description = "**Depricated** Name of the Databricks workspace"
}

output "workspace_id" {
  value       = azurerm_databricks_workspace.this.workspace_id
  description = "ID of the Databricks workspace"
}

output "workspace_resource_id" {
  value       = azurerm_databricks_workspace.this.id
  description = "**Depricated** ID of the Databricks workspace resource"
}

output "workspace_url" {
  value       = "https://${azurerm_databricks_workspace.this.workspace_url}"
  description = "URL of the Databricks workspace"
}

output "azure_resource_group_id" {
  description = "ID of the created or existing Azure resource group"
  value       = local.rg_id
}

output "azure_resource_group_location" {
  description = "Location of the created or existing Azure resource group"
  value       = local.rg_id
}
