
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

data "azurerm_client_config" "current" {
}

locals {
  resource_regex            = "(?i)subscriptions/(.+)/resourceGroups/(.+)/providers/Microsoft.Databricks/workspaces/(.+)"
  subscription_id           = regex(local.resource_regex, var.databricks_resource_id)[0]
  resource_group            = regex(local.resource_regex, var.databricks_resource_id)[1]
  databricks_workspace_name = regex(local.resource_regex, var.databricks_resource_id)[2]
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  prefix                    = replace(replace(replace(lower(data.azurerm_resource_group.this.name), "rg", ""), "-", ""), "_", "")
}

data "azurerm_resource_group" "this" {
  name = local.resource_group
}

data "azurerm_databricks_workspace" "this" {
  name                = local.databricks_workspace_name
  resource_group_name = local.resource_group
}

locals {
  databricks_workspace_host = data.azurerm_databricks_workspace.this.workspace_url
  databricks_workspace_id   = data.azurerm_databricks_workspace.this.workspace_id
}


provider "azurerm" {
  subscription_id = local.subscription_id
  features {}
}

provider "databricks" {
  host = local.databricks_workspace_host
}

# Create azure managed identity to be used by unity catalog metastore 
resource "azurerm_databricks_access_connector" "unity" {
  name                = "${local.prefix}-databricks-mi"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  identity {
    type = "SystemAssigned"
  }
}

# Create a storage account to be used by unity catalog metastore as root storage
resource "azurerm_storage_account" "unity_catalog" {
  name                     = "${local.prefix}storage121212"
  resource_group_name      = data.azurerm_resource_group.this.name
  location                 = data.azurerm_resource_group.this.location
  tags                     = data.azurerm_resource_group.this.tags
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
}

# Create a container in storage account to be used by unity catalog metastore as root storage
resource "azurerm_storage_container" "unity_catalog" {
  name                  = "${local.prefix}-container"
  storage_account_name  = azurerm_storage_account.unity_catalog.name
  container_access_type = "private"
}

# Assign the Storage Blob Data Contributor role to managed identity to allow unity catalog to access the storage
resource "azurerm_role_assignment" "mi_data_contributor" {
  scope                = azurerm_storage_account.unity_catalog.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.unity.identity[0].principal_id
}

# Create the first unity catalog metastore
resource "databricks_metastore" "this" {
  name = "primary"
  storage_root = format("abfss://%s@%s.dfs.core.windows.net/",
    azurerm_storage_container.unity_catalog.name,
  azurerm_storage_account.unity_catalog.name)
  force_destroy = true
}

# Assign managed identity to metastore
resource "databricks_metastore_data_access" "first" {
  metastore_id = databricks_metastore.this.id
  name         = "the-keys"
  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.unity.id
  }

  is_default = true
}

# Attach the databricks workspace to the metastore
resource "databricks_metastore_assignment" "this" {
  workspace_id         = local.databricks_workspace_id
  metastore_id         = databricks_metastore.this.id
  default_catalog_name = "hive_metastore"
}


# Initialize provider at Azure account-level
provider "databricks" {
  alias      = "azure_account"
  host       = "https://accounts.azuredatabricks.net"
  account_id = var.account_id
  auth_type  = "azure-cli"
}

locals {
  all_groups             = toset(keys(var.user_groups))
  all_users              = toset(flatten([for group in values(var.user_groups) : group.users]))
  all_service_principals = toset(flatten([for group in values(var.user_groups) : group.service_principals]))
}

// create or remove groups within databricks - all governed by "groups" variable
resource "databricks_group" "this" {
  provider     = databricks.azure_account
  for_each     = local.all_groups
  display_name = each.key
  force        = true
}

// all governed by AzureAD, create or remove users from databricks account
resource "databricks_user" "this" {
  provider     = databricks.azure_account
  for_each     = local.all_users
  user_name    = each.key
  display_name = each.key
  force        = true
}

// all governed by AzureAD, create or remove service principals from databricks accout
resource "databricks_service_principal" "this" {
  provider       = databricks.azure_account
  for_each       = local.all_service_principals
  application_id = each.key
  display_name   = each.key
  force          = true
}

// put users & service principams to respective groups
resource "databricks_group_member" "this" {
  provider   = databricks.azure_account
  depends_on = [databricks_group.this, databricks_user.this, databricks_service_principal.this]
  for_each = toset(flatten([
    for group, attr in var.user_groups : [
      for member in setunion(attr.users, attr.service_principals) : jsonencode({
        group  = group,
        member = member
      })
    ]
  ]))
  group_id  = jsondecode(each.value).group
  member_id = jsondecode(each.value).member
}

