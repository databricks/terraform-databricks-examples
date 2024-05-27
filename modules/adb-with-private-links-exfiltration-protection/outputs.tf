output "arm_client_id" {
  value       = data.azurerm_client_config.current.client_id
  description = "Client ID for current user/service principal"
}

output "arm_subscription_id" {
  value       = data.azurerm_client_config.current.subscription_id
  description = "Azure Subscription ID for current user/service principal"
}

output "arm_tenant_id" {
  value       = data.azurerm_client_config.current.tenant_id
  description = "Azure Tenant ID for current user/service principal"
}

output "azure_region" {
  value       = local.location
  description = "Geo location of created resources"
}

output "resource_group" {
  value       = azurerm_resource_group.this.name
  description = "Name of created resource group"
}

output "my_ip_addr" {
  value       = local.ifconfig_co_json.ip
  description = "IP address of caller"
}

output "test_vm_public_ip" {
  value       = azurerm_public_ip.testvmpublicip.ip_address
  description = "Public IP of the created virtual machine"
}

output "databricks_azure_workspace_resource_id" {
  description = "The ID of the Databricks Workspace in the Azure management plane."
  value       = azurerm_databricks_workspace.this.id
}

output "workspace_url" {
  value       = "https://${azurerm_databricks_workspace.this.workspace_url}/"
  description = "The workspace URL which is of the format 'adb-{workspaceId}.{random}.azuredatabricks.net'"
}
