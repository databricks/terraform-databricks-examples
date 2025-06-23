#########################################
# Databricks Private DNS Configuration  #
#########################################

# Create a private DNS zone for Databricks PSC management
resource "google_dns_managed_zone" "hub_private_zone" {
  name        = "${var.prefix}-hub-gcp-databricks-com"
  project     = var.hub_vpc_google_project
  dns_name    = "gcp.databricks.com."
  description = "Private DNS zone for Databricks PSC management"
  visibility  = "private"

  # Restrict visibility to the hub VPC network
  private_visibility_config {
    networks {
      network_url = google_compute_network.hub_vpc.id
    }
  }
}

# DNS A record for the Databricks workspace URL
resource "google_dns_record_set" "hub_workspace_url" {
  name         = "${local.workspace_dns_id}.${google_dns_managed_zone.hub_private_zone.dns_name}"
  project      = var.hub_vpc_google_project
  managed_zone = google_dns_managed_zone.hub_private_zone.name
  type         = "A"
  ttl          = 300

  # Points to the Databricks frontend Private Endpoint IP address
  rrdatas = [
    google_compute_address.hub_frontend_pe_ip_address.address
  ]
}

# DNS A record for the Databricks PSC authentication endpoint
resource "google_dns_record_set" "hub_workspace_psc_auth" {
  name         = "${var.google_region}.psc-auth.${google_dns_managed_zone.hub_private_zone.dns_name}"
  project      = var.hub_vpc_google_project
  managed_zone = google_dns_managed_zone.hub_private_zone.name
  type         = "A"
  ttl          = 300

  # Points to the same frontend Private Endpoint IP
  rrdatas = [
    google_compute_address.hub_frontend_pe_ip_address.address
  ]
}

# DNS A record for the Databricks dataplane endpoint
resource "google_dns_record_set" "hub_workspace_dp" {
  name         = "dp-${local.workspace_dns_id}.${google_dns_managed_zone.hub_private_zone.dns_name}"
  project      = var.hub_vpc_google_project
  managed_zone = google_dns_managed_zone.hub_private_zone.name
  type         = "A"
  ttl          = 300

  # Points to the same frontend Private Endpoint IP
  rrdatas = [
    google_compute_address.hub_frontend_pe_ip_address.address
  ]
}

#############################################
# Google Container Registry Private DNS Zone #
#############################################

# Create a private DNS zone for GCR (gcr.io)
resource "google_dns_managed_zone" "gcr_private_zone" {
  name        = "${var.prefix}-gcr-io"
  project     = var.hub_vpc_google_project
  dns_name    = "gcr.io."
  description = "Private DNS zone for GCR private resolution"
  visibility  = "private"

  # Restrict visibility to the hub VPC network
  private_visibility_config {
    networks {
      network_url = google_compute_network.hub_vpc.id
    }
  }
}

# Wildcard CNAME record for all subdomains of gcr.io
resource "google_dns_record_set" "gcr_cname" {
  name         = "*.${google_dns_managed_zone.gcr_private_zone.dns_name}"
  project      = var.hub_vpc_google_project
  managed_zone = google_dns_managed_zone.gcr_private_zone.name
  type         = "CNAME"
  ttl          = 300

  # All subdomains point to gcr.io
  rrdatas = [
    "gcr.io."
  ]
}

# A record for gcr.io pointing to Google IPs for private access
resource "google_dns_record_set" "gcr_a" {
  name         = google_dns_managed_zone.gcr_private_zone.dns_name
  project      = var.hub_vpc_google_project
  managed_zone = google_dns_managed_zone.gcr_private_zone.name
  type         = "A"
  ttl          = 300

  # Official Google IPs for gcr.io
  rrdatas = [
    "199.36.153.8",
    "199.36.153.9",
    "199.36.153.10",
    "199.36.153.11"
  ]
}

##################################
# Google APIs Private DNS Zone   #
##################################

# Create a private DNS zone for Google APIs (googleapis.com)
resource "google_dns_managed_zone" "google_apis_private_zone" {
  name        = "${var.prefix}-google-apis"
  project     = var.hub_vpc_google_project
  dns_name    = "googleapis.com."
  description = "Private DNS zone for Google APIs resolution"
  visibility  = "private"

  # Restrict visibility to the hub VPC network
  private_visibility_config {
    networks {
      network_url = google_compute_network.hub_vpc.id
    }
  }
}

# Wildcard CNAME record for all subdomains of googleapis.com
resource "google_dns_record_set" "restricted_apis_cname" {
  name         = "*.${google_dns_managed_zone.google_apis_private_zone.dns_name}"
  project      = var.hub_vpc_google_project
  managed_zone = google_dns_managed_zone.google_apis_private_zone.name
  type         = "CNAME"
  ttl          = 300

  # All subdomains point to restricted.googleapis.com
  rrdatas = [
    "restricted.googleapis.com."
  ]
}

# A record for restricted.googleapis.com pointing to Google IPs for private access
resource "google_dns_record_set" "restricted_apis_a" {
  name         = "restricted.${google_dns_managed_zone.google_apis_private_zone.dns_name}"
  project      = var.hub_vpc_google_project
  managed_zone = google_dns_managed_zone.google_apis_private_zone.name
  type         = "A"
  ttl          = 300

  # Official Google IPs for restricted.googleapis.com
  rrdatas = [
    "199.36.153.4",
    "199.36.153.5",
    "199.36.153.6",
    "199.36.153.7"
  ]
}

##################################
# Go Packages Private DNS Zone   #
##################################

# Create a private DNS zone for Go Packages (pkg.dev)
resource "google_dns_managed_zone" "pkg_dev_private_zone" {
  name        = "${var.prefix}-pkg-dev"
  project     = var.hub_vpc_google_project
  dns_name    = "pkg.dev."
  description = "Private DNS zone for Go Packages resolution"
  visibility  = "private"

  # Restrict visibility to the hub VPC network
  private_visibility_config {
    networks {
      network_url = google_compute_network.hub_vpc.id
    }
  }
}

# Wildcard CNAME record for all subdomains of pkg.dev
resource "google_dns_record_set" "pkg_dev_cname" {
  name         = "*.${google_dns_managed_zone.pkg_dev_private_zone.dns_name}"
  project      = var.hub_vpc_google_project
  managed_zone = google_dns_managed_zone.pkg_dev_private_zone.name
  type         = "CNAME"
  ttl          = 300

  # All subdomains point to pkg.dev
  rrdatas = [
    "pkg.dev."
  ]
}

# A record for pkg.dev pointing to Google IPs for private access
resource "google_dns_record_set" "pkg_dev_a" {
  name         = google_dns_managed_zone.pkg_dev_private_zone.dns_name
  project      = var.hub_vpc_google_project
  managed_zone = google_dns_managed_zone.pkg_dev_private_zone.name
  type         = "A"
  ttl          = 300

  # Official Google IPs for pkg.dev
  rrdatas = [
    "199.36.153.8",
    "199.36.153.9",
    "199.36.153.10",
    "199.36.153.11"
  ]
}
