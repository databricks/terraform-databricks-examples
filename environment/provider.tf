terraform {
  required_providers {
    databricks = {
      source = "databrickslabs/databricks"
    }
  }
}

provider "databricks" {
  # profile = "databricks-profile"
  auth_type = "databricks-cli"
}
