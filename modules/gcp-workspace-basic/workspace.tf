



resource "databricks_mws_workspaces" "databricks_workspace" {
  provider       = databricks.accounts
  account_id     = var.databricks_account_id
  workspace_name = var.workspace_name
  
  location = var.google_region
  cloud_resource_container {
    gcp {
      project_id = var.google_project
    }
  }
  token {
    comment = "Terraform token"
  }
}

output "databricks_host" {
  value = databricks_mws_workspaces.databricks_workspace.workspace_url
}

output "databricks_token" {
  value     = databricks_mws_workspaces.databricks_workspace.token[0].token_value
  sensitive = true
}
