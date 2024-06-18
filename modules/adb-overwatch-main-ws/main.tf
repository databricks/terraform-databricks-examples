data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

// Create a new workspace for Overwatch
resource "azurerm_databricks_workspace" "adb-new-ws" {
  count = var.use_existing_ws ? 0 : 1
  name                = var.overwatch_ws_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  sku                 = "premium"

  tags = {
    Environment = "Overwatch"
  }
}

// Use an existing workspace for Overwatch
data "azurerm_databricks_workspace" "adb-existing-ws" {
  count = var.use_existing_ws ? 1 : 0
  name                = var.overwatch_ws_name
  resource_group_name = var.rg_name
}


data "databricks_spark_version" "latest_lts" {
  provider = databricks.ow-main-ws
  long_term_support = true
  depends_on = [azurerm_databricks_workspace.adb-new-ws]
}