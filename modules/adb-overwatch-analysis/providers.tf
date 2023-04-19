terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}

/*
provider "databricks" {
  host = data.azurerm_databricks_workspace.adb-ws.workspace_url
}*/
