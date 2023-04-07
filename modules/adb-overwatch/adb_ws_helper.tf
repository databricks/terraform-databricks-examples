data "azurerm_databricks_workspace" "adb-ws1" {
  name                = var.adb_ws1
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "databricks_token" "pat-ws1" {
  provider = databricks.adb-ws1
  comment = "Databricks PAT to be used by Overwatch jobs"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "cluster-logs-ws1" {
  name               = "cluster-logs-ws1"
  storage_account_id = azurerm_storage_account.logsa.id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "cluster-logs-ws2" {
  name               = "cluster-logs-ws2"
  storage_account_id = azurerm_storage_account.logsa.id
}

data "azurerm_monitor_diagnostic_categories" "dgs-cat1" {
  resource_id = data.azurerm_databricks_workspace.adb-ws1.id
}

resource "azurerm_monitor_diagnostic_setting" "dgs-ws1" {
  name               = "dgs-ws1"
  target_resource_id = data.azurerm_databricks_workspace.adb-ws1.id
  eventhub_name = azurerm_eventhub.eh1.name
  eventhub_authorization_rule_id = azurerm_eventhub_namespace_authorization_rule.ehnar.id

  dynamic "enabled_log" {
    iterator = log_category_type
    for_each = data.azurerm_monitor_diagnostic_categories.dgs-cat1.log_category_types
    content {
      category = log_category_type.value
      retention_policy {
        enabled = false
      }
    }
  }
}

resource "databricks_notebook" "quick_start_nb" {
  provider = databricks.adb-ws1
  source = "${path.module}/notebooks/quick-start-notebook.scala"
  path   = "/Notebooks/quick-start-notebook"
  format = "SOURCE"
  language = "SCALA"
}

data "azurerm_databricks_workspace" "adb-ws2" {
  name                = var.adb_ws2
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "databricks_token" "pat-ws2" {
  provider = databricks.adb-ws2
  comment = "Databricks PAT to be used by Overwatch jobs"
}

data "azurerm_monitor_diagnostic_categories" "dgs-cat2" {
  resource_id = data.azurerm_databricks_workspace.adb-ws2.id
}

resource "azurerm_monitor_diagnostic_setting" "dgs-ws2" {
  name               = "dgs-ws2"
  target_resource_id = data.azurerm_databricks_workspace.adb-ws2.id
  eventhub_name = azurerm_eventhub.eh2.name
  eventhub_authorization_rule_id = azurerm_eventhub_namespace_authorization_rule.ehnar.id

  dynamic "enabled_log" {
    iterator = log_category_type
    for_each = data.azurerm_monitor_diagnostic_categories.dgs-cat2.log_category_types
    content {
      category = log_category_type.value
      retention_policy {
        enabled = false
      }
    }
  }
}

resource "databricks_secret_scope" "overwatch-ws1" {
  provider = databricks.adb-ws1
  name                     = "overwatch"
  initial_manage_principal = "users"
}

resource "databricks_secret" "service_principal_key-ws1" {
  provider = databricks.adb-ws1
  key          = "service_principal_key"
  string_value = var.overwatch_spn_key
  scope        = databricks_secret_scope.overwatch-ws1.name
}

resource "databricks_secret_scope" "overwatch-ws2" {
  provider = databricks.adb-ws2
  name                     = "overwatch"
  initial_manage_principal = "users"
}

resource "databricks_secret" "service_principal_key-ws2" {
  provider = databricks.adb-ws2
  key          = "service_principal_key"
  string_value = var.overwatch_spn_key
  scope        = databricks_secret_scope.overwatch-ws2.name
}

resource "databricks_mount" "cluster_logs_ws1" {
  provider = databricks.adb-ws1
  name       = "cluster_logs"

  abfs {
    tenant_id              = var.tenant_id
    client_id              = var.overwatch_spn
    client_secret_scope    = databricks_secret_scope.overwatch.name
    client_secret_key      = databricks_secret.service_principal_key.key
    initialize_file_system = true
    storage_account_name   = azurerm_storage_account.logsa.name
    container_name         = azurerm_storage_data_lake_gen2_filesystem.cluster-logs-ws1.name
  }
}

resource "databricks_mount" "cluster_logs_ws2" {
  provider = databricks.adb-ws2
  name       = "cluster_logs"

  abfs {
    tenant_id              = var.tenant_id
    client_id              = var.overwatch_spn
    client_secret_scope    = databricks_secret_scope.overwatch.name
    client_secret_key      = databricks_secret.service_principal_key.key
    initialize_file_system = true
    storage_account_name   = azurerm_storage_account.logsa.name
    container_name         = azurerm_storage_data_lake_gen2_filesystem.cluster-logs-ws2.name
  }
}

resource "databricks_job" "test-job" {
  provider = databricks.adb-ws1

  name = "Test Job WS1"
  new_cluster{
    num_workers = 0
    spark_version           = data.databricks_spark_version.latest_lts.id
    node_type_id            = "Standard_DS3_v2"
    cluster_log_conf {
      dbfs {
      destination = "dbfs:/mnt/${databricks_mount.cluster_logs_ws1.name}"
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
    notebook_path = databricks_notebook.quick_start_nb.path
  }
}


//

resource "databricks_repo" "dlt_demo" {
  provider = databricks.adb-ws2

  url = "https://github.com/databricks/delta-live-tables-notebooks.git"
}

resource "databricks_pipeline" "dlt-pipeline" {
  provider = databricks.adb-ws2

  name    = "DLT Wikipedia Demo"
  storage = "/test/first-pipeline"

  cluster {
    label       = "default"
    num_workers = 1
    custom_tags = {
      cluster_type = "default"
    }

    cluster_log_conf {
      dbfs {
      destination = "dbfs:/mnt/${databricks_mount.cluster_logs_ws2.name}"
      }
    }
  }

  library {
    notebook {
      path = "${databricks_repo.dlt_demo.path}/sql/Wikipedia"
    }
  }
  filters {}

  continuous = false
}