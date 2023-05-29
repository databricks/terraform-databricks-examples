// Resource Group
data "azurerm_resource_group" "rg" {
  name = var.rg_name
}


// Storage Account
resource "azurerm_storage_account" "log-sa" {
  name                     = join("", [var.logs_sa_name, var.random_string])
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true

  identity {
    type = "SystemAssigned"
  }

  tags = {
    source = "Databricks"
    application = "Overwatch"
    description="Overwatch cluster logs storage"
  }
}


// Role Assignment
data "azuread_service_principal" "overwatch-spn" {
  application_id = var.overwatch_spn_app_id
}

resource "azurerm_role_assignment" "data-contributor-role-log"{
  scope = azurerm_storage_account.log-sa.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id = data.azuread_service_principal.overwatch-spn.object_id
}


// Eventhubs
resource "azurerm_eventhub_namespace" "ehn" {
  name                = join("-", [var.ehn_name, var.random_string])
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "Basic"
  capacity            = 1

  tags = {
    environment = "Overwatch"
  }
}

resource "azurerm_eventhub_namespace_authorization_rule" "ehn-ar" {
  name                = join("-", [var.ehn_name, "ar", var.random_string])
  namespace_name      = azurerm_eventhub_namespace.ehn.name
  resource_group_name = data.azurerm_resource_group.rg.name
  listen              = true
  send                = true
  manage              = true
}

// AKV
data "azurerm_client_config" "current" {
}

resource "azurerm_key_vault" "kv" {
  name                = join("-", [var.key_vault_prefix, var.random_string])
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = var.rg_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  purge_protection_enabled = false
}


resource "azurerm_key_vault_access_policy" "kv-ap" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions    = [
    "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore", "Purge"
  ]
  secret_permissions = [
    "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"
  ]
  certificate_permissions = [
    "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore", "Purge"
  ]

  depends_on = [azurerm_key_vault.kv]
}

resource "azurerm_key_vault_secret" "spn-key"{
  name                     = "spn-key"
  value                    = var.overwatch_spn_secret
  expiration_date          = "2030-12-31T23:59:59Z"
  key_vault_id             = azurerm_key_vault.kv.id

  depends_on = [azurerm_key_vault_access_policy.kv-ap]
}