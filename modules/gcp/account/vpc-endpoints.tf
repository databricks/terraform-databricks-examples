resource "databricks_mws_vpc_endpoint" "frontend" {
  count = var.enable_frontend && var.frontend_psc_fr_id != null ? 1 : 0

  account_id        = var.databricks_account_id
  vpc_endpoint_name = "${var.prefix}-ws-ep-${var.suffix}"

  gcp_vpc_endpoint_info {
    project_id        = var.spoke_vpc_google_project
    psc_endpoint_name = var.frontend_psc_fr_id
    endpoint_region   = var.google_region
  }
}

resource "databricks_mws_vpc_endpoint" "backend" {
  count = var.enable_backend && var.backend_psc_fr_id != null ? 1 : 0

  account_id        = var.databricks_account_id
  vpc_endpoint_name = "${var.prefix}-scc-ep-${var.suffix}"

  gcp_vpc_endpoint_info {
    project_id        = var.spoke_vpc_google_project
    psc_endpoint_name = var.backend_psc_fr_id
    endpoint_region   = var.google_region
  }
}

resource "databricks_mws_vpc_endpoint" "transit" {
  count = var.enable_frontend && var.hub_frontend_psc_fr_id != null ? 1 : 0

  account_id        = var.databricks_account_id
  vpc_endpoint_name = "${var.prefix}-hub-ep-${var.suffix}"

  gcp_vpc_endpoint_info {
    project_id        = var.hub_vpc_google_project
    psc_endpoint_name = var.hub_frontend_psc_fr_id
    endpoint_region   = var.google_region
  }
}
