resource "google_compute_network" "dbx_private_vpc" {
  project                 = var.google_project
  name                    = "tf-network-${random_string.suffix.result}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "network-with-private-secondary-ip-ranges" {
  name          = "test-dbx-${random_string.suffix.result}"
  ip_cidr_range = "10.0.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.dbx_private_vpc.id
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.1.0.0/16"
  }
  secondary_ip_range {
    range_name    = "svc"
    ip_cidr_range = "10.2.0.0/20"
  }
  private_ip_google_access = true
}

resource "google_compute_router" "router" {
  name    = "my-router-${random_string.suffix.result}"
  region  = google_compute_subnetwork.network-with-private-secondary-ip-ranges.region
  network = google_compute_network.dbx_private_vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "my-router-nat-${random_string.suffix.result}"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "databricks_mws_networks" "this" {
  provider     = databricks.accounts
  account_id   = var.databricks_account_id
  network_name = "test-demo-${random_string.suffix.result}"
  gcp_network_info {
    network_project_id    = var.google_project
    vpc_id                = google_compute_network.dbx_private_vpc.name
    subnet_id             = google_compute_subnetwork.network-with-private-secondary-ip-ranges.name
    subnet_region         = google_compute_subnetwork.network-with-private-secondary-ip-ranges.region
    pod_ip_range_name     = "pods"
    service_ip_range_name = "svc"
  }
}
