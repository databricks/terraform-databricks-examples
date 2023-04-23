terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }

    databricks = {
      source = "databricks/databricks"
    }
  }
}

provider "databricks" {
  alias = "ow-main-ws"
  host = var.use_existing_ws ? one(data.azurerm_databricks_workspace.adb-existing-ws[*].workspace_url) : one(azurerm_databricks_workspace.adb-new-ws[*].workspace_url)
}