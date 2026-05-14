locals {
  create_vpc = var.vpc_source == "create"
  use_existing_vpc = var.vpc_source == "existing"

  subnet_name = coalesce(var.subnet_name, "${var.prefix}-subnet-${var.suffix}")
}

# === Spoke VPC (created) ================================================
resource "google_compute_network" "spoke_vpc" {
  count = local.create_vpc ? 1 : 0

  name                    = "${var.prefix}-spoke-vpc-${var.suffix}"
  project                 = var.spoke_vpc_google_project
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

resource "google_compute_subnetwork" "spoke_subnet" {
  count = local.create_vpc ? 1 : 0

  name                     = local.subnet_name
  project                  = var.spoke_vpc_google_project
  network                  = google_compute_network.spoke_vpc[0].id
  region                   = var.google_region
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true

  dynamic "secondary_ip_range" {
    for_each = var.pod_cidr != null ? [1] : []
    content {
      range_name    = "pods"
      ip_cidr_range = var.pod_cidr
    }
  }

  dynamic "secondary_ip_range" {
    for_each = var.svc_cidr != null ? [1] : []
    content {
      range_name    = "services"
      ip_cidr_range = var.svc_cidr
    }
  }
}

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

# === Spoke VPC (data lookup) ============================================
data "google_compute_network" "existing_spoke" {
  count = local.use_existing_vpc ? 1 : 0

  name    = var.existing_vpc_name
  project = var.spoke_vpc_google_project
}

data "google_compute_subnetwork" "existing_spoke_subnet" {
  count = local.use_existing_vpc ? 1 : 0

  name    = var.existing_subnet_name
  project = var.spoke_vpc_google_project
  region  = var.google_region
}

# === Hub VPC ============================================================
resource "google_compute_network" "hub_vpc" {
  count = var.create_hub ? 1 : 0

  name                    = "${var.prefix}-hub-vpc-${var.suffix}"
  project                 = var.hub_vpc_google_project
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

resource "google_compute_subnetwork" "hub_subnet" {
  count = var.create_hub ? 1 : 0

  name                     = "${var.prefix}-hub-subnet-${var.suffix}"
  project                  = var.hub_vpc_google_project
  network                  = google_compute_network.hub_vpc[0].id
  region                   = var.google_region
  ip_cidr_range            = var.hub_vpc_cidr
  private_ip_google_access = true
}

# === Peering ============================================================
resource "google_compute_network_peering" "hub_to_spoke" {
  count = var.create_hub ? 1 : 0

  name         = "${var.prefix}-hub-spoke-${var.suffix}"
  network      = google_compute_network.hub_vpc[0].self_link
  peer_network = local.create_vpc ? google_compute_network.spoke_vpc[0].self_link : data.google_compute_network.existing_spoke[0].self_link
}

resource "google_compute_network_peering" "spoke_to_hub" {
  count = var.create_hub ? 1 : 0

  name         = "${var.prefix}-spoke-hub-${var.suffix}"
  network      = local.create_vpc ? google_compute_network.spoke_vpc[0].self_link : data.google_compute_network.existing_spoke[0].self_link
  peer_network = google_compute_network.hub_vpc[0].self_link
}

# === Shared VPC =========================================================
resource "google_compute_shared_vpc_host_project" "host" {
  count = var.create_hub && var.is_spoke_vpc_shared && var.workspace_google_project != var.spoke_vpc_google_project ? 1 : 0

  project = var.spoke_vpc_google_project
}

resource "google_compute_shared_vpc_service_project" "service" {
  count = var.create_hub && var.is_spoke_vpc_shared && var.workspace_google_project != var.spoke_vpc_google_project ? 1 : 0

  host_project    = google_compute_shared_vpc_host_project.host[0].project
  service_project = var.workspace_google_project
}
