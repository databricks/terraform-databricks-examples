# === PSC Subnet (spoke) =================================================
resource "google_compute_subnetwork" "psc_subnet" {
  name                     = "${var.prefix}-psc-subnet-${var.suffix}"
  project                  = var.spoke_vpc_google_project
  network                  = var.spoke_vpc_id
  region                   = var.google_region
  ip_cidr_range            = var.psc_subnet_cidr
  private_ip_google_access = true
}

# === Backend (SCC) PSC endpoint — spoke =================================
resource "google_compute_address" "backend_address" {
  count = var.enable_backend ? 1 : 0

  name         = "${var.prefix}-psc-scc-ip-${var.suffix}"
  project      = var.spoke_vpc_google_project
  region       = var.google_region
  subnetwork   = google_compute_subnetwork.psc_subnet.name
  address_type = "INTERNAL"
}

resource "google_compute_forwarding_rule" "backend_forwarding_rule" {
  count = var.enable_backend ? 1 : 0

  name                  = "${var.prefix}-psc-scc-ep-${var.suffix}"
  project               = var.spoke_vpc_google_project
  region                = var.google_region
  network               = var.spoke_vpc_id
  ip_address            = google_compute_address.backend_address[0].id
  target                = local.google_backend_psc_targets[var.google_region]
  load_balancing_scheme = ""
}

# === Frontend PSC endpoint — spoke ======================================
resource "google_compute_address" "frontend_address_spoke" {
  count = var.enable_frontend ? 1 : 0

  name         = "${var.prefix}-psc-ws-ip-${var.suffix}"
  project      = var.spoke_vpc_google_project
  region       = var.google_region
  subnetwork   = google_compute_subnetwork.psc_subnet.name
  address_type = "INTERNAL"
}

resource "google_compute_forwarding_rule" "frontend_forwarding_rule_spoke" {
  count = var.enable_frontend ? 1 : 0

  name                  = "${var.prefix}-psc-ws-ep-${var.suffix}"
  project               = var.spoke_vpc_google_project
  region                = var.google_region
  network               = var.spoke_vpc_id
  ip_address            = google_compute_address.frontend_address_spoke[0].id
  target                = local.google_frontend_psc_targets[var.google_region]
  load_balancing_scheme = ""
}

# === Frontend PSC endpoint — hub (transit) ==============================
resource "google_compute_address" "frontend_address_hub" {
  count = var.enable_hub && var.enable_frontend ? 1 : 0

  name         = "${var.prefix}-hub-psc-ws-ip-${var.suffix}"
  project      = var.hub_vpc_google_project
  region       = var.google_region
  subnetwork   = var.hub_subnet_name
  address_type = "INTERNAL"
}

resource "google_compute_forwarding_rule" "frontend_forwarding_rule_hub" {
  count = var.enable_hub && var.enable_frontend ? 1 : 0

  name                  = "${var.prefix}-hub-psc-ws-ep-${var.suffix}"
  project               = var.hub_vpc_google_project
  region                = var.google_region
  network               = var.hub_vpc_id
  ip_address            = google_compute_address.frontend_address_hub[0].id
  target                = local.google_frontend_psc_targets[var.google_region]
  load_balancing_scheme = ""
}
