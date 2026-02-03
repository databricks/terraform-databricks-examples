terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}

provider "databricks" {
  # For an overview of possible authentication mechanisms, please refer to:
  # https://registry.terraform.io/providers/databricks/databricks/latest/docs#authentication
  alias         = "workspace"
  host          = var.workspace_host
}
