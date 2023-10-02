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

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

data "azurerm_resource_group" "this" {
  name = var.resource_group
}

data "azurerm_databricks_workspace" "this" {
  name                = var.databricks_workspace_name
  resource_group_name = var.resource_group
}

locals {
  databricks_workspace_host = data.azurerm_databricks_workspace.this.workspace_url
  databricks_workspace_id   = data.azurerm_databricks_workspace.this.workspace_id
  prefix                    = var.prefix
}

// Provider for databricks workspace
provider "databricks" {
  host = local.databricks_workspace_host
}

// Create azure managed identity to be used by unity catalog metastore
resource "azurerm_databricks_access_connector" "unity" {
  name                = "${local.prefix}-databricks-mi"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  identity {
    type = "SystemAssigned"
  }
}

// Create a storage account to be used by unity catalog metastore as root storage
resource "azurerm_storage_account" "unity_catalog" {
  name                     = "${local.prefix}storageaccuc"
  resource_group_name      = data.azurerm_resource_group.this.name
  location                 = data.azurerm_resource_group.this.location
  tags                     = data.azurerm_resource_group.this.tags
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
}

// Create a container in storage account to be used by unity catalog metastore as root storage
resource "azurerm_storage_container" "unity_catalog" {
  name                  = "${local.prefix}-container"
  storage_account_name  = azurerm_storage_account.unity_catalog.name
  container_access_type = "private"
}

// Assign the Storage Blob Data Contributor role to managed identity to allow unity catalog to access the storage
resource "azurerm_role_assignment" "mi_data_contributor" {
  scope                = azurerm_storage_account.unity_catalog.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.unity.identity[0].principal_id
}

// Create the first unity catalog metastore
resource "databricks_metastore" "this" {
  name = "primary"
  storage_root = format("abfss://%s@%s.dfs.core.windows.net/",
    azurerm_storage_container.unity_catalog.name,
  azurerm_storage_account.unity_catalog.name)
  force_destroy = true
  owner         = "account_unity_admin"
}

// Assign managed identity to metastore
resource "databricks_metastore_data_access" "first" {
  metastore_id = databricks_metastore.this.id
  name         = "the-metastore-key"
  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.unity.id
  }
  is_default = true
}

// Attach the databricks workspace to the metastore
resource "databricks_metastore_assignment" "this" {
  workspace_id         = local.databricks_workspace_id
  metastore_id         = databricks_metastore.this.id
  default_catalog_name = "hive_metastore"
}


// Initialize provider at Azure account-level
provider "databricks" {
  alias      = "azure_account"
  host       = "https://accounts.azuredatabricks.net"
  account_id = var.account_id
  auth_type  = "azure-cli"
}

locals {
  aad_groups = toset(var.aad_groups)
}

// Read group members of given groups from AzureAD every time Terraform is started
data "azuread_group" "this" {
  for_each     = local.aad_groups
  display_name = each.value
}

// Add groups to databricks account
resource "databricks_group" "this" {
  provider     = databricks.azure_account
  for_each     = data.azuread_group.this
  display_name = each.key
  external_id  = data.azuread_group.this[each.key].object_id
  force        = true
}

locals {
  all_members = toset(flatten([for group in values(data.azuread_group.this) : group.members]))
}

// Extract information about real users
data "azuread_users" "users" {
  ignore_missing = true
  object_ids     = local.all_members
}

locals {
  all_users = {
    for user in data.azuread_users.users.users : user.object_id => user
  }
}

// All governed by AzureAD, create or remove users to/from databricks account
resource "databricks_user" "this" {
  provider                 = databricks.azure_account
  for_each                 = local.all_users
  user_name                = lower(local.all_users[each.key]["user_principal_name"])
  display_name             = local.all_users[each.key]["display_name"]
  active                   = local.all_users[each.key]["account_enabled"]
  external_id              = each.key
  force                    = true
  disable_as_user_deletion = true # default behavior

// Review warning before deactivating or deleting users from databricks account
// https://learn.microsoft.com/en-us/azure/databricks/administration-guide/users-groups/scim/#add-users-and-groups-to-your-azure-databricks-account-using-azure-active-directory-azure-ad
  lifecycle {
    prevent_destroy = true
  }
}

// Extract information about service prinicpals users
data "azuread_service_principals" "spns" {
  object_ids = toset(setsubtract(local.all_members, data.azuread_users.users.object_ids))
}

locals {
  all_spns = {
    for sp in data.azuread_service_principals.spns.service_principals : sp.object_id => sp
  }
}

// All governed by AzureAD, create or remove service to/from databricks account
resource "databricks_service_principal" "sp" {
  provider       = databricks.azure_account
  for_each       = local.all_spns
  application_id = local.all_spns[each.key]["application_id"]
  display_name   = local.all_spns[each.key]["display_name"]
  active         = local.all_spns[each.key]["account_enabled"]
  external_id    = each.key
  force          = true
}

locals {
  account_admin_members = toset(flatten([for group in values(data.azuread_group.this) : [group.display_name == "account_unity_admin" ? group.members : []]]))
}
# Extract information about real account admins users
data "azuread_users" "account_admin_users" {
  ignore_missing = true
  object_ids     = local.account_admin_members
}

locals {
  all_account_admin_users = {
    for user in data.azuread_users.account_admin_users.users : user.object_id => user
  }
}

// Making all users on account_unity_admin group as databricks account admin
resource "databricks_user_role" "account_admin" {
  provider = databricks.azure_account
  for_each = local.all_account_admin_users
  user_id  = databricks_user.this[each.key].id
  role     = "account_admin"
  depends_on = [databricks_group.this, databricks_user.this, databricks_service_principal.sp]
}
