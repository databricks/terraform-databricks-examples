# === gcp.databricks.com (spoke) ==========================================
resource "google_dns_managed_zone" "spoke_databricks" {
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
  name         = "${local.workspace_dns_id}.${google_dns_managed_zone.spoke_databricks.dns_name}"
  project      = var.spoke_vpc_google_project
  managed_zone = google_dns_managed_zone.spoke_databricks.name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.frontend_psc_ip_spoke]
}

resource "google_dns_record_set" "spoke_dp" {
  name         = "dp-${local.workspace_dns_id}.${google_dns_managed_zone.spoke_databricks.dns_name}"
  project      = var.spoke_vpc_google_project
  managed_zone = google_dns_managed_zone.spoke_databricks.name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.frontend_psc_ip_spoke]
}

resource "google_dns_record_set" "spoke_tunnel" {
  name         = "tunnel.${var.google_region}.${google_dns_managed_zone.spoke_databricks.dns_name}"
  project      = var.spoke_vpc_google_project
  managed_zone = google_dns_managed_zone.spoke_databricks.name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.backend_psc_ip_spoke]
}

# === Peering zones (spoke → hub) =========================================
# Private zones do not propagate over VPC peering. The hub hosts the
# record-bearing zones for googleapis.com / gcr.io / pkg.dev; these peering
# zones make them resolvable from the spoke.
resource "google_dns_managed_zone" "spoke_peering_google_apis" {
  name        = "${var.prefix}-peering-google-apis"
  project     = var.spoke_vpc_google_project
  dns_name    = "googleapis.com."
  description = "Peering DNS zone delegating googleapis.com resolution to the hub VPC"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = var.spoke_vpc_id
    }
  }

  peering_config {
    target_network {
      network_url = var.hub_vpc_id
    }
  }
}

resource "google_dns_managed_zone" "spoke_peering_gcr" {
  name        = "${var.prefix}-peering-gcr"
  project     = var.spoke_vpc_google_project
  dns_name    = "gcr.io."
  description = "Peering DNS zone delegating gcr.io resolution to the hub VPC"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = var.spoke_vpc_id
    }
  }

  peering_config {
    target_network {
      network_url = var.hub_vpc_id
    }
  }
}

resource "google_dns_managed_zone" "spoke_peering_pkg_dev" {
  name        = "${var.prefix}-peering-pkg-dev"
  project     = var.spoke_vpc_google_project
  dns_name    = "pkg.dev."
  description = "Peering DNS zone delegating pkg.dev resolution to the hub VPC"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = var.spoke_vpc_id
    }
  }

  peering_config {
    target_network {
      network_url = var.hub_vpc_id
    }
  }
}
