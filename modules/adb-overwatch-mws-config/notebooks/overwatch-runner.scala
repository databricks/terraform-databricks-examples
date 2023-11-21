// Databricks notebook source
// MAGIC %md
// MAGIC ## 071.x Deployment Runner
// MAGIC This notebook is used to deploy Overwatch onto one or many workspaces
// MAGIC 
// MAGIC ### Parameters
// MAGIC `PATHTOCSVCONFIG` = Path to where the CSV was uploaded
// MAGIC 
// MAGIC `TEMPDIR` = Overwatch temporary working directory for intermediate / temporary files during the run
// MAGIC 
// MAGIC `ETLSTORAGEPREFIX` = `etl_storage_prefix` from the config file
// MAGIC 
// MAGIC `PARALLELISM` = Number of workspaces to load simultaneously -- Should == number of workspaces to deploy (up to a max of about 20, beyond that, larger drivers and high-throughput tuning may need to be implemented on the cluster)
// MAGIC 
// MAGIC ### REPORTS
// MAGIC This deployment method provides user-friendly reports including a validation report (if validation is executed) and a deployment report. Both of these reports are stored in the `<etl_storage_prefix>/report` folder
// MAGIC * Validation Report `<etl_storage_prefix>/report/validationReport` stored as Delta
// MAGIC * Deployment Report `<etl_storage_prefix>/report/deploymentReport` stored as Delta

// COMMAND ----------

import com.databricks.labs.overwatch.MultiWorkspaceDeployment

// COMMAND ----------

val TEMPDIR =  dbutils.widgets.get("TempDir")
val PARALLELISM =  dbutils.widgets.get("Parallelism").toInt
val ETLSTORAGEPREFIX =  dbutils.widgets.get("ETLStoragePrefix")
val PATHTOCSVCONFIG = dbutils.widgets.get("PathToCsvConfig")

// COMMAND ----------

display(
  spark.read.option("header", "true").csv(PATHTOCSVCONFIG)
)

// COMMAND ----------

MultiWorkspaceDeployment(PATHTOCSVCONFIG, TEMPDIR).validate(PARALLELISM)

// COMMAND ----------

display(
  spark.read.format("delta")
    .load(s"${ETLSTORAGEPREFIX}/report/validationReport")
)

// COMMAND ----------

MultiWorkspaceDeployment(PATHTOCSVCONFIG, TEMPDIR).deploy(PARALLELISM, "Bronze,Silver,Gold")

// COMMAND ----------

display(
  spark.read.format("delta")
    .load(s"${ETLSTORAGEPREFIX}/report/deploymentReport")
)

// COMMAND ----------


