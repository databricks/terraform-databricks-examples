resource "google_compute_network_peering" "hub_to_spoke" {
  count = var.enable_hub && var.enable_hub_spoke_peering ? 1 : 0

  name         = "${var.prefix}-hub-spoke-${var.suffix}"
  network      = local.create_hub_vpc ? google_compute_network.hub_vpc[0].self_link : data.google_compute_network.existing_hub[0].self_link
  peer_network = local.create_spoke ? google_compute_network.spoke_vpc[0].self_link : data.google_compute_network.existing_spoke[0].self_link
}

resource "google_compute_network_peering" "spoke_to_hub" {
  count = var.enable_hub && var.enable_hub_spoke_peering ? 1 : 0

  name         = "${var.prefix}-spoke-hub-${var.suffix}"
  network      = local.create_spoke ? google_compute_network.spoke_vpc[0].self_link : data.google_compute_network.existing_spoke[0].self_link
  peer_network = local.create_hub_vpc ? google_compute_network.hub_vpc[0].self_link : data.google_compute_network.existing_hub[0].self_link
}
