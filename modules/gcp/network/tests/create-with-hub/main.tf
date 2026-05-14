terraform {
  required_version = ">= 1.5"
}

provider "google" {
  project = "fixture-project"
  region  = "us-central1"
}

module "network" {
  source = "../.."

  prefix                   = "fixture"
  suffix                   = "abc123"
  google_region            = "us-central1"
  vpc_source               = "create"
  spoke_vpc_google_project = "fixture-spoke-project"
  spoke_vpc_cidr           = "10.0.0.0/16"
  subnet_cidr              = "10.0.0.0/22"

  create_hub               = true
  hub_vpc_google_project   = "fixture-hub-project"
  hub_vpc_cidr             = "10.1.0.0/24"
  is_spoke_vpc_shared      = true
  workspace_google_project = "fixture-workspace-project"
}
