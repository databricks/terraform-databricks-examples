terraform {
  required_version = ">= 1.5"
}

provider "google" {
  project = "fixture-spoke"
  region  = "us-central1"
}

module "pc" {
  source = "../.."

  prefix        = "fixture"
  suffix        = "abc123"
  google_region = "us-central1"

  spoke_vpc_id             = "projects/fixture-spoke/global/networks/spoke-vpc"
  spoke_vpc_self_link      = "https://www.googleapis.com/compute/v1/projects/fixture-spoke/global/networks/spoke-vpc"
  spoke_vpc_google_project = "fixture-spoke"
  spoke_vpc_cidr           = "10.0.0.0/16"

  enable_frontend = true
  enable_backend  = false
  restrict_egress = false
  psc_subnet_cidr = "10.0.255.0/28"
}
