#############################################
# Databricks Private DNS Zone (Spoke VPC)   #
#############################################

# Creates a private DNS managed zone for Databricks PSC endpoints
# This zone is only visible within the spoke VPC network
resource "google_dns_managed_zone" "spoke_private_zone" {
  name        = "${var.prefix}-spoke-gcp-databricks-com"
  project     = var.spoke_vpc_google_project
  dns_name    = "gcp.databricks.com."
  description = "Private DNS zone for Databricks PSC management"
  visibility  = "private"

  # Restricts DNS zone visibility to the spoke VPC
  private_visibility_config {
    networks {
      network_url = google_compute_network.spoke_vpc.id
    }
  }
}

# Creates an A record for the Databricks workspace endpoint in the spoke VPC
resource "google_dns_record_set" "spoke_workspace_url" {
  name         = "${local.workspace_dns_id}.${google_dns_managed_zone.spoke_private_zone.dns_name}"
  project      = var.spoke_vpc_google_project
  managed_zone = google_dns_managed_zone.spoke_private_zone.name
  type         = "A"
  ttl          = 300

  # Points to the Databricks frontend Private Endpoint IP in the spoke VPC
  rrdatas = [
    google_compute_address.spoke_frontend_pe_ip_address.address
  ]
}

# Creates an A record for the Databricks dataplane endpoint in the spoke VPC
resource "google_dns_record_set" "spoke_workspace_dp" {
  name         = "dp-${local.workspace_dns_id}.${google_dns_managed_zone.spoke_private_zone.dns_name}"
  project      = var.spoke_vpc_google_project
  managed_zone = google_dns_managed_zone.spoke_private_zone.name
  type         = "A"
  ttl          = 300

  # Points to the Databricks frontend Private Endpoint IP in the spoke VPC
  rrdatas = [
    google_compute_address.spoke_frontend_pe_ip_address.address
  ]
}

# Creates an A record for the Databricks relay/tunnel endpoint in the spoke VPC
resource "google_dns_record_set" "spoke_relay" {
  name         = "tunnel.${var.google_region}.${google_dns_managed_zone.spoke_private_zone.dns_name}"
  project      = var.spoke_vpc_google_project
  managed_zone = google_dns_managed_zone.spoke_private_zone.name
  type         = "A"
  ttl          = 300

  # Points to the backend Private Endpoint IP (used for relay/tunnel)
  rrdatas = [
    google_compute_address.backend_pe_ip_address.address
  ]
}

##########################################################
# Peering DNS Zones for Hub-Spoke Shared Service Access  #
##########################################################

# The following managed zones provide private DNS for Google services (GCR, Google APIs, Go Packages)
# and are peered to the hub VPC for shared DNS resolution across VPCs.

# Google Container Registry (GCR) private peering zone
resource "google_dns_managed_zone" "gcr_peering_zone" {
  name        = "${var.prefix}-peering-gcr"
  project     = var.spoke_vpc_google_project
  dns_name    = "gcr.io."
  description = "Peering DNS zone for GCR private resolution"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.spoke_vpc.id
    }
  }

  # Peers this DNS zone with the hub VPC to allow DNS resolution from the hub
  peering_config {
    target_network {
      network_url = google_compute_network.hub_vpc.id
    }
  }
}

# Google APIs private peering zone
resource "google_dns_managed_zone" "google_apis_peering_zone" {
  name        = "${var.prefix}-peering-google-apis"
  project     = var.spoke_vpc_google_project
  dns_name    = "googleapis.com."
  description = "Private DNS zone for Google APIs resolution"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.spoke_vpc.id
    }
  }

  # Peers this DNS zone with the hub VPC to allow DNS resolution from the hub
  peering_config {
    target_network {
      network_url = google_compute_network.hub_vpc.id
    }
  }
}

# Go Packages (pkg.dev) private peering zone
resource "google_dns_managed_zone" "pkg_dev_peering_zone" {
  name        = "${var.prefix}-peering-pkg-dev"
  project     = var.spoke_vpc_google_project
  dns_name    = "pkg.dev."
  description = "Private DNS zone for Go Packages resolution"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.spoke_vpc.id
    }
  }

  # Peers this DNS zone with the hub VPC to allow DNS resolution from the hub
  peering_config {
    target_network {
      network_url = google_compute_network.hub_vpc.id
    }
  }
}
