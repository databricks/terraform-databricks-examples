resource "azurerm_role_assignment" "data-contributor-role"{
  scope = azurerm_storage_account.owsa.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id = var.service_principal_id_mount
}

resource "azurerm_role_assignment" "data-contributor-role-log"{
  scope = azurerm_storage_account.logsa.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id = var.service_principal_id_mount
}