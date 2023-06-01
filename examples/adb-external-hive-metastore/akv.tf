resource "azurerm_key_vault" "akv1" {
  name                        = "${local.prefix}-akv"
  location                    = azurerm_resource_group.this.location
  resource_group_name         = azurerm_resource_group.this.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
}

resource "azurerm_key_vault_access_policy" "example" {
  key_vault_id       = azurerm_key_vault.akv1.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = data.azurerm_client_config.current.object_id
  key_permissions    = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore"]
  secret_permissions = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
}
