resource "azurerm_databricks_workspace" "this" {
  name                         = "${local.prefix}-workspace"
  resource_group_name          = azurerm_resource_group.this.name
  location                     = azurerm_resource_group.this.location
  sku                          = "premium"
  tags                         = local.tags
  customer_managed_key_enabled = true
  //infrastructure_encryption_enabled = true
  custom_parameters {
    no_public_ip                                         = var.no_public_ip
    virtual_network_id                                   = azurerm_virtual_network.this.id
    private_subnet_name                                  = azurerm_subnet.private.name
    public_subnet_name                                   = azurerm_subnet.public.name
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.public.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.private.id
    storage_account_name                                 = local.dbfsname
  }
  # We need this, otherwise destroy doesn't cleanup things correctly
  depends_on = [
    azurerm_subnet_network_security_group_association.public,
    azurerm_subnet_network_security_group_association.private
  ]
}

resource "databricks_global_init_script" "metastoreinit" {
  source = "./initscripts/external_metastore_init.sh"
  name   = "basic init script to enforce on every cluster in workspace that uses external metastore"
}

provider "databricks" {
  host = azurerm_databricks_workspace.this.workspace_url
}

data "databricks_spark_version" "latest_lts" {
  long_term_support = true
  depends_on = [
    azurerm_databricks_workspace.this
  ]
}

resource "databricks_cluster" "coldstart" {
  count                   = var.cold_start ? 1 : 0
  cluster_name            = "cluster - external metastore"
  spark_version           = data.databricks_spark_version.latest_lts.id
  node_type_id            = var.node_type
  autotermination_minutes = 30
  autoscale {
    min_workers = 0
    max_workers = 1
  }

  spark_conf = {
    "spark.hadoop.javax.jdo.option.ConnectionDriverName" : "com.microsoft.sqlserver.jdbc.SQLServerDriver",
    "spark.hadoop.javax.jdo.option.ConnectionURL" : "{{secrets/hive/HIVE-URL}}",
    "spark.hadoop.metastore.catalog.default" : "hive",
    "spark.databricks.delta.preview.enabled" : true,
    "spark.hadoop.javax.jdo.option.ConnectionUserName" : "{{secrets/hive/HIVE-USER}}",
    "datanucleus.fixedDatastore" : true,
    "spark.hadoop.javax.jdo.option.ConnectionPassword" : "{{secrets/hive/HIVE-PASSWORD}}",
    "datanucleus.autoCreateSchema" : false,
    "spark.sql.hive.metastore.jars" : "/dbfs/tmp/hive/3-1-0/lib/*",
    "spark.sql.hive.metastore.version" : "3.1.0",
  }

  spark_env_vars = {
    "HIVE_PASSWORD" = "{{secrets/hive/HIVE-PASSWORD}}",
    "HIVE_USER"     = "{{secrets/hive/HIVE-USER}}",
    "HIVE_URL"      = "{{secrets/hive/HIVE-URL}}",
  }
  depends_on = [
    azurerm_databricks_workspace.this,
    databricks_secret_scope.kv, # need this to be able to access the secrets
    azurerm_key_vault_secret.hiveuser,
    azurerm_key_vault_secret.hivepwd,
    azurerm_key_vault_secret.hiveurl
  ]
}
