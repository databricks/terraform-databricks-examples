variable "databricks_account_id" {
  default = "f187f55a-9d3d-463b-aa1a-d55818b704c9"
}

variable "google_project" {
  default = "fe-dev-sandbox"
}
variable "google_region" {
    default = "europe-west1"
}
variable "google_zone" {
    default = "europe-west1-a"
}


terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
    google = {
      source  = "hashicorp/google"
      version = "4.47.0"
    }
  }
}

provider "google" {
  project = var.google_project
  region  = var.google_region
  zone    = var.google_zone
}

// initialize provider in "accounts" mode to provision new workspace

provider "databricks" {
  alias                  = "accounts"  
  host                   = "https://accounts.gcp.databricks.com"
  google_service_account = google_service_account.sa2.name
  account_id             = var.databricks_account_id
}

data "google_client_openid_userinfo" "me" {
}


resource "random_string" "suffix" {
  special = false
  upper   = false
  length  = 6
}
