terraform {
  required_version = ">= 1.5"
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}

provider "databricks" {
  host       = "https://accounts.gcp.databricks.com"
  account_id = "00000000-0000-0000-0000-000000000000"
}

module "account" {
  source = "../.."

  prefix                = "fixture"
  suffix                = "abc123"
  databricks_account_id = "00000000-0000-0000-0000-000000000000"
  google_project        = "fixture-workspace"
  google_region         = "us-central1"
  vpc_source            = "databricks_managed"
}
