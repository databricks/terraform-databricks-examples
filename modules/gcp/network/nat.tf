resource "google_compute_router" "router" {
  count = local.create_vpc ? 1 : 0

  name    = "${var.prefix}-router-${var.suffix}"
  project = var.spoke_vpc_google_project
  region  = var.google_region
  network = google_compute_network.spoke_vpc[0].id
}

resource "google_compute_router_nat" "nat" {
  count = local.create_vpc ? 1 : 0

  name                               = "${var.prefix}-nat-${var.suffix}"
  project                            = var.spoke_vpc_google_project
  router                             = google_compute_router.router[0].name
  region                             = var.google_region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
