#########################################################
# Private Service Connect (PSC) Internal Endpoints Setup
#########################################################

# ----------------------------------------------------------------
# Secure Cluster Connectivity (SCC) PSC Endpoint (Spoke VPC)
# ----------------------------------------------------------------

# Reserves an internal IP address for the backend (SCC) PSC endpoint in the spoke VPC
resource "google_compute_address" "backend_pe_ip_address" {
  name         = "${var.prefix}-psc-scc-ip-${random_string.suffix.result}"
  project      = var.spoke_vpc_google_project
  region       = var.google_region
  subnetwork   = google_compute_subnetwork.psc_subnetwork.name
  address_type = "INTERNAL"
}

# Creates a forwarding rule to map the reserved IP to the SCC PSC service attachment
resource "google_compute_forwarding_rule" "backend_psc_ep" {
  name                  = "${var.prefix}-psc-scc-ep-${random_string.suffix.result}"
  project               = var.spoke_vpc_google_project
  region                = var.google_region
  network               = google_compute_network.spoke_vpc.id
  ip_address            = google_compute_address.backend_pe_ip_address.id
  target                = "projects/prod-gcp-${var.google_region}/regions/${var.google_region}/serviceAttachments/ngrok-psc-endpoint"
  load_balancing_scheme = "" # Must be set to "" for service attachment targets
}

# ----------------------------------------------------------------
# Workspace Frontend PSC Endpoint (Spoke VPC)
# ----------------------------------------------------------------

# Reserves an internal IP address for the workspace frontend PSC endpoint in the spoke VPC
resource "google_compute_address" "spoke_frontend_pe_ip_address" {
  name         = "${var.prefix}-psc-ws-ip-${random_string.suffix.result}"
  project      = var.spoke_vpc_google_project
  region       = var.google_region
  subnetwork   = google_compute_subnetwork.psc_subnetwork.name
  address_type = "INTERNAL"
}

# Creates a forwarding rule to map the reserved IP to the workspace frontend PSC service attachment
resource "google_compute_forwarding_rule" "spoke_frontend_psc_ep" {
  name                  = "${var.prefix}-psc-ws-ep-${random_string.suffix.result}"
  project               = var.spoke_vpc_google_project
  region                = var.google_region
  network               = google_compute_network.spoke_vpc.id
  ip_address            = google_compute_address.spoke_frontend_pe_ip_address.id
  target                = "projects/prod-gcp-${var.google_region}/regions/${var.google_region}/serviceAttachments/plproxy-psc-endpoint-all-ports"
  load_balancing_scheme = "" # Must be set to "" for service attachment targets
}

# ----------------------------------------------------------------
# Workspace Frontend PSC Endpoint (Hub VPC)
# ----------------------------------------------------------------

# Reserves an internal IP address for the workspace frontend PSC endpoint in the hub VPC
resource "google_compute_address" "hub_frontend_pe_ip_address" {
  name         = "${var.prefix}-hub-psc-ws-ip-${random_string.suffix.result}"
  project      = var.hub_vpc_google_project
  region       = var.google_region
  subnetwork   = google_compute_subnetwork.hub_subnetwork.name
  address_type = "INTERNAL"
}

# Creates a forwarding rule to map the reserved IP to the workspace frontend PSC service attachment in the hub VPC
resource "google_compute_forwarding_rule" "hub_frontend_psc_ep" {
  name                  = "${var.prefix}-hub-psc-ws-ep-${random_string.suffix.result}"
  project               = var.hub_vpc_google_project
  region                = var.google_region
  network               = google_compute_network.hub_vpc.id
  ip_address            = google_compute_address.hub_frontend_pe_ip_address.id
  target                = "projects/prod-gcp-${var.google_region}/regions/${var.google_region}/serviceAttachments/plproxy-psc-endpoint-all-ports"
  load_balancing_scheme = "" # Must be set to "" for service attachment targets
}
