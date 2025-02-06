resource "google_compute_firewall" "default_deny_egress" {
  name = "${google_compute_network.spoke_vpc.name}-default-deny-egress"

  project = var.spoke_vpc_google_project
  network = google_compute_network.spoke_vpc.self_link

  direction          = "EGRESS"
  priority           = 1100
  destination_ranges = ["0.0.0.0/0"]
  source_ranges      = []

  deny {
    protocol = "all"
  }
}

resource "google_compute_firewall" "from_gcp_health_checks" {
  name = "${google_compute_network.spoke_vpc.name}-from-gcp-healthcheck"

  project = var.spoke_vpc_google_project
  network = google_compute_network.spoke_vpc.self_link

  direction          = "INGRESS"
  priority           = 1010
  destination_ranges = []
  source_ranges      = ["35.191.0.0/16", "130.211.0.0/22"]

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}

resource "google_compute_firewall" "to_gcp_health_checks" {
  name = "${google_compute_network.spoke_vpc.name}-to-gcp-healthcheck"

  project = var.spoke_vpc_google_project
  network = google_compute_network.spoke_vpc.self_link

  direction          = "EGRESS"
  priority           = 1000
  destination_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  source_ranges      = []

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}

resource "google_compute_firewall" "to_google_apis" {
  name = "${google_compute_network.spoke_vpc.name}-to-google-apis"

  project = var.spoke_vpc_google_project
  network = google_compute_network.spoke_vpc.self_link

  direction          = "EGRESS"
  priority           = 1000
  destination_ranges = ["199.36.153.4/30", "199.36.153.8/30", "34.126.0.0/18"]
  source_ranges      = []

  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "to_gke_master" {
  name = "${google_compute_network.spoke_vpc.name}-to-gke-master"

  project = var.spoke_vpc_google_project
  network = google_compute_network.spoke_vpc.self_link

  direction          = "EGRESS"
  priority           = 1000
  destination_ranges = [var.gke_master_ip_range]
  source_ranges      = []

  allow {
    protocol = "tcp"
    ports    = ["443", "10250", "8132"]
  }
}


resource "google_compute_firewall" "to_gke_nodes_subnet" {
  name = "${google_compute_network.spoke_vpc.name}-to-gke-nodes-subnet"

  project = var.spoke_vpc_google_project
  network = google_compute_network.spoke_vpc.self_link

  direction          = "EGRESS"
  priority           = 1000
  destination_ranges = [var.spoke_vpc_cidr, var.pod_ip_cidr_range, var.service_ip_cidr_range]
  source_ranges      = []

  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "to_databricks_control_plane" {
  name = "${google_compute_network.spoke_vpc.name}-to-databricks-control-plane"

  project = var.spoke_vpc_google_project
  network = google_compute_network.spoke_vpc.self_link

  direction          = "EGRESS"
  priority           = 1000
  destination_ranges = ["${google_compute_forwarding_rule.backend_psc_ep.ip_address}/32", "${google_compute_forwarding_rule.spoke_frontend_psc_ep.ip_address}/32"]
  source_ranges      = []

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}

# This is the only Egress rule that goes to a public internet IP
# It can be avoided if the workspace is UC-enabled and that the spark config is configured to avoid fetching the metastore IP
resource "google_compute_firewall" "to_managed_hive" {
  name = "${google_compute_network.spoke_vpc.name}-to-${var.google_region}-managed-hive"

  project = var.spoke_vpc_google_project
  network = google_compute_network.spoke_vpc.self_link

  direction          = "EGRESS"
  priority           = 1000
  destination_ranges = ["${var.hive_metastore_ip}/32"]
  source_ranges      = []

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }
}

resource "google_compute_firewall" "databricks_workspace_traffic" {
  name = "${google_compute_network.spoke_vpc.name}-${databricks_mws_workspaces.databricks_workspace.workspace_id}-ingress"

  project = var.spoke_vpc_google_project
  network = google_compute_network.spoke_vpc.self_link

  direction     = "INGRESS"
  priority      = 1000
  target_tags   = ["databricks-${databricks_mws_workspaces.databricks_workspace.workspace_id}"]
  source_ranges = [var.spoke_vpc_cidr]

  allow {
    protocol = "all"
  }
}
