resource "google_compute_firewall" "hub_net_traffic" {
  name = "${google_compute_network.hub_vpc.name}-ingress"

  project = var.hub_vpc_google_project
  network = google_compute_network.hub_vpc.self_link

  direction          = "INGRESS"
  priority           = 1000
  destination_ranges = []
  source_ranges      = [var.spoke_vpc_cidr]

  allow {
    protocol = "all"
  }
}
