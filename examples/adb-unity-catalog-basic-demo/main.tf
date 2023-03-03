
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

provider "azurerm" {
  subscription_id = local.subscription_id
  features {}
}

provider "databricks" {
  alias      = "azure_account"
  host       = "https://accounts.azuredatabricks.net"
  account_id = var.account_id
  auth_type  = "azure-cli"
}

module "metastore_and_users" {
  source                    = "./modules/metastore-and-users"
  subscription_id           = local.subscription_id
  databricks_workspace_name = local.databricks_workspace_name
  resource_group            = local.resource_group
  aad_groups                = var.aad_groups
  account_id                = var.account_id
  prefix                    = local.prefix
}


locals {
  merged_user_sp = merge(module.metastore_and_users.databricks_users, module.metastore_and_users.databricks_sps)
}

locals {
  aad_groups = toset(var.aad_groups)
}

# Read group members of given groups from AzureAD every time Terraform is started
data "azuread_group" "this" {
  for_each     = local.aad_groups
  display_name = each.value
}


// Put users and service principals to their respective groups
resource "databricks_group_member" "this" {
  provider = databricks.azure_account
  for_each = toset(flatten([
    for group, details in data.azuread_group.this : [
      for member in details["members"] : jsonencode({
        group  = module.metastore_and_users.databricks_groups[details["object_id"]],
        member = local.merged_user_sp[member]
      })
    ]
  ]))
  group_id   = jsondecode(each.value).group
  member_id  = jsondecode(each.value).member
  depends_on = [module.metastore_and_users]
}

