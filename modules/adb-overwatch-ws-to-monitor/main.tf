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

resource "databricks_secret_scope" "overwatch-akv" {
  name = var.databricks_secret_scope_name

  keyvault_metadata {
    resource_id = data.azurerm_key_vault.existing-kv.id
    dns_name    = data.azurerm_key_vault.existing-kv.vault_uri
  }
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
  name       = "cluster-logs"

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

// add overwatch config that will be written to the csv file
data "template_file" "ow-deployment-config" {
  template = file("${path.module}/overwatch_deployment_template.txt")
  vars = {
    workspace_name = data.azurerm_databricks_workspace.adb-ws.name
    workspace_id = data.azurerm_databricks_workspace.adb-ws.workspace_id
    workspace_url = "https://${data.azurerm_databricks_workspace.adb-ws.workspace_url}"
    api_url = "https://${data.azurerm_databricks_workspace.adb-ws.location}.azuredatabricks.net"
    cloud = "Azure"
    primordial_date = formatdate("YYYY-MM-DD", timestamp())
    etl_storage_prefix = var.etl_storage_prefix
    etl_database_name = "ow_etl_mws"
    consumer_database_name = "overwatch_consumer_mws"
    secret_scope = var.databricks_secret_scope_name
    secret_key_dbpat = azurerm_key_vault_secret.adb-pat.name
    auditlogprefix_source_path = var.auditlog_prefix_source_path
    eh_name = azurerm_eventhub.eh.name
    eh_scope_key = azurerm_key_vault_secret.eh-conn-string.name
    interactive_dbu_price = var.interactive_dbu_price
    automated_dbu_price = var.automated_dbu_price
    sql_compute_dbu_price = var.sql_compute_dbu_price
    jobs_light_dbu_price = var.jobs_light_dbu_price
    max_days = var.max_days
    excluded_scopes = var.excluded_scopes
    active = var.active
    proxy_host = var.proxy_host
    proxy_port = var.proxy_port
    proxy_user_name = var.proxy_user_name
    proxy_password_scope = var.proxy_password_scope
    proxy_password_key = var.proxy_password_key
    success_batch_size = var.success_batch_size
    error_batch_size = var.error_batch_size
    enable_unsafe_SSL = var.enable_unsafe_SSL
    thread_pool_size = var.thread_pool_size
    api_waiting_time = var.api_waiting_time
  }
}

locals {
  filename = "overwatch_deployment_config.csv"
}

data "template_cloudinit_config" "local" {
  gzip          = false
  base64_encode = false

  part {
    filename     = local.filename
    content      = data.template_file.ow-deployment-config.rendered
  }
}

resource "null_resource" "local" {
  triggers = {
    template = data.template_file.ow-deployment-config.rendered
  }

  provisioner "local-exec" {
    command = "echo \"${data.template_file.ow-deployment-config.rendered}\" >> \"${local.filename}\""
  }
}