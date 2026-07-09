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

# precondition fail: frontend without backend (GCP requires both)
module "workspace" {
  source = "../.."

  prefix                = "fixture"
  databricks_account_id = "00000000-0000-0000-0000-000000000000"
  google_project        = "fixture-workspace"
  google_region         = "us-central1"

  vpc_source     = { spoke = "create" }
  spoke_vpc_cidr = "10.0.0.0/16"
  subnet_cidr    = "10.0.0.0/22"

  private_link_frontend = true
  private_link_backend  = false
  psc_subnet_cidr       = "10.0.255.0/28"
}
