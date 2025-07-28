resource "databricks_mws_workspaces" "databricks_workspace" {
  account_id     = var.databricks_account_id
  workspace_name = "dbx-example-tf-deploy-${random_string.suffix.result}"

  location = var.google_region
  cloud_resource_container {
    gcp {
      project_id = var.google_project
    }
  }

  network_id = databricks_mws_networks.databricks_network.network_id

  token {
    comment = "Terraform token"
  }

  # this makes sure that the NAT is created for outbound traffic before creating the workspace
  depends_on = [google_compute_router_nat.nat]
}
