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
