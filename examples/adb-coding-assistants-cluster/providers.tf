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
    external = {
      source  = "hashicorp/external"
      version = ">=2.3.0"
    }
  }
}

# Determine authentication approach based on variables provided
locals {
  # Use profile-based auth if profile is specified
  use_profile_auth = var.databricks_profile != null

  # For Azure resource ID approach
  resource_regex            = var.databricks_resource_id != null ? "(?i)subscriptions/(.+)/resourceGroups/(.+)/providers/Microsoft.Databricks/workspaces/(.+)" : ""
  subscription_id_from_resource = var.databricks_resource_id != null ? regex(local.resource_regex, var.databricks_resource_id)[0] : null
  resource_group            = var.databricks_resource_id != null ? regex(local.resource_regex, var.databricks_resource_id)[1] : null
  databricks_workspace_name = var.databricks_resource_id != null ? regex(local.resource_regex, var.databricks_resource_id)[2] : null
}

# Get Azure subscription ID from Azure CLI or environment variable when not provided via resource ID
# This is needed for the Azure provider even when using profile-based Databricks auth
data "external" "azure_subscription" {
  count   = local.subscription_id_from_resource == null ? 1 : 0
  program = ["bash", "-c", "SUBSCRIPTION_ID=$(az account show --query id -o tsv 2>/dev/null || echo $${ARM_SUBSCRIPTION_ID:-}); echo \"{\\\"id\\\":\\\"$${SUBSCRIPTION_ID:-}\\\"}\""]
}

locals {
  # Use subscription ID from resource ID, or from Azure CLI/environment, or null (provider will try to auto-detect)
  subscription_id = coalesce(
    local.subscription_id_from_resource,
    try(data.external.azure_subscription[0].result.id != "" ? data.external.azure_subscription[0].result.id : null, null)
  )
}

# Data source to get current Azure client configuration (only for Azure resource ID approach)
data "azurerm_client_config" "current" {
  count = local.use_profile_auth ? 0 : 1
}

# Data source to get the resource group (only for Azure resource ID approach)
data "azurerm_resource_group" "this" {
  count = local.use_profile_auth ? 0 : 1
  name  = local.resource_group
}

# Configure the Azure Provider
# When using profile-based auth, subscription_id is not needed (provider will auto-detect if Azure CLI is configured)
# When using Azure resource ID approach, subscription_id is extracted from the resource ID
provider "azurerm" {
  subscription_id = local.subscription_id
  features {}
  skip_provider_registration = local.use_profile_auth
  
  # Allow provider to work without explicit subscription_id when using profile auth
  # It will attempt to auto-detect from Azure CLI or environment variables
}

# Data source to get the Databricks workspace (only for Azure resource ID approach)
data "azurerm_databricks_workspace" "this" {
  count               = local.use_profile_auth ? 0 : 1
  name                = local.databricks_workspace_name
  resource_group_name = local.resource_group
}

# Configure the Databricks Provider
# Two authentication approaches supported:
#
# 1. Profile-based (Recommended - Simple and cloud-agnostic):
#    Set databricks_profile variable to your ~/.databrickscfg profile name
#    Example: databricks_profile = "dok"
#
# 2. Azure resource ID (Azure-specific):
#    Set databricks_resource_id to your Azure Databricks workspace resource ID
#    Requires Azure CLI authentication (az login)
#
# See: https://docs.databricks.com/dev-tools/auth/unified-auth.html
provider "databricks" {
  profile = var.databricks_profile
  host    = local.use_profile_auth ? null : data.azurerm_databricks_workspace.this[0].workspace_url
}

