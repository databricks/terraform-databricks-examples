resource "google_dns_managed_zone" "hub_private_zone" {
  name = "gcp-databricks-com"

  project = var.hub_vpc_google_project

  dns_name    = "gcp.databricks.com."
  description = "Private DNS zone for Databricks PSC management"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.hub_vpc.id
    }
  }
}

resource "google_dns_record_set" "hub_workspace_url" {
  name = "${local.workspace_dns_id}.${google_dns_managed_zone.hub_private_zone.dns_name}"

  project = var.hub_vpc_google_project

  managed_zone = google_dns_managed_zone.hub_private_zone.name
  type         = "A"
  ttl          = 300

  rrdatas = [
    google_compute_address.hub_frontend_pe_ip_address.address
  ]
}

resource "google_dns_record_set" "hub_workspace_psc_auth" {
  name = "${var.google_region}.psc-auth.${google_dns_managed_zone.hub_private_zone.dns_name}"

  project = var.hub_vpc_google_project

  managed_zone = google_dns_managed_zone.hub_private_zone.name
  type         = "A"
  ttl          = 300

  rrdatas = [
    google_compute_address.hub_frontend_pe_ip_address.address
  ]
}

resource "google_dns_record_set" "hub_workspace_dp" {
  name = "dp-${local.workspace_dns_id}.${google_dns_managed_zone.hub_private_zone.dns_name}"

  project = var.hub_vpc_google_project

  managed_zone = google_dns_managed_zone.hub_private_zone.name
  type         = "A"
  ttl          = 300

  rrdatas = [
    google_compute_address.hub_frontend_pe_ip_address.address
  ]
}


#Google Container Registry private zone

resource "google_dns_managed_zone" "gcr_private_zone" {
  name = "gcr-io"

  project = var.hub_vpc_google_project

  dns_name    = "gcr.io."
  description = "Private DNS zone for GCR private resolution"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.hub_vpc.id
    }
  }
}

resource "google_dns_record_set" "gcr_cname" {
  name = "*.${google_dns_managed_zone.gcr_private_zone.dns_name}"

  project = var.hub_vpc_google_project

  managed_zone = google_dns_managed_zone.gcr_private_zone.name
  type         = "CNAME"
  ttl          = 300

  rrdatas = [
    "gcr.io."
  ]
}

resource "google_dns_record_set" "gcr_a" {
  name = google_dns_managed_zone.gcr_private_zone.dns_name

  project = var.hub_vpc_google_project

  managed_zone = google_dns_managed_zone.gcr_private_zone.name
  type         = "A"
  ttl          = 300

  rrdatas = [
    "199.36.153.8",
    "199.36.153.9",
    "199.36.153.10",
    "199.36.153.11"
  ]
}


#Google APIs private zone

resource "google_dns_managed_zone" "google_apis_private_zone" {
  name = "google-apis"

  project = var.hub_vpc_google_project

  dns_name    = "googleapis.com."
  description = "Private DNS zone for Google APIs resolution"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.hub_vpc.id
    }
  }
}

resource "google_dns_record_set" "restricted_apis_cname" {
  name = "*.${google_dns_managed_zone.google_apis_private_zone.dns_name}"

  project = var.hub_vpc_google_project

  managed_zone = google_dns_managed_zone.google_apis_private_zone.name
  type         = "CNAME"
  ttl          = 300

  rrdatas = [
    "restricted.googleapis.com."
  ]
}

resource "google_dns_record_set" "restricted_apis_a" {
  name = "restricted.${google_dns_managed_zone.google_apis_private_zone.dns_name}"

  project = var.hub_vpc_google_project

  managed_zone = google_dns_managed_zone.google_apis_private_zone.name
  type         = "A"
  ttl          = 300

  rrdatas = [
    "199.36.153.4",
    "199.36.153.5",
    "199.36.153.6",
    "199.36.153.7"
  ]
}


#Go Packages private zone

resource "google_dns_managed_zone" "pkg_dev_private_zone" {
  name = "pkg-dev"

  project = var.hub_vpc_google_project

  dns_name    = "pkg.dev."
  description = "Private DNS zone for Go Packages resolution"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.hub_vpc.id
    }
  }
}

resource "google_dns_record_set" "pkg_dev_cname" {
  name = "*.${google_dns_managed_zone.pkg_dev_private_zone.dns_name}"

  project = var.hub_vpc_google_project

  managed_zone = google_dns_managed_zone.pkg_dev_private_zone.name
  type         = "CNAME"
  ttl          = 300

  rrdatas = [
    "pkg.dev."
  ]
}

resource "google_dns_record_set" "pkg_dev_a" {
  name = google_dns_managed_zone.pkg_dev_private_zone.dns_name

  project = var.hub_vpc_google_project

  managed_zone = google_dns_managed_zone.pkg_dev_private_zone.name
  type         = "A"
  ttl          = 300

  rrdatas = [
    "199.36.153.8",
    "199.36.153.9",
    "199.36.153.10",
    "199.36.153.11"
  ]
}
