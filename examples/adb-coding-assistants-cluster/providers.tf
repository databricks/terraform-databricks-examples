terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.31.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.81.1"
    }
  }
}

# Data source to get current Azure client configuration
data "azurerm_client_config" "current" {}

# Extract subscription ID, resource group, and workspace name from resource ID
locals {
  resource_regex            = "(?i)subscriptions/(.+)/resourceGroups/(.+)/providers/Microsoft.Databricks/workspaces/(.+)"
  subscription_id           = regex(local.resource_regex, var.databricks_resource_id)[0]
  resource_group            = regex(local.resource_regex, var.databricks_resource_id)[1]
  databricks_workspace_name = regex(local.resource_regex, var.databricks_resource_id)[2]
}

# Data source to get the resource group
data "azurerm_resource_group" "this" {
  name = local.resource_group
}

# Configure the Azure Provider
provider "azurerm" {
  subscription_id = local.subscription_id
  features {}
}

# Data source to get the Databricks workspace
data "azurerm_databricks_workspace" "this" {
  name                = local.databricks_workspace_name
  resource_group_name = local.resource_group
}

# Configure the Databricks Provider
# Authentication uses Databricks unified authentication:
# 1. Environment variables (DATABRICKS_HOST, DATABRICKS_TOKEN) - Recommended for CI/CD
# 2. Azure CLI authentication (az login) - Recommended for local development
# 3. Configuration profile (~/.databrickscfg) - Alternative for local development
#
# See: https://docs.databricks.com/dev-tools/auth/unified-auth.html
provider "databricks" {
  host = data.azurerm_databricks_workspace.this.workspace_url
  # No explicit authentication configured - uses unified authentication
}

