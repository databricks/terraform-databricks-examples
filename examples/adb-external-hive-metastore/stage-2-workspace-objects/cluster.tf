data "databricks_spark_version" "latest_lts" {
  long_term_support = true
  latest            = true
}

resource "databricks_cluster" "coldstart" {
  cluster_name            = "cluster - external metastore"
  spark_version           = data.databricks_spark_version.latest_lts.id
  node_type_id            = var.node_type
  autotermination_minutes = 30
  autoscale {
    min_workers = 1
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
    databricks_secret_scope.kv,
    azurerm_key_vault_secret.hiveuser,
    azurerm_key_vault_secret.hivepwd,
    azurerm_key_vault_secret.hiveurl
  ]
}
