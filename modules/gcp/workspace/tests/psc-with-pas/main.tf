terraform {
  required_version = ">= 1.5"
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}

provider "databricks" {
  host       = "https://accounts.gcp.databricks.com"
  account_id = "00000000-0000-0000-0000-000000000000"
}

module "workspace" {
  source = "../.."

  prefix                   = "fixture"
  suffix                   = "abc123"
  databricks_account_id    = "00000000-0000-0000-0000-000000000000"
  google_project           = "fixture-workspace"
  google_region            = "us-central1"
  vpc_source               = "create"
  spoke_vpc_name           = "fixture-spoke-vpc-abc123"
  spoke_subnet_name        = "fixture-subnet-abc123"
  spoke_vpc_google_project = "fixture-spoke"
  hub_vpc_google_project   = "fixture-hub"

  frontend_forwarding_rule_name     = "fixture-psc-ws-ep-abc123"
  backend_forwarding_rule_name      = "fixture-psc-scc-ep-abc123"
  hub_frontend_forwarding_rule_name = "fixture-hub-psc-ws-ep-abc123"

  enable_frontend     = true
  enable_backend      = true
  private_access_only = true
  create_hub          = true

  serverless_egress_mode                   = "restricted"
  serverless_allowed_internet_destinations = ["pypi.org"]
  serverless_allowed_storage_destinations  = ["fixture-allowed-bucket"]
}
