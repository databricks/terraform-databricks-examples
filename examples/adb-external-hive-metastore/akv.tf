resource "azurerm_key_vault" "akv1" {
  name                        = "${local.prefix}-akv"
  location                    = local.rg_location
  resource_group_name         = local.rg_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "premium"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  enabled_for_disk_encryption = true
}

resource "azurerm_key_vault_access_policy" "this" {
  key_vault_id       = azurerm_key_vault.akv1.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = data.azurerm_client_config.current.object_id
  key_permissions    = ["Delete", "Get", "List", "Purge", "Recover", "Restore"]
  secret_permissions = ["Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
}
