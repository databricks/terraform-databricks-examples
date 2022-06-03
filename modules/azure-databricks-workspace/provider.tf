terraform {
  required_providers {
    databricks = {
      source = "databrickslabs/databricks"
    }
  }
}


provider "databricks" {
  profile = "databricks-profile"
}