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
