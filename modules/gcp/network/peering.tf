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
