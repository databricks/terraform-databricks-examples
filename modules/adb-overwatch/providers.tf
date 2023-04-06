terraform {
  required_version = ">=0.12"

  required_providers {
    databricks = {
      source = "databrickslabs/databricks"
      version = "~>0.5.7"
    }
  }
}

provider "databricks" {
  host = azurerm_databricks_workspace.adb.workspace_url
  azure_workspace_resource_id = azurerm_databricks_workspace.adb.id
}

provider "databricks" {
  alias = "adb-ws1"
  host = data.azurerm_databricks_workspace.adb-ws1.workspace_url
}

provider "databricks" {
  alias = "adb-ws2"
  host = data.azurerm_databricks_workspace.adb-ws2.workspace_url
}