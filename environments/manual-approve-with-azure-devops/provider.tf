terraform {
  required_providers {
    databricks = {
      source = "databrickslabs/databricks"
    }
  }
}

provider "databricks" {
  auth_type = "pat"
}
