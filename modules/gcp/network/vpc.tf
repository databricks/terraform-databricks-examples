# === Spoke VPC (created) ================================================
resource "google_compute_network" "spoke_vpc" {
  count = local.create_spoke ? 1 : 0

  name                    = "${var.prefix}-spoke-vpc-${var.suffix}"
  project                 = var.spoke_vpc_google_project
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

# === Hub VPC ============================================================
resource "google_compute_network" "hub_vpc" {
  count = var.create_hub ? 1 : 0

  name                    = "${var.prefix}-hub-vpc-${var.suffix}"
  project                 = var.hub_vpc_google_project
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}
