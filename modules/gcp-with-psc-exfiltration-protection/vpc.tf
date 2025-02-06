resource "google_compute_network" "spoke_vpc" {
  name = "${var.prefix}-spoke-vpc-${random_string.suffix.result}"

  project = var.spoke_vpc_google_project

  auto_create_subnetworks      = false
  routing_mode                 = "GLOBAL"
  bgp_best_path_selection_mode = "STANDARD"
}

resource "google_compute_subnetwork" "spoke_subnetwork" {
  name = "${var.prefix}-spoke-subnet-${random_string.suffix.result}"

  project = var.spoke_vpc_google_project
  network = google_compute_network.spoke_vpc.id
  region  = var.google_region

  ip_cidr_range = var.spoke_vpc_cidr

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.pod_ip_cidr_range
  }
  secondary_ip_range {
    range_name    = "svc"
    ip_cidr_range = var.service_ip_cidr_range
  }
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "psc_subnetwork" {
  name = "${var.prefix}-spoke-psc-subnet-${random_string.suffix.result}"

  project = var.spoke_vpc_google_project
  network = google_compute_network.spoke_vpc.id
  region  = var.google_region

  ip_cidr_range = var.psc_subnet_cidr

  private_ip_google_access = true

}

resource "google_compute_network" "hub_vpc" {
  name = "${var.prefix}-hub-vpc-${random_string.suffix.result}"

  project = var.hub_vpc_google_project

  auto_create_subnetworks      = false
  routing_mode                 = "GLOBAL"
  bgp_best_path_selection_mode = "STANDARD"
}

resource "google_compute_subnetwork" "hub_subnetwork" {
  name = "${var.prefix}-hub-subnet-${random_string.suffix.result}"

  project = var.hub_vpc_google_project
  network = google_compute_network.hub_vpc.id
  region  = var.google_region

  ip_cidr_range = var.hub_vpc_cidr

  private_ip_google_access = true

}

resource "google_compute_network_peering" "hub_spoke_peering" {
  name = "${var.prefix}-hub-spoke-peering-${random_string.suffix.result}"

  network      = google_compute_network.hub_vpc.self_link
  peer_network = google_compute_network.spoke_vpc.self_link
}

resource "google_compute_network_peering" "spoke_hub_peering" {
  name = "${var.prefix}-spoke-hub-peering-${random_string.suffix.result}"

  network      = google_compute_network.spoke_vpc.self_link
  peer_network = google_compute_network.hub_vpc.self_link

}

# resource "google_compute_router" "hub_router" {
#   name = "${var.prefix}-hub-router-${random_string.suffix.result}"
#
#   project = var.hub_vpc_google_project
#   network = google_compute_network.hub_vpc.id
#   region  = var.google_region
# }
#
# resource "google_compute_router" "spoke_router" {
#   name = "${var.prefix}-spoke-router-${random_string.suffix.result}"
#
#   project = var.spoke_vpc_google_project
#   region  = var.google_region
#   network = google_compute_network.spoke_vpc.id
# }

resource "google_compute_shared_vpc_host_project" "host" {
  count = var.workspace_google_project != var.spoke_vpc_google_project && var.is_spoke_vpc_shared ? 1 : 0

  project = var.spoke_vpc_google_project
}

resource "google_compute_shared_vpc_service_project" "service" {
  count = var.workspace_google_project != var.spoke_vpc_google_project && var.is_spoke_vpc_shared ? 1 : 0

  host_project    = google_compute_shared_vpc_host_project.host[0].project
  service_project = var.workspace_google_project
}
