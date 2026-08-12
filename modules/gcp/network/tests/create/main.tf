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
  spoke_vpc_google_project = "fixture-project"
  subnet_cidr              = "10.0.0.0/22"
}
