# === gcp.databricks.com (spoke) ==========================================
resource "google_dns_managed_zone" "spoke_dbx" {
  name        = "${var.prefix}-spoke-gcp-databricks-com"
  project     = var.spoke_vpc_google_project
  dns_name    = "gcp.databricks.com."
  description = "Private DNS zone for Databricks PSC management"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = var.spoke_vpc_id
    }
  }
}

resource "google_dns_record_set" "spoke_workspace_url" {
  name         = "${local.workspace_dns_id}.${google_dns_managed_zone.spoke_dbx.dns_name}"
  project      = var.spoke_vpc_google_project
  managed_zone = google_dns_managed_zone.spoke_dbx.name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.frontend_psc_ip_spoke]
}

resource "google_dns_record_set" "spoke_dp" {
  name         = "dp-${local.workspace_dns_id}.${google_dns_managed_zone.spoke_dbx.dns_name}"
  project      = var.spoke_vpc_google_project
  managed_zone = google_dns_managed_zone.spoke_dbx.name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.frontend_psc_ip_spoke]
}

resource "google_dns_record_set" "spoke_tunnel" {
  name         = "tunnel.${var.google_region}.${google_dns_managed_zone.spoke_dbx.dns_name}"
  project      = var.spoke_vpc_google_project
  managed_zone = google_dns_managed_zone.spoke_dbx.name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.backend_psc_ip_spoke]
}
