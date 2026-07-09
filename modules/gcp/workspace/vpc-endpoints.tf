resource "databricks_mws_vpc_endpoint" "frontend" {
  count = var.enable_frontend ? 1 : 0

  # account_id is required at runtime: the provider builds this resource's API
  # path from the attribute (/accounts/<account_id>/vpc-endpoints), not from
  # the provider config. Omitting it fails apply with a misleading OAuth error.
  account_id        = var.databricks_account_id
  vpc_endpoint_name = "${var.prefix}-ws-ep-${var.suffix}"

  gcp_vpc_endpoint_info {
    project_id        = var.spoke_vpc_google_project
    psc_endpoint_name = var.frontend_forwarding_rule_name
    endpoint_region   = var.google_region
  }
}

resource "databricks_mws_vpc_endpoint" "backend" {
  count = var.enable_backend ? 1 : 0

  account_id        = var.databricks_account_id
  vpc_endpoint_name = "${var.prefix}-scc-ep-${var.suffix}"

  gcp_vpc_endpoint_info {
    project_id        = var.spoke_vpc_google_project
    psc_endpoint_name = var.backend_forwarding_rule_name
    endpoint_region   = var.google_region
  }
}

resource "databricks_mws_vpc_endpoint" "transit" {
  count = var.enable_frontend && var.create_hub ? 1 : 0

  account_id        = var.databricks_account_id
  vpc_endpoint_name = "${var.prefix}-hub-ep-${var.suffix}"

  gcp_vpc_endpoint_info {
    project_id        = var.hub_vpc_google_project
    psc_endpoint_name = var.hub_frontend_forwarding_rule_name
    endpoint_region   = var.google_region
  }
}
