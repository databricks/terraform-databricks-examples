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

resource "databricks_secret_scope" "kv" {
  # akv backed secret scope
  name = "hive"
  keyvault_metadata {
    resource_id = azurerm_key_vault.akv1.id
    dns_name    = azurerm_key_vault.akv1.vault_uri
  }
  depends_on = [
    azurerm_key_vault.akv1,
  ]
}

resource "azurerm_key_vault_secret" "hiveurl" {
  name         = "HIVE-URL"
  value        = local.db_url
  key_vault_id = azurerm_key_vault.akv1.id
  depends_on = [
    azurerm_key_vault.akv1,
    azurerm_key_vault_access_policy.example, # need dependency on policy or else destroy can't clean up
  ]
}

resource "azurerm_key_vault_secret" "hiveuser" {
  name         = "HIVE-USER"
  value        = local.db_username_local # use local group instead of var
  key_vault_id = azurerm_key_vault.akv1.id
  depends_on = [
    azurerm_key_vault.akv1,
    azurerm_key_vault_access_policy.example,
  ]
}

resource "azurerm_key_vault_secret" "hivepwd" {
  name         = "HIVE-PASSWORD"
  value        = local.db_password_local
  key_vault_id = azurerm_key_vault.akv1.id
  depends_on = [
    azurerm_key_vault.akv1,
    azurerm_key_vault_access_policy.example,
  ]
}
