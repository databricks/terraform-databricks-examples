resource "azurerm_databricks_access_connector" "unity" {
  name                = "${local.prefix}-databricks-mi"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_storage_account" "unity_catalog" {
  name                     = "${local.prefix}ucmetastore"
  resource_group_name      = data.azurerm_resource_group.this.name
  location                 = data.azurerm_resource_group.this.location
  tags                     = data.azurerm_resource_group.this.tags
  account_tier             = "Standard"
  account_replication_type = "ZRS"
  is_hns_enabled           = true

  network_rules {
    default_action = "Deny"
    bypass         = ["None"]
    private_link_access {
      endpoint_resource_id = azurerm_databricks_access_connector.unity.id
    }
  }
}

resource "azurerm_storage_container" "unity_catalog" {
  name                  = "${local.prefix}metastorecontainer"
  storage_account_name  = azurerm_storage_account.unity_catalog.name
  container_access_type = "private"
}

resource "azurerm_role_assignment" "example" {
  scope                = azurerm_storage_account.unity_catalog.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.unity.identity[0].principal_id
}
