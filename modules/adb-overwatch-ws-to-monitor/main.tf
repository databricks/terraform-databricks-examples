// Resource Group
data "azurerm_resource_group" "rg" {
  name = var.rg_name
}


// Azure Databricks ws
data "azurerm_databricks_workspace" "adb-ws" {
  name                = var.adb_ws_name
  resource_group_name = var.rg_name
}

resource "databricks_token" "pat-ws" {
  comment = "Databricks PAT to be used by Overwatch jobs"
}


// EH topic
data "azurerm_eventhub_namespace_authorization_rule" "ehn-ar" {
  name                = var.ehn_auth_rule_name
  resource_group_name = var.rg_name
  namespace_name      = var.ehn_name
}

resource "azurerm_eventhub" "eh" {
  name                = "eh-overwatch-${data.azurerm_databricks_workspace.adb-ws.name}"
  namespace_name      = var.ehn_name
  resource_group_name = var.rg_name
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventhub_authorization_rule" "eh-ar" {
  name                = "eh-auth-rule-${data.azurerm_databricks_workspace.adb-ws.name}"
  namespace_name      = var.ehn_name
  eventhub_name       = azurerm_eventhub.eh.name
  resource_group_name = data.azurerm_resource_group.rg.name
  listen              = true
  send                = true
  manage              = true
}


// Diagnostics Logs
data "azurerm_monitor_diagnostic_categories" "dgs-cat" {
  resource_id = data.azurerm_databricks_workspace.adb-ws.id
}

resource "azurerm_monitor_diagnostic_setting" "dgs-ws" {
  name               = "dgs-${data.azurerm_databricks_workspace.adb-ws.name}"
  target_resource_id = data.azurerm_databricks_workspace.adb-ws.id
  eventhub_name = azurerm_eventhub.eh.name
  eventhub_authorization_rule_id = data.azurerm_eventhub_namespace_authorization_rule.ehn-ar.id

  dynamic "enabled_log" {
    iterator = log_category_type
    for_each = data.azurerm_monitor_diagnostic_categories.dgs-cat.log_category_types
    content {
      category = log_category_type.value
      retention_policy {
        enabled = false
      }
    }
  }
}


// AKV
data "azurerm_key_vault" "existing-kv" {
  name                = var.akv_name
  resource_group_name = var.rg_name
}

data "azurerm_key_vault_secret" "spn-key" {
  name         = "spn-key"
  key_vault_id = data.azurerm_key_vault.existing-kv.id
}

resource "azurerm_key_vault_secret" "adb-pat"{
  name                     = "pat-${data.azurerm_databricks_workspace.adb-ws.name}"
  value                    = databricks_token.pat-ws.token_value
  expiration_date          = "2030-12-31T23:59:59Z"
  key_vault_id             = data.azurerm_key_vault.existing-kv.id
}

resource "azurerm_key_vault_secret" "eh-conn-string"{
  name                     = "eh-primary-conn-${data.azurerm_databricks_workspace.adb-ws.name}"
  value                    = azurerm_eventhub_authorization_rule.eh-ar.primary_connection_string
  expiration_date          = "2030-12-31T23:59:59Z"
  key_vault_id             = data.azurerm_key_vault.existing-kv.id
}


// Mount point to the Logs storage account
data "azurerm_storage_account" "logs-sa" {
  name                = var.logs_sa_name
  resource_group_name = var.rg_name
}

resource "azurerm_storage_data_lake_gen2_filesystem" "cluster-logs-fs" {
  name               = "cluster-logs-${data.azurerm_databricks_workspace.adb-ws.name}"
  storage_account_id = data.azurerm_storage_account.logs-sa.id
}

resource "databricks_mount" "cluster-logs-mount-ws" {
  name       = "cluster-logs-mount-${data.azurerm_databricks_workspace.adb-ws.name}"

  abfs {
    tenant_id              = var.tenant_id
    client_id              = var.overwatch_spn_app_id
    client_secret_scope    = var.databricks_secret_scope_name
    client_secret_key      = data.azurerm_key_vault_secret.spn-key.name
    initialize_file_system = true
    storage_account_name   = data.azurerm_storage_account.logs-sa.name
    container_name         = azurerm_storage_data_lake_gen2_filesystem.cluster-logs-fs.name
  }
}

// add config for csv file