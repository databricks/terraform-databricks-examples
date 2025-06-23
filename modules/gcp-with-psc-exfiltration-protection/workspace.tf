#########################################################
# Databricks Workspace Configuration
#########################################################

resource "databricks_mws_workspaces" "databricks_workspace" {
  workspace_name = "${var.prefix}-ws-${random_string.suffix.result}"

  # Databricks account and cloud provider details
  account_id = var.databricks_account_id
  location   = var.google_region # GCP region for workspace deployment

  # GCP project hosting workspace resources
  cloud_resource_container {
    gcp {
      project_id = var.workspace_google_project
    }
  }

  # Network and security configurations
  private_access_settings_id = databricks_mws_private_access_settings.pas.private_access_settings_id # Private access enforcement
  network_id                 = databricks_mws_networks.databricks_network.network_id                 # Associated VPC network
}
