resource "databricks_secret_scope" "kv" {
  # akv backed secret scope
  name = "hive"
  keyvault_metadata {
    resource_id = var.key_vault_id
    dns_name    = var.vault_uri
  }
}

resource "azurerm_key_vault_secret" "hiveurl" {
  name         = "HIVE-URL"
  value        = local.db_url
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "hiveuser" {
  name         = "HIVE-USER"
  value        = var.db_username # use local group instead of var
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "hivepwd" {
  name         = "HIVE-PASSWORD"
  value        = var.db_password
  key_vault_id = var.key_vault_id
}
