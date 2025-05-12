# ==========================================================
# Google Cloud VPC Firewall Rule: Hub Network Ingress Traffic
# ==========================================================

resource "google_compute_firewall" "hub_net_traffic" {
  name = "${google_compute_network.hub_vpc.name}-ingress"

  project = var.hub_vpc_google_project
  network = google_compute_network.hub_vpc.self_link

  direction          = "INGRESS"
  priority           = 1000
  destination_ranges = []
  # The source IP range(s) allowed by this rule (CIDR format)
  # Only traffic originating from the spoke VPC's CIDR block will be allowed
  source_ranges = [var.spoke_vpc_cidr]

  allow {
    protocol = "all"
  }
}
