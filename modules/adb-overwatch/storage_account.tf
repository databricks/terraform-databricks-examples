resource "azurerm_storage_account" "owsa" {
  name                     = join("", [var.overwatch_storage_account_name, var.random_string])
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true

  identity {
    type = "SystemAssigned"
  }

  tags = {
    source = "Databricks"
    application = "Overwatch"
    description="Overwatch ETL database storage"
  }
}

resource "azurerm_storage_account" "logsa" {
  name                     = join("", [var.logs_storage_account_name, var.random_string])
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true

  identity {
    type = "SystemAssigned"
  }

  tags = {
    source = "Databricks"
    application = "Overwatch"
    description="Overwatch cluster logs storage"
  }
}

resource "azurerm_storage_data_lake_gen2_filesystem" "overwatch-db" {
  name               = "overwatch-db"
  storage_account_id = azurerm_storage_account.owsa.id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "cluster-logs" {
  name               = "cluster-logs"
  storage_account_id = azurerm_storage_account.logsa.id
}