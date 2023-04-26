
output "databricks_host" {
  value = databricks_mws_workspaces.databricks_workspace.workspace_url
}

output "databricks_token" {
  value     = databricks_mws_workspaces.databricks_workspace.token[0].token_value
  sensitive = true
}
