resource "databricks_mws_workspaces" "this" {
  account_id     = var.databricks_account_id
  workspace_name = local.workspace_name
  location       = var.google_region

  cloud_resource_container {
    gcp {
      project_id = var.google_project
    }
  }

  network_id                 = local.emit_mws_networks ? databricks_mws_networks.this[0].network_id : null
  private_access_settings_id = local.emit_pas ? databricks_mws_private_access_settings.this[0].private_access_settings_id : null

  depends_on = [var.nat_dependency]
}
