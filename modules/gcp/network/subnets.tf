# === Spoke subnet =======================================================
resource "google_compute_subnetwork" "spoke_subnet" {
  count = local.create_vpc ? 1 : 0

  name                     = local.subnet_name
  project                  = var.spoke_vpc_google_project
  network                  = google_compute_network.spoke_vpc[0].id
  region                   = var.google_region
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true
}

# === Hub subnet =========================================================
resource "google_compute_subnetwork" "hub_subnet" {
  count = var.create_hub ? 1 : 0

  name                     = "${var.prefix}-hub-subnet-${var.suffix}"
  project                  = var.hub_vpc_google_project
  network                  = google_compute_network.hub_vpc[0].id
  region                   = var.google_region
  ip_cidr_range            = var.hub_vpc_cidr
  private_ip_google_access = true
}
