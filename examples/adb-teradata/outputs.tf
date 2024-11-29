output "pip" {
  value = module.test_vm_instance.vm_public_ip
}

output "azure_resource_group_id" {
  description = "ID of the created Azure resource group"
  value       = azurerm_resource_group.this.id
}

output "workspace_id" {
  description = "The Databricks workspace ID"
  value       = azurerm_databricks_workspace.this.workspace_id
}

output "workspace_url" {
  description = "The Databricks workspace URL"
  value       = azurerm_databricks_workspace.this.workspace_url
}