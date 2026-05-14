locals {
  workspace_name     = coalesce(var.workspace_name, "${var.prefix}-ws-${var.suffix}")
  emit_mws_networks  = var.vpc_source != "databricks_managed"
  emit_vpc_endpoints = var.frontend_psc_fr_id != null && var.backend_psc_fr_id != null
  emit_pas           = var.private_access_only
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

  token {
    comment = "Terraform"
  }

  depends_on = [var.nat_dependency]
}

resource "databricks_mws_networks" "this" {
  count = local.emit_mws_networks ? 1 : 0

  account_id   = var.databricks_account_id
  network_name = "${var.prefix}-ntw-${var.suffix}"

  gcp_network_info {
    network_project_id = var.spoke_vpc_google_project
    vpc_id             = var.spoke_vpc_name
    subnet_id          = var.spoke_subnet_name
    subnet_region      = var.google_region
  }

  dynamic "vpc_endpoints" {
    for_each = local.emit_vpc_endpoints ? [1] : []
    content {
      dataplane_relay = [databricks_mws_vpc_endpoint.backend[0].vpc_endpoint_id]
      rest_api        = [databricks_mws_vpc_endpoint.frontend[0].vpc_endpoint_id]
    }
  }
}
