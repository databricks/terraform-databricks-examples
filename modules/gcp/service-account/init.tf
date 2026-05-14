terraform {
  required_providers {

    google = {
      source = "hashicorp/google"
    }
  }
}

data "google_client_openid_userinfo" "me" {
}
