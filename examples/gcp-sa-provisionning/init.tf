terraform {
  required_providers {

    google = {
      source  = "hashicorp/google"
    }
  }
}

provider "google" {
  project = var.google_project
  region  = var.google_region
  zone    = var.google_zone

}
data "google_client_openid_userinfo" "me" {
}
