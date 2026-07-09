# Egress firewall stack — only emitted when restrict_egress = true.

# === Spoke deny-egress ==================================================
resource "google_compute_firewall" "spoke_default_deny_egress" {
  count = var.restrict_egress ? 1 : 0

  name    = "${var.prefix}-spoke-${var.suffix}-default-deny-egress"
  project = var.spoke_vpc_google_project
  network = var.spoke_vpc_self_link

  direction          = "EGRESS"
  priority           = 1100
  destination_ranges = ["0.0.0.0/0"]

  deny {
    protocol = "all"
  }
}

# === Spoke allow Google APIs ============================================
resource "google_compute_firewall" "spoke_allow_google_apis" {
  count = var.restrict_egress ? 1 : 0

  name    = "${var.prefix}-spoke-${var.suffix}-to-google-apis"
  project = var.spoke_vpc_google_project
  network = var.spoke_vpc_self_link

  direction = "EGRESS"
  priority  = 1000
  destination_ranges = [
    "199.36.153.4/30",
    "199.36.153.8/30",
    "34.126.0.0/18"
  ]

  allow {
    protocol = "all"
  }
}

# === Spoke allow Databricks control plane (to PSC IPs) ==================
resource "google_compute_firewall" "spoke_allow_ctl_plane" {
  count = var.restrict_egress && var.enable_frontend && var.enable_backend ? 1 : 0

  name    = "${var.prefix}-spoke-${var.suffix}-to-databricks-control-plane"
  project = var.spoke_vpc_google_project
  network = var.spoke_vpc_self_link

  direction = "EGRESS"
  priority  = 1000
  destination_ranges = [
    "${google_compute_forwarding_rule.backend_forwarding_rule[0].ip_address}/32",
    "${google_compute_forwarding_rule.frontend_forwarding_rule_spoke[0].ip_address}/32"
  ]

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}

# === Spoke allow managed Hive (conditional on hive_metastore_ip) ========
resource "google_compute_firewall" "spoke_allow_hive" {
  count = var.restrict_egress && var.hive_metastore_ip != null ? 1 : 0

  name    = "${var.prefix}-spoke-${var.suffix}-to-${var.google_region}-managed-hive"
  project = var.spoke_vpc_google_project
  network = var.spoke_vpc_self_link

  direction          = "EGRESS"
  priority           = 1000
  destination_ranges = ["${var.hive_metastore_ip}/32"]

  allow {
    protocol = "tcp"
    ports    = ["3306"]
  }
}

# === Hub ingress from spoke =============================================
resource "google_compute_firewall" "hub_ingress" {
  count = var.restrict_egress && var.create_hub ? 1 : 0

  name    = "${var.prefix}-hub-${var.suffix}-ingress"
  project = var.hub_vpc_google_project
  network = var.hub_vpc_self_link

  direction     = "INGRESS"
  priority      = 1000
  source_ranges = [var.spoke_vpc_cidr]

  allow {
    protocol = "all"
  }
}

# === Intra-VPC traffic (cluster node-to-node) ===========================
# The deny-egress rule above also covers RFC1918 space, and GCP ingress is
# implied-deny. Without these two allows, Spark clusters cannot form.
# The legacy module scoped ingress with workspace-id target_tags; this
# module runs before the workspace exists, so the rule applies VPC-wide -
# acceptable because the spoke VPC is dedicated to Databricks.
resource "google_compute_firewall" "spoke_intra_egress" {
  count = var.restrict_egress ? 1 : 0

  name    = "${var.prefix}-spoke-${var.suffix}-intra-egress"
  project = var.spoke_vpc_google_project
  network = var.spoke_vpc_self_link

  direction          = "EGRESS"
  priority           = 1000
  destination_ranges = [var.spoke_vpc_cidr]

  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "spoke_intra_ingress" {
  count = var.restrict_egress ? 1 : 0

  name    = "${var.prefix}-spoke-${var.suffix}-intra-ingress"
  project = var.spoke_vpc_google_project
  network = var.spoke_vpc_self_link

  direction     = "INGRESS"
  priority      = 1000
  source_ranges = [var.spoke_vpc_cidr]

  allow {
    protocol = "all"
  }
}
