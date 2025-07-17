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

# ----------------------------------------------------------------------------------------------------------
# Local Value: Extract Project ID with Region to Project Mapping for Workspace Frontend PSC Endpoint
# ----------------------------------------------------------------------------------------------------------

locals {
  # project_mapping is a map data structure that associates each Google Cloud region with its corresponding project ID for the Workspace Frontend PSC endpoint.
  # This mapping helps construct accurate service endpoint URIs in Terraform resources for each available GCP region.
  # Each key in the map is a region name, and each value is the expected project ID pattern for that region, ensuring consistent deployment across various regions.
  project_mapping = {
    "asia-northeast1"         = "general-prod-asianeast1-01"
    "asia-south1"             = "gen-prod-asias1-01"
    "asia-southeast1"         = "general-prod-asiasoutheast1-01"
    "australia-southeast1"    = "general-prod-ausoutheast1-01"
    "europe-west1"            = "general-prod-europewest1-01"
    "europe-west2"            = "general-prod-europewest2-01"
    "europe-west3"            = "general-prod-europewest3-01"
    "northamerica-northeast1" = "general-prod-nanortheast1-01"
    "southamerica-east1"      = "gen-prod-saeast1-01"
    "us-central1"             = "gcp-prod-general"
    "us-east1"                = "general-prod-useast1-01"
    "us-east4"                = "general-prod-useast4-01"
    "us-west1"                = "general-prod-uswest1-01"
    "us-west4"                = "general-prod-uswest4-01"
  }
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
  target                = "projects/${local.project_mapping[var.google_region]}/regions/${var.google_region}/serviceAttachments/plproxy-psc-endpoint-all-ports"
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
  target                = "projects/${local.project_mapping[var.google_region]}/regions/${var.google_region}/serviceAttachments/plproxy-psc-endpoint-all-ports"
  load_balancing_scheme = "" # Must be set to "" for service attachment targets
}
