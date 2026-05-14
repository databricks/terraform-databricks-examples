locals {
  # Regex extracts the workspace DNS id (numeric.numeric) from the URL.
  workspace_dns_id = regex("[0-9]+\\.[0-9]+", var.workspace_url)
}

# === gcp.databricks.com (hub) ============================================
resource "google_dns_managed_zone" "hub_dbx" {
  name        = "${var.prefix}-hub-gcp-databricks-com"
  project     = var.hub_vpc_google_project
  dns_name    = "gcp.databricks.com."
  description = "Private DNS zone for Databricks PSC management"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = var.hub_vpc_id
    }
  }
}

resource "google_dns_record_set" "hub_workspace_url" {
  name         = "${local.workspace_dns_id}.${google_dns_managed_zone.hub_dbx.dns_name}"
  project      = var.hub_vpc_google_project
  managed_zone = google_dns_managed_zone.hub_dbx.name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.frontend_psc_ip_hub]
}

resource "google_dns_record_set" "hub_psc_auth" {
  name         = "${var.google_region}.psc-auth.${google_dns_managed_zone.hub_dbx.dns_name}"
  project      = var.hub_vpc_google_project
  managed_zone = google_dns_managed_zone.hub_dbx.name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.frontend_psc_ip_hub]
}

resource "google_dns_record_set" "hub_dp" {
  name         = "dp-${local.workspace_dns_id}.${google_dns_managed_zone.hub_dbx.dns_name}"
  project      = var.hub_vpc_google_project
  managed_zone = google_dns_managed_zone.hub_dbx.name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.frontend_psc_ip_hub]
}

# === gcr.io ==============================================================
resource "google_dns_managed_zone" "gcr" {
  name        = "${var.prefix}-gcr-io"
  project     = var.hub_vpc_google_project
  dns_name    = "gcr.io."
  description = "Private DNS zone for GCR private resolution"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = var.hub_vpc_id
    }
  }
}

resource "google_dns_record_set" "gcr_cname" {
  name         = "*.${google_dns_managed_zone.gcr.dns_name}"
  project      = var.hub_vpc_google_project
  managed_zone = google_dns_managed_zone.gcr.name
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["gcr.io."]
}

resource "google_dns_record_set" "gcr_a" {
  name         = google_dns_managed_zone.gcr.dns_name
  project      = var.hub_vpc_google_project
  managed_zone = google_dns_managed_zone.gcr.name
  type         = "A"
  ttl          = 300
  rrdatas      = ["199.36.153.8", "199.36.153.9", "199.36.153.10", "199.36.153.11"]
}

# === googleapis.com ======================================================
resource "google_dns_managed_zone" "google_apis" {
  name        = "${var.prefix}-google-apis"
  project     = var.hub_vpc_google_project
  dns_name    = "googleapis.com."
  description = "Private DNS zone for Google APIs resolution"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = var.hub_vpc_id
    }
  }
}

resource "google_dns_record_set" "google_apis_cname" {
  name         = "*.${google_dns_managed_zone.google_apis.dns_name}"
  project      = var.hub_vpc_google_project
  managed_zone = google_dns_managed_zone.google_apis.name
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["restricted.googleapis.com."]
}

resource "google_dns_record_set" "google_apis_a" {
  name         = "restricted.${google_dns_managed_zone.google_apis.dns_name}"
  project      = var.hub_vpc_google_project
  managed_zone = google_dns_managed_zone.google_apis.name
  type         = "A"
  ttl          = 300
  rrdatas      = ["199.36.153.4", "199.36.153.5", "199.36.153.6", "199.36.153.7"]
}

# === pkg.dev =============================================================
resource "google_dns_managed_zone" "pkg_dev" {
  name        = "${var.prefix}-pkg-dev"
  project     = var.hub_vpc_google_project
  dns_name    = "pkg.dev."
  description = "Private DNS zone for Go Packages resolution"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = var.hub_vpc_id
    }
  }
}

resource "google_dns_record_set" "pkg_dev_cname" {
  name         = "*.${google_dns_managed_zone.pkg_dev.dns_name}"
  project      = var.hub_vpc_google_project
  managed_zone = google_dns_managed_zone.pkg_dev.name
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["pkg.dev."]
}

resource "google_dns_record_set" "pkg_dev_a" {
  name         = google_dns_managed_zone.pkg_dev.dns_name
  project      = var.hub_vpc_google_project
  managed_zone = google_dns_managed_zone.pkg_dev.name
  type         = "A"
  ttl          = 300
  rrdatas      = ["199.36.153.8", "199.36.153.9", "199.36.153.10", "199.36.153.11"]
}
