output "workspace_id" {
  value       = module.workspace.workspace_id
  description = "Databricks workspace ID"
}

output "workspace_url" {
  value       = module.workspace.workspace_url
  description = "Databricks workspace URL"
}

output "network_id" {
  value       = module.workspace.network_id
  description = "databricks_mws_networks ID"
}
