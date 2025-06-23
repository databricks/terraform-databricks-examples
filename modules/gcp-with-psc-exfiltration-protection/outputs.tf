
output "workspace_url" {
  value       = databricks_mws_workspaces.databricks_workspace.workspace_url
  description = "The workspace URL which is of the format '{workspaceId}.{random}.gcp.databricks.com'"
}

output "workspace_id" {
  description = "The Databricks workspace ID"
  value       = databricks_mws_workspaces.databricks_workspace.workspace_id
}