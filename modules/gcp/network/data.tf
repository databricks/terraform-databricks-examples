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
