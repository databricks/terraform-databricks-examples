output "dp_databricks_azure_workspace_resource_id" {
  description = "The ID of the Databricks Workspace in the Azure management plane."
  value       = azurerm_databricks_workspace.dp_workspace.id
}

output "dp_workspace_url" {
  value       = "https://${azurerm_databricks_workspace.dp_workspace.workspace_url}/"
  description = "The workspace URL which is of the format 'adb-{workspaceId}.{random}.azuredatabricks.net'"
}

output "test_vm_password" {
  description = "Password to access the Test VM, use `terraform output -json test_vm_password` to get the password value"
  value       = azurerm_windows_virtual_machine.testvm.admin_password
  sensitive   = true
}
