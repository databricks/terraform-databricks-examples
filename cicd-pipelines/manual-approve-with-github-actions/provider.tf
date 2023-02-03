terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}

provider "databricks" {
  # profile = "databricks-profile"
  auth_type = "databricks-cli"
}
