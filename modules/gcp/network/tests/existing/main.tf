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
  vpc_source               = "existing"
  spoke_vpc_google_project = "fixture-project"
  existing_vpc_name        = "preexisting-vpc"
  existing_subnet_name     = "preexisting-subnet"
}
