/**
 * this example creates:
 * * Resource group with random prefix
 * * Tags, including `Owner`, which is taken from `az account show --query user`
 * * VNet with public and private subnet
 * * Databricks workspace
 * * External Hive Metastore for ADB workspace
 */

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

# Retrieve information about the current user (the caller of tf apply)
data "databricks_current_user" "me" {
  depends_on = [azurerm_databricks_workspace.this]
}

data "databricks_spark_version" "latest_lts" {
  long_term_support = true
  latest            = true
  depends_on        = [azurerm_databricks_workspace.this]
}


locals {
  // dltp - databricks labs terraform provider
  prefix   = join("-", [var.workspace_prefix, "${random_string.naming.result}"])
  location = var.rglocation
  cidr     = var.spokecidr
  sqlcidr  = var.sqlvnetcidr
  dbfsname = join("", [var.dbfs_prefix, "${random_string.naming.result}"]) // dbfs name must not have special chars
  db_url   = "jdbc:sqlserver://${azurerm_mssql_server.metastoreserver.name}.database.windows.net:1433;database=${azurerm_mssql_database.sqlmetastore.name};user=${var.db_username}@${azurerm_mssql_server.metastoreserver.name};password={${var.db_password}};encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;"

  tags = {
    Environment = "Testing"
    Owner       = lookup(data.external.me.result, "name")
    Epoch       = random_string.naming.result
  }
}

resource "azurerm_resource_group" "this" {
  name     = "adb-test-${local.prefix}-rg"
  location = local.location
  tags     = local.tags
}
