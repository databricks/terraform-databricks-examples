# Bridge an opaque upstream dependency (Cloud NAT readiness) into the graph.
resource "terraform_data" "nat_gate" {
  input = var.nat_dependency
}

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

  managed_services_customer_managed_key_id = var.cmek_managed_services_key_id != null ? databricks_mws_customer_managed_keys.managed_services[0].customer_managed_key_id : null
  storage_customer_managed_key_id          = var.cmek_storage_key_id != null ? databricks_mws_customer_managed_keys.storage[0].customer_managed_key_id : null

  depends_on = [terraform_data.nat_gate]
}
