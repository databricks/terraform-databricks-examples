resource "databricks_mws_vpc_endpoint" "frontend" {
  count = var.enable_frontend ? 1 : 0

  vpc_endpoint_name = "${var.prefix}-ws-ep-${var.suffix}"

  gcp_vpc_endpoint_info {
    project_id        = var.spoke_vpc_google_project
    psc_endpoint_name = var.frontend_forwarding_rule_name
    endpoint_region   = var.google_region
  }
}

resource "databricks_mws_vpc_endpoint" "backend" {
  count = var.enable_backend ? 1 : 0

  vpc_endpoint_name = "${var.prefix}-scc-ep-${var.suffix}"

  gcp_vpc_endpoint_info {
    project_id        = var.spoke_vpc_google_project
    psc_endpoint_name = var.backend_forwarding_rule_name
    endpoint_region   = var.google_region
  }
}

resource "databricks_mws_vpc_endpoint" "transit" {
  count = var.enable_frontend && var.create_hub ? 1 : 0

  vpc_endpoint_name = "${var.prefix}-hub-ep-${var.suffix}"

  gcp_vpc_endpoint_info {
    project_id        = var.hub_vpc_google_project
    psc_endpoint_name = var.hub_frontend_forwarding_rule_name
    endpoint_region   = var.google_region
  }
}
