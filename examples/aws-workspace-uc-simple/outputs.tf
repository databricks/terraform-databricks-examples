output "databricks_workspace_id" {
  value       = module.databricks_workspace.databricks_workspace_id
  description = "Databricks workspace ID"
}

output "databricks_workspace_url" {
  value       = module.databricks_workspace.databricks_host
  description = "Databricks workspace URL"
}
