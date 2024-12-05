output "arm_client_id" {
  value       = data.azurerm_client_config.current.client_id
  description = "***Depricated***. Client ID for current user/service principal"
}

output "arm_subscription_id" {
  value       = data.azurerm_client_config.current.subscription_id
  description = "***Depricated***. Azure Subscription ID for current user/service principal"
}

output "arm_tenant_id" {
  value       = data.azurerm_client_config.current.tenant_id
  description = "***Depricated***. Azure Tenant ID for current user/service principal"
}

output "azure_region" {
  value       = local.location
  description = "***Depricated***. Geo location of created resources"
}

output "resource_group" {
  value       = azurerm_resource_group.this.name
  description = "Name of created resource group"
}

output "my_ip_addr" {
  value       = local.ifconfig_co_json.ip
  description = "***Depricated***. IP address of caller"
}

output "test_vm_public_ip" {
  value       = azurerm_public_ip.testvmpublicip.ip_address
  description = "Public IP of the created virtual machine"
}

output "databricks_azure_workspace_resource_id" {
  description = "***Depricated***. The ID of the Databricks Workspace in the Azure management plane."
  value       = azurerm_databricks_workspace.this.id
}

output "workspace_url" {
  value       = "https://${azurerm_databricks_workspace.this.workspace_url}/"
  description = "The workspace URL which is of the format 'adb-{workspaceId}.{random}.azuredatabricks.net'"
}

output "azure_resource_group_id" {
  description = "ID of the created Azure resource group"
  value       = azurerm_resource_group.this.id
}

output "workspace_id" {
  description = "The Databricks workspace ID"
  value       = azurerm_databricks_workspace.this.workspace_id
}