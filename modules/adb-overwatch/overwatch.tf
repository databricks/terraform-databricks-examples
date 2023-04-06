resource "azurerm_databricks_workspace" "adb" {
  name                = var.overwatch_ws_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  sku                 = "premium"

  tags = {
    Environment = "Overwatch"
  }
}

/*data "azurerm_databricks_workspace" "adb" {
  name                = azurerm_databricks_workspace.adb.name
  resource_group_name = azurerm_resource_group.rg.name
}*/

/*resource "databricks_secret_scope" "overwatch-akv" {
  name                     = "overwatch-akv"
  initial_manage_principal = "users"

  keyvault_metadata {
    resource_id = var.kv_id
    dns_name    = var.kv_vault_uri
  }
}*/

resource "databricks_secret_scope" "overwatch" {
  name                     = "overwatch"
  initial_manage_principal = "users"
}

resource "databricks_secret" "secret-ws1" {
  key          = "pat-ws1"
  string_value = databricks_token.pat-ws1.token_value
  scope        = databricks_secret_scope.overwatch.name
}

resource "databricks_secret" "secret-ws2" {
  key          = "pat-ws2"
  string_value = databricks_token.pat-ws2.token_value
  scope        = databricks_secret_scope.overwatch.name
}

resource "databricks_secret" "eh-conn-ws1" {
  key          = "eh-connection-key-ws1"
  string_value = azurerm_eventhub_authorization_rule.eh1-ar.primary_connection_string
  scope        = databricks_secret_scope.overwatch.name
}

resource "databricks_secret" "eh-conn-ws2" {
  key          = "eh-connection-key-ws2"
  string_value = azurerm_eventhub_authorization_rule.eh2-ar.primary_connection_string
  scope        = databricks_secret_scope.overwatch.name
}

resource "databricks_secret" "service_principal_key" {
  key          = "service_principal_key"
  string_value = var.overwatch_spn_key
  scope        = databricks_secret_scope.overwatch.name
}

resource "databricks_mount" "overwatch_db" {
  name       = "overwatch-etl-db"
  # cluster_id = "0314-132342-7nhy02wq" # local.cluster_id

  abfs {
    tenant_id              = var.tenant_id
    client_id              = var.overwatch_spn
    client_secret_scope    = databricks_secret_scope.overwatch.name
    client_secret_key      = databricks_secret.service_principal_key.key
    initialize_file_system = true
    storage_account_name   = azurerm_storage_account.owsa.name
    container_name         = azurerm_storage_data_lake_gen2_filesystem.overwatch-db.name
  }
}

resource "databricks_mount" "cluster_logs" {
  name       = "cluster-logs"
  # cluster_id = "0314-132342-7nhy02wq" # local.cluster_id

  abfs {
    tenant_id              = var.tenant_id
    client_id              = var.overwatch_spn
    client_secret_scope    = databricks_secret_scope.overwatch.name
    client_secret_key      = databricks_secret.service_principal_key.key
    initialize_file_system = true
    storage_account_name   = azurerm_storage_account.logsa.name
    container_name         = azurerm_storage_data_lake_gen2_filesystem.cluster-logs.name
  }
}

data "databricks_spark_version" "latest_lts" {
  long_term_support = true
  depends_on = [azurerm_databricks_workspace.adb]
}

//Upload Databricks notebook
resource "databricks_notebook" "overwatch_etl" {
  source = "${path.module}/notebooks/overwatch-runner.scala"
  path   = "/Overwatch/ETL/overwatch-runner"
  format = "SOURCE"
  language = "SCALA"
}

resource "databricks_dbfs_file" "overwatch_deployment_config" {
  source = "${path.module}/config/overwatch_deployment_config.csv"
  path   = "/mnt/${databricks_mount.overwatch_db.name}/config/overwatch_deployment_config.csv"
}

resource "databricks_job" "overwatch" {
  name = "Overwatch ETL Job"
  new_cluster{
    num_workers = 0
    spark_version           = data.databricks_spark_version.latest_lts.id
    node_type_id            = "Standard_DS3_v2"

    cluster_log_conf {
      dbfs {
      destination = "dbfs:/mnt/${databricks_mount.cluster_logs.name}/${azurerm_databricks_workspace.adb.name}"
      }
    }

    spark_conf = {
      # Single-node
      "spark.databricks.cluster.profile" : "singleNode"
      "spark.master" : "local[*]"
    }
    custom_tags =  {"ResourceClass" : "SingleNode"}
  }
  notebook_task {
    notebook_path = "/Overwatch/ETL/overwatch-runner"
    base_parameters = {
      "TempDir": "/tmp/overwatch/",
      "Parallelism": 4,
      "ETLStoragePrefix": "/mnt/${databricks_mount.overwatch_db.name}/ow_multi_ws",
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

//Upload Databricks notebooks used to analyse the Overwatch results
resource "databricks_notebook" "overwatch_analysis" {
  for_each = toset(["Cluster", "Helpers", "Jobs", "Notebook", "Readme", "Workspace"])
  source = "${path.module}/notebooks/${each.key}.py"
  path   = "/Overwatch/Analysis/${each.key}"
  format = "SOURCE"
  language = "PYTHON"
}