#############################################################
# Google Cloud Firewall Rules for Databricks Spoke Network  #
#############################################################

# ==========================================================
# Default Egress Deny Rule (Catch-All Block)
# ==========================================================

resource "google_compute_firewall" "default_deny_egress" {
  name    = "${google_compute_network.spoke_vpc.name}-default-deny-egress"
  project = var.spoke_vpc_google_project
  network = google_compute_network.spoke_vpc.self_link

  direction          = "EGRESS"
  priority           = 1100          # Higher priority than allow rules
  destination_ranges = ["0.0.0.0/0"] # Block all external destinations
  source_ranges      = []

  deny { protocol = "all" } # Explicit deny all outbound traffic
}

# ==========================================================
# Essential Service Allow Rules
# ==========================================================

# Allows outbound traffic to Google APIs and services
resource "google_compute_firewall" "to_google_apis" {
  name    = "${google_compute_network.spoke_vpc.name}-to-google-apis"
  project = var.spoke_vpc_google_project
  network = google_compute_network.spoke_vpc.self_link

  direction = "EGRESS"
  priority  = 1000 # Lower priority than deny rule
  destination_ranges = [
    "199.36.153.4/30", # Restricted Google APIs
    "199.36.153.8/30", # GCR/GCS endpoints
    "34.126.0.0/18"    # Additional Google service IPs
  ]

  allow { protocol = "all" } # Full protocol access to these IPs
}

# Allows control plane communication for Databricks
resource "google_compute_firewall" "to_databricks_control_plane" {
  name    = "${google_compute_network.spoke_vpc.name}-to-databricks-control-plane"
  project = var.spoke_vpc_google_project
  network = google_compute_network.spoke_vpc.self_link

  direction = "EGRESS"
  priority  = 1000
  destination_ranges = [
    "${google_compute_forwarding_rule.backend_psc_ep.ip_address}/32",       # SCC endpoint
    "${google_compute_forwarding_rule.spoke_frontend_psc_ep.ip_address}/32" # Frontend endpoint
  ]

  allow {
    protocol = "tcp"
    ports    = ["443"] # HTTPS only
  }
}

# ==========================================================
# Managed Hive Metastore Access (Conditional)
# ==========================================================

resource "google_compute_firewall" "to_managed_hive" {
  name    = "${google_compute_network.spoke_vpc.name}-to-${var.google_region}-managed-hive"
  project = var.spoke_vpc_google_project
  network = google_compute_network.spoke_vpc.self_link

  direction          = "EGRESS"
  priority           = 1000
  destination_ranges = ["${var.hive_metastore_ip}/32"] # Metastore-specific IP

  allow {
    protocol = "tcp"
    ports    = ["3306"] # MySQL port
  }
}

# ==========================================================
# Internal Workspace Communication
# ==========================================================

resource "google_compute_firewall" "databricks_workspace_traffic" {
  name    = "${google_compute_network.spoke_vpc.name}-${databricks_mws_workspaces.databricks_workspace.workspace_id}-ingress"
  project = var.spoke_vpc_google_project
  network = google_compute_network.spoke_vpc.self_link

  direction     = "INGRESS"
  priority      = 1000
  source_ranges = [var.spoke_vpc_cidr]                                                          # Internal VPC traffic
  target_tags   = ["databricks-${databricks_mws_workspaces.databricks_workspace.workspace_id}"] # Workspace-specific instances

  allow { protocol = "all" } # Full internal access
}

resource "google_compute_firewall" "to_databricks_compute_plane" {
  name    = "${google_compute_network.spoke_vpc.name}-to-databricks-compute-plane"
  project = var.spoke_vpc_google_project
  network = google_compute_network.spoke_vpc.self_link

  direction = "EGRESS"
  priority  = 1000
  destination_ranges = [
    var.spoke_vpc_cidr
  ]

  allow {
    protocol = "all"
  }
}