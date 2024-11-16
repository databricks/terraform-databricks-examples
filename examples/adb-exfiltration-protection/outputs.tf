output "azure_resource_group_id" {
  description = "ID of the created Azure resource group"
  value       = module.adb-exfiltration-protection.azure_resource_group_id
}

output "workspace_id" {
  description = "The Databricks workspace ID"
  value       = module.adb-exfiltration-protection.workspace_id
}

output "workspace_url" {
  description = "The Databricks workspace URL"
  value       = module.adb-exfiltration-protection.workspace_url
}