terraform {
  required_version = ">= 1.5"
  required_providers {
    databricks = { source = "databricks/databricks" }
    google     = { source = "hashicorp/google" }
  }
}

provider "google" {
  project = "fixture-workspace"
  region  = "us-central1"
}

provider "databricks" {
  host       = "https://accounts.gcp.databricks.com"
  account_id = "00000000-0000-0000-0000-000000000000"
}

module "workspace" {
  source = "../.."

  prefix                = "fixture"
  databricks_account_id = "00000000-0000-0000-0000-000000000000"
  google_project        = "fixture-workspace"
  google_region         = "us-central1"

  vpc_source     = { spoke = "create" }
  spoke_vpc_cidr = "10.0.0.0/16"
  subnet_cidr    = "10.0.0.0/22"

  private_link_frontend    = true
  private_link_backend     = true
  private_access_only      = true
  restricted_egress        = true
  enable_hub_spoke_peering = false

  spoke_vpc_google_project = "fixture-spoke"
  hub_vpc_google_project   = "fixture-hub"
  is_spoke_vpc_shared      = true
  hub_vpc_cidr             = "10.1.0.0/24"
  psc_subnet_cidr          = "10.0.255.0/28"

  serverless_egress_mode                   = "restricted"
  serverless_allowed_internet_destinations = ["pypi.org"]

  cmek_managed_services_key_id = "projects/fixture-workspace/locations/us-central1/keyRings/fixture-kr/cryptoKeys/fixture-ms-key"
  cmek_storage_key_id          = "projects/fixture-workspace/locations/us-central1/keyRings/fixture-kr/cryptoKeys/fixture-storage-key"
}
