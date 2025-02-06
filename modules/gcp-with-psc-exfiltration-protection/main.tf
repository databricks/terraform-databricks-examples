locals {
  workspace_dns_id = regex("[0-9]+\\.[0-9]+", databricks_mws_workspaces.databricks_workspace.workspace_url)
}

resource "random_string" "suffix" {
  special = false
  upper   = false
  length  = 6
}
