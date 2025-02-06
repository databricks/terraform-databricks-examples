resource "google_dns_managed_zone" "spoke_private_zone" {
  name = "gcp-databricks-com"

  project = var.spoke_vpc_google_project

  dns_name    = "gcp.databricks.com."
  description = "Private DNS zone for Databricks PSC management"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.spoke_vpc.id
    }
  }
}

resource "google_dns_record_set" "spoke_workspace_url" {
  name = "${local.workspace_dns_id}.${google_dns_managed_zone.spoke_private_zone.dns_name}"

  project = var.spoke_vpc_google_project

  managed_zone = google_dns_managed_zone.spoke_private_zone.name
  type         = "A"
  ttl          = 300

  rrdatas = [
    google_compute_address.spoke_frontend_pe_ip_address.address
  ]
}

resource "google_dns_record_set" "spoke_workspace_dp" {
  name = "dp-${local.workspace_dns_id}.${google_dns_managed_zone.spoke_private_zone.dns_name}"

  project = var.spoke_vpc_google_project

  managed_zone = google_dns_managed_zone.spoke_private_zone.name
  type         = "A"
  ttl          = 300

  rrdatas = [
    google_compute_address.spoke_frontend_pe_ip_address.address
  ]

}


resource "google_dns_record_set" "spoke_relay" {
  name = "tunnel.${var.google_region}.${google_dns_managed_zone.spoke_private_zone.dns_name}"

  project = var.spoke_vpc_google_project

  managed_zone = google_dns_managed_zone.spoke_private_zone.name
  type         = "A"
  ttl          = 300

  rrdatas = [
    google_compute_address.backend_pe_ip_address.address
  ]

}


# Hub VPC peering zones
#Google Container Registry private zone

resource "google_dns_managed_zone" "gcr_peering_zone" {
  name = "${var.prefix}-peering-gcr"

  project = var.spoke_vpc_google_project

  dns_name    = "gcr.io."
  description = "Peering DNS zone for GCR private resolution"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.spoke_vpc.id
    }
  }

  peering_config {
    target_network {
      network_url = google_compute_network.hub_vpc.id
    }
  }
}

#Google APIs private zone

resource "google_dns_managed_zone" "google_apis_peering_zone" {
  name = "${var.prefix}-peering-google-apis"

  project = var.spoke_vpc_google_project

  dns_name    = "googleapis.com."
  description = "Private DNS zone for Google APIs resolution"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.spoke_vpc.id
    }
  }

  peering_config {
    target_network {
      network_url = google_compute_network.hub_vpc.id
    }
  }
}

#Goo Packages private zone

resource "google_dns_managed_zone" "pkg_dev_peering_zone" {
  name = "${var.prefix}-peering-pkg-dev"

  project = var.spoke_vpc_google_project

  dns_name    = "pkg.dev."
  description = "Private DNS zone for Go Packages resolution"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.spoke_vpc.id
    }
  }

  peering_config {
    target_network {
      network_url = google_compute_network.hub_vpc.id
    }
  }
}