resource "azurerm_key_vault" "example" {
  count                       = var.key_vault_name != "" ? 1 : 0
  name                        = var.key_vault_name
  location                    = local.rg_location
  resource_group_name         = local.rg_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
  tags                        = var.tags
}
