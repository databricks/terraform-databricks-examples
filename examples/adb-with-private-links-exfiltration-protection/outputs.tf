output "azure_resource_group_id" {
  description = "ID of the created Azure resource group"
  value       = module.adb_with_private_links_exfiltration_protection.azure_resource_group_id
}

output "workspace_id" {
  description = "The Databricks workspace ID"
  value       = module.adb_with_private_links_exfiltration_protection.workspace_id
}

output "workspace_url" {
  description = "The Databricks workspace URL"
  value       = module.adb_with_private_links_exfiltration_protection.workspace_url
}

output "test_vm_public_ip" {
  description = "Public IP of the Azure VM created for testing"
  value       = module.adb_with_private_links_exfiltration_protection.test_vm_public_ip
}

output "workspace_azure_resource_id" {
  description = "***Depricated***. Use workspace_id"
  value       = module.adb_with_private_links_exfiltration_protection.databricks_azure_workspace_resource_id
}

output "resource_group" {
  description = "***Depricated***. Use azure_resource_group_id instead"
  value       = module.adb_with_private_links_exfiltration_protection.resource_group
}