provider "aws" {
  region = var.region
  default_tags {
    tags = var.tags
  }
}

// initialize an account-level provider to provision the
// private connectivity endpoint rule on the NCC.
provider "databricks" {
  host          = "https://accounts.cloud.databricks.com"
  account_id    = var.databricks_account_id
  client_id     = var.databricks_account_client_id
  client_secret = var.databricks_account_client_secret
}
