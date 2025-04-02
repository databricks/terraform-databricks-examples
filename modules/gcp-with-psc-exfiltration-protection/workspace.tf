resource "databricks_mws_workspaces" "databricks_workspace" {
  workspace_name = "${var.prefix}-ws-${random_string.suffix.result}"

  account_id = var.databricks_account_id
  location   = var.google_region

  cloud_resource_container {
    gcp {
      project_id = var.workspace_google_project
    }
  }

  private_access_settings_id = databricks_mws_private_access_settings.pas.private_access_settings_id
  network_id                 = databricks_mws_networks.databricks_network.network_id

  gke_config {
    connectivity_type = "PRIVATE_NODE_PUBLIC_MASTER"
    master_ip_range   = var.gke_master_ip_range
  }

}
