# This module expects:
# - a workspace-level Databricks provider (authenticated to a UC-enabled workspace)
# - an AzureRM provider with permission to assign RBAC on the storage account / RG
#
# Example:
#
#   provider "databricks" {
#     host = "https://adb-xxxx.azuredatabricks.net"
#   }
#
#   provider "azurerm" {
#     features {}
#   }
