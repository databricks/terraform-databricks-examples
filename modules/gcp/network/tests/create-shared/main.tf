terraform {
  required_version = ">= 1.5"
}

provider "google" {
  project = "fixture-project"
  region  = "us-central1"
}

# Shared-VPC binding without a hub (BYOVPC + Shared VPC)
module "network" {
  source = "../.."

  prefix                   = "fixture"
  suffix                   = "abc123"
  google_region            = "us-central1"
  vpc_source               = "create"
  spoke_vpc_google_project = "fixture-host-project"
  subnet_cidr              = "10.0.0.0/22"

  is_spoke_vpc_shared      = true
  workspace_google_project = "fixture-workspace-project"
}
