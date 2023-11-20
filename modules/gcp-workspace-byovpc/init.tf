terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
    google = {
      source = "hashicorp/google"
    }
  }
}

data "google_client_openid_userinfo" "me" {
}


data "google_client_config" "current" {
}


resource "random_string" "suffix" {
  special = false
  upper   = false
  length  = 6
}
