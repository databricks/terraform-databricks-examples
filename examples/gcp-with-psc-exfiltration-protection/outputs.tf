
output "workspace_url" {
  value       = module.gcp_with_data_exfiltration_protection.workspace_url
  description = "The workspace URL which is of the format '{workspaceId}.{random}.gcp.databricks.com'"
}

output "workspace_id" {
  description = "The Databricks workspace ID"
  value       = module.gcp_with_data_exfiltration_protection.workspace_id
}