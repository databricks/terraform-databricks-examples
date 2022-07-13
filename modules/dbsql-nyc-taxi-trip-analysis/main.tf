terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.0.0"
    }
  }
}

data "databricks_group" "users" {
  display_name = "users"
}

resource "databricks_sql_endpoint" "this" {
  name         = "Sample endpoint"
  cluster_size = "Small"

  enable_photon             = true
  enable_serverless_compute = true
}
