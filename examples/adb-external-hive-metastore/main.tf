/**
 * this example creates:
 * * Resource group with random prefix
 * * Tags, including `Owner`, which is taken from `az account show --query user`
 * * VNet with public and private subnet
 * * Databricks workspace
 * * External Hive Metastore for ADB workspace
 */

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

provider "random" {
}

# Use Azure CLI to authenticate at Azure Databricks account level, and the Azure Databricks workspace level
provider "databricks" {
  host = azurerm_databricks_workspace.this.workspace_url
}

resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

data "azurerm_client_config" "current" {
}

data "external" "me" {
  program = ["az", "account", "show", "--query", "user"]
}

locals {
  // dltp - databricks labs terraform provider
  prefix   = join("-", [var.workspace_prefix, "${random_string.naming.result}"])
  location = var.rglocation
  cidr     = var.spokecidr
  sqlcidr  = var.sqlvnetcidr
  dbfsname = join("", [var.dbfs_prefix, "${random_string.naming.result}"]) // dbfs name must not have special chars

  db_url            = "jdbc:sqlserver://${azurerm_mssql_server.metastoreserver.name}.database.windows.net:1433;database=${azurerm_mssql_database.sqlmetastore.name};user=${var.db_username}@${azurerm_mssql_server.metastoreserver.name};password={${var.db_password}};encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;"
  db_username_local = var.db_username
  db_password_local = var.db_password

  tags = {
    Environment = "Testing"
    Owner       = lookup(data.external.me.result, "name")
    Epoch       = random_string.naming.result
  }
}

resource "azurerm_resource_group" "this" {
  name     = "adb-dev-${local.prefix}-rg"
  location = local.location
  tags     = local.tags
}
