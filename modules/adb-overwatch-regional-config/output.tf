output "ehn_name" {
  description = "Eventhubs namespace name"
  value = azurerm_eventhub_namespace.ehn.name
}

output "ehn_ar_name" {
  description = "Eventhubs namespace authorization rule name"
  value = azurerm_eventhub_namespace_authorization_rule.ehn-ar.name
}

output "logs_sa_name" {
  description = "Logs storage account name"
  value = azurerm_storage_account.log-sa.name
}

output "akv_name" {
  description = "AKV name"
  value = azurerm_key_vault.kv.name
}
