



resource "databricks_mws_workspaces" "databricks_workspace" {
  provider       = databricks.accounts
  account_id     = var.databricks_account_id
  workspace_name = "dbx-example-tf-deploy-${random_string.suffix.result}"
  
  # location       = google_compute_subnetwork.network-with-private-secondary-ip-ranges.region
  location = var.google_region
  cloud_resource_container {
    gcp {
      project_id = var.google_project
    }
  }
  
  # network_name="${var.project}-nw-${random_string.databricks_suffix.result}"
  # network_id = databricks_mws_networks.databricks_network.network_id
  # gke_config {
  #   connectivity_type = "PRIVATE_NODE_PUBLIC_MASTER"
  #   master_ip_range   = "10.3.0.0/28"
  # }

  token {
    comment = "Terraform token"
  }

  # this makes sure that the NAT is created for outbound traffic before creating the workspace
  # depends_on = [google_compute_router_nat.nat]
}

output "databricks_host" {
  value = databricks_mws_workspaces.databricks_workspace.workspace_url
}

output "databricks_token" {
  value     = databricks_mws_workspaces.databricks_workspace.token[0].token_value
  sensitive = true
}
