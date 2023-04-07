data "azuread_service_principal" "overwatch-spn" {
  application_id = var.overwatch_spn_app_id
}

resource "azurerm_role_assignment" "data-contributor-role"{
  scope = azurerm_storage_account.owsa.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id = data.azuread_service_principal.overwatch-spn.object_id
}

resource "azurerm_role_assignment" "data-contributor-role-log"{
  scope = azurerm_storage_account.logsa.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id = data.azuread_service_principal.overwatch-spn.object_id
}