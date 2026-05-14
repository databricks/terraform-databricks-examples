terraform {
  required_version = ">= 1.5"
}

provider "google" {
  project = "fixture-spoke"
  region  = "us-central1"
}

module "dns" {
  source = "../.."

  prefix        = "fixture"
  google_region = "us-central1"

  hub_vpc_id             = "projects/fixture-hub/global/networks/hub-vpc"
  hub_vpc_self_link      = "https://www.googleapis.com/compute/v1/projects/fixture-hub/global/networks/hub-vpc"
  hub_vpc_google_project = "fixture-hub"

  spoke_vpc_id             = "projects/fixture-spoke/global/networks/spoke-vpc"
  spoke_vpc_self_link      = "https://www.googleapis.com/compute/v1/projects/fixture-spoke/global/networks/spoke-vpc"
  spoke_vpc_google_project = "fixture-spoke"

  workspace_url = "https://1234567890123456.7.gcp.databricks.com"

  frontend_psc_ip_spoke = "10.0.255.4"
  frontend_psc_ip_hub   = "10.1.0.10"
  backend_psc_ip_spoke  = "10.0.255.5"
}
