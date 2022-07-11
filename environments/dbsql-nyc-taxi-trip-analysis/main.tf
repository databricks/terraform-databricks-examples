terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.0.0"
    }
  }
}

provider "databricks" {
  # For an overview of possible authentication mechanisms, please refer to:
  # https://registry.terraform.io/providers/databricks/databricks/latest/docs#authentication
}

resource "databricks_sql_endpoint" "this" {
  name         = "Sample endpoint"
  cluster_size = "Small"

  enable_photon             = true
  enable_serverless_compute = true
}
