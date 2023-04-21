data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

data "azurerm_databricks_workspace" "overwatch-ws" {
  name                = var.overwatch_ws_name
  resource_group_name = var.rg_name
}

// Storage Account
resource "azurerm_storage_account" "ow-sa" {
  name                     = join("", [var.ow_sa_name, var.random_string])
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
    description="Overwatch ETL database storage"
  }
}

resource "azurerm_storage_data_lake_gen2_filesystem" "overwatch-db" {
  name               = "overwatch-db"
  storage_account_id = azurerm_storage_account.ow-sa.id
}

// Role Assignment
data "azuread_service_principal" "overwatch-spn" {
  application_id = var.overwatch_spn_app_id
}

resource "azurerm_role_assignment" "data-contributor-role"{
  scope = azurerm_storage_account.ow-sa.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id = data.azuread_service_principal.overwatch-spn.object_id
}

// AKV data
data "azurerm_key_vault" "existing-kv" {
  name                = var.akv_name
  resource_group_name = var.rg_name
}

resource "databricks_secret_scope" "overwatch-akv" {
  name = var.databricks_secret_scope_name

  keyvault_metadata {
    resource_id = data.azurerm_key_vault.existing-kv.id
    dns_name    = data.azurerm_key_vault.existing-kv.vault_uri
  }

}

data "azurerm_key_vault_secret" "spn-key" {
  name         = "spn-key"
  key_vault_id = data.azurerm_key_vault.existing-kv.id
}

resource "databricks_mount" "overwatch_db" {
  name       = "overwatch-etl-db"

  abfs {
    tenant_id              = var.tenant_id
    client_id              = var.overwatch_spn_app_id
    client_secret_scope    = var.databricks_secret_scope_name
    client_secret_key      = data.azurerm_key_vault_secret.spn-key.name
    initialize_file_system = true
    storage_account_name   = azurerm_storage_account.ow-sa.name
    container_name         = azurerm_storage_data_lake_gen2_filesystem.overwatch-db.name
  }
}

locals {
  etl_storage_prefix = "/mnt/${databricks_mount.overwatch_db.name}/ow_multi_ws"
}

resource "databricks_job" "overwatch" {
  name = "Overwatch ETL Job"
  new_cluster{
    autoscale {
        min_workers = 1
        max_workers = 3
    }
    spark_version           = var.latest_dbr_lts
    node_type_id            = "Standard_DS3_v2"

    spark_conf = {
      "fs.azure.account.auth.type" : "OAuth"
      "fs.azure.account.oauth.provider.type" : "org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider"
      "fs.azure.account.oauth2.client.endpoint" : "https://login.microsoftonline.com/${var.tenant_id}/oauth2/token"
      "fs.azure.account.oauth2.client.id" : var.overwatch_spn_app_id
      "fs.azure.account.oauth2.client.secret" : "{{secrets/${var.databricks_secret_scope_name}/${data.azurerm_key_vault_secret.spn-key.name}}}"
      "spark.hadoop.fs.azure.account.auth.type" : "OAuth"
      "spark.hadoop.fs.azure.account.oauth.provider.type" : "org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider"
      "spark.hadoop.fs.azure.account.oauth2.client.endpoint" : "https://login.microsoftonline.com/${var.tenant_id}/oauth2/token"
      "spark.hadoop.fs.azure.account.oauth2.client.id" : var.overwatch_spn_app_id
      "spark.hadoop.fs.azure.account.oauth2.client.secret" : "{{secrets/${var.databricks_secret_scope_name}/${data.azurerm_key_vault_secret.spn-key.name}}}"

    }
  }
  notebook_task {
    notebook_path = "/Overwatch/ETL/overwatch-runner"
    base_parameters = {
      "TempDir": "/tmp/overwatch/",
      "Parallelism": 4,
      "ETLStoragePrefix": local.etl_storage_prefix,
      "PathToCsvConfig": "/mnt/${databricks_mount.overwatch_db.name}/config/overwatch_deployment_config.csv"
    }
  }

  library {
    maven {
    coordinates = "com.microsoft.azure:azure-eventhubs-spark_2.12:2.3.21"
    exclusions  = []
    }
  }
  library{
    maven {
    coordinates = "com.databricks.labs:${var.overwatch_version}"
    exclusions  = []
    }
  }
  email_notifications {

    on_failure = [var.overwatch_job_notification_email]
    no_alert_for_skipped_runs = false

  }

  schedule{
    quartz_cron_expression = var.cron_job_schedule
    timezone_id = var.cron_timezone_id
    pause_status = "PAUSED"
  }
}

//Upload Databricks notebook
resource "databricks_notebook" "overwatch_etl" {
  source = "${path.module}/notebooks/overwatch-runner.scala"
  path   = "/Overwatch/ETL/overwatch-runner"
  format = "SOURCE"
  language = "SCALA"
}
