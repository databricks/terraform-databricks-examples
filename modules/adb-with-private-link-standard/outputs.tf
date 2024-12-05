output "dp_databricks_azure_workspace_resource_id" {
  description = "**Depricated** The ID of the Databricks Workspace in the Azure management plane."
  value       = azurerm_databricks_workspace.dp_workspace.id
}

output "dp_workspace_url" {
  value       = "https://${azurerm_databricks_workspace.dp_workspace.workspace_url}/"
  description = "**Depricated** Renamed to `workspace_url` to align with naming used in other modules"
}

output "test_vm_public_ip" {
  value       = azurerm_public_ip.testvmpublicip.ip_address
  description = "Public IP of the created virtual machine"
}

output "test_vm_password" {
  description = "Password to access the Test VM, use `terraform output -json test_vm_password` to get the password value"
  value       = azurerm_windows_virtual_machine.testvm.admin_password
  sensitive   = true
}

output "workspace_url" {
  value       = "https://${azurerm_databricks_workspace.dp_workspace.workspace_url}/"
  description = "The workspace URL which is of the format 'adb-{workspaceId}.{random}.azuredatabricks.net'"
}

output "workspace_id" {
  description = "The Databricks workspace ID"
  value       = azurerm_databricks_workspace.dp_workspace.workspace_id
}