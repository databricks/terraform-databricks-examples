



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
