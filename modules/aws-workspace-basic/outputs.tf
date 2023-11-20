output "databricks_host" {
  value = databricks_mws_workspaces.this.workspace_url
}

output "databricks_token" {
  value     = databricks_mws_workspaces.this.token[0].token_value
  sensitive = true
}

output "workspace_id" {
  value = databricks_mws_workspaces.this.workspace_id
}
