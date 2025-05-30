###################################################
# Databricks VPC Endpoints & Network Configuration
###################################################

# ================================================
# Private Service Connect Endpoint Configurations
# ================================================

# Registers a transit VPC endpoint for hub network connectivity
resource "databricks_mws_vpc_endpoint" "transit_endpoint" {
  depends_on = [google_compute_forwarding_rule.backend_psc_ep]

  vpc_endpoint_name = "${var.prefix}-hub-ep-${random_string.suffix.result}"
  account_id        = var.databricks_account_id

  # GCP-specific PSC configuration for hub network
  gcp_vpc_endpoint_info {
    project_id        = var.hub_vpc_google_project
    psc_endpoint_name = google_compute_forwarding_rule.hub_frontend_psc_ep.name
    endpoint_region   = var.google_region
  }
}

# Registers frontend workspace VPC endpoint for user-facing access
resource "databricks_mws_vpc_endpoint" "frontend_endpoint" {
  depends_on = [google_compute_forwarding_rule.backend_psc_ep]

  vpc_endpoint_name = "${var.prefix}-ws-ep-${random_string.suffix.result}"
  account_id        = var.databricks_account_id

  # GCP-specific PSC configuration for spoke workspace
  gcp_vpc_endpoint_info {
    project_id        = var.spoke_vpc_google_project
    psc_endpoint_name = google_compute_forwarding_rule.spoke_frontend_psc_ep.name
    endpoint_region   = var.google_region
  }
}

# Registers backend SCC (Secure Cluster Connectivity) endpoint
resource "databricks_mws_vpc_endpoint" "backend_endpoint" {
  depends_on = [google_compute_forwarding_rule.spoke_frontend_psc_ep]

  vpc_endpoint_name = "${var.prefix}-scc-ep-${random_string.suffix.result}"
  account_id        = var.databricks_account_id

  # GCP-specific PSC configuration for backend connectivity
  gcp_vpc_endpoint_info {
    project_id        = var.spoke_vpc_google_project
    psc_endpoint_name = google_compute_forwarding_rule.backend_psc_ep.name
    endpoint_region   = var.google_region
  }
}

# ================================================
# Network Configuration for Databricks Workspace
# ================================================

resource "databricks_mws_networks" "databricks_network" {
  network_name = "${var.prefix}-ntw-${random_string.suffix.result}"
  account_id   = var.databricks_account_id

  # GCP network infrastructure details
  gcp_network_info {
    network_project_id = var.spoke_vpc_google_project
    vpc_id             = google_compute_network.spoke_vpc.name
    subnet_id          = google_compute_subnetwork.spoke_subnetwork.name
    subnet_region      = var.google_region
  }

  # PrivateLink endpoint associations
  vpc_endpoints {
    dataplane_relay = [databricks_mws_vpc_endpoint.backend_endpoint.vpc_endpoint_id]  # SCC connectivity
    rest_api        = [databricks_mws_vpc_endpoint.frontend_endpoint.vpc_endpoint_id] # Workspace API access
  }
}

# ================================================
# Private Access Configuration
# ================================================

resource "databricks_mws_private_access_settings" "pas" {
  private_access_settings_name = "${var.prefix}-pas-${random_string.suffix.result}"
  region                       = var.google_region
  public_access_enabled        = false     # Block public internet access
  private_access_level         = "ACCOUNT" # Apply to entire Databricks account
}
