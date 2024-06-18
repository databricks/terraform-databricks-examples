resource "databricks_secret_scope" "kv" {
  # akv backed secret scope
  name = "hive"
  keyvault_metadata {
    resource_id = azurerm_key_vault.akv1.id
    dns_name    = azurerm_key_vault.akv1.vault_uri
  }
}

resource "azurerm_key_vault_secret" "hiveurl" {
  name         = "HIVE-URL"
  value        = local.db_url
  key_vault_id = azurerm_key_vault.akv1.id
  depends_on   = [azurerm_key_vault.akv1]
}

resource "azurerm_key_vault_secret" "hiveuser" {
  name         = "HIVE-USER"
  value        = var.db_username
  key_vault_id = azurerm_key_vault.akv1.id
  depends_on   = [azurerm_key_vault.akv1]
}

resource "azurerm_key_vault_secret" "hivepwd" {
  name         = "HIVE-PASSWORD"
  value        = var.db_password
  key_vault_id = azurerm_key_vault.akv1.id
  depends_on   = [azurerm_key_vault.akv1]
}
