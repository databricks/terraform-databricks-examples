output "rg_name" {
  value = azurerm_resource_group.this.name
}

output "rg_id" {
  value = azurerm_resource_group.this.id
}

output "vnet_name" {
  value = azurerm_virtual_network.this.name
}

output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "nsg_id" {
  value = azurerm_network_security_group.this.id
}

output "route_table_id" {
  value = azurerm_route_table.this.id
}

output "workspace_name" {
  value       = azurerm_databricks_workspace.this.name
  description = "Name of the Databricks workspace"
}

output "workspace_id" {
  value       = azurerm_databricks_workspace.this.id
  description = "ID of the Databricks workspace"
}

output "workspace_url" {
  value = azurerm_databricks_workspace.this.workspace_url
}

output "private_subnet_address_prefixes" {
  value = azurerm_subnet.private.address_prefixes
}

output "public_subnet_address_prefixes" {
  value = azurerm_subnet.public.address_prefixes
}
