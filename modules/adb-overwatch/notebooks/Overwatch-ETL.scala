// Databricks notebook source
import com.databricks.labs.overwatch.pipeline._
import com.databricks.labs.overwatch.utils._
import org.apache.spark.sql.DataFrame
import org.apache.spark.sql.functions._

// COMMAND ----------

// MAGIC %md
// MAGIC ## Some Helper Functions / Vars

// COMMAND ----------

// dbutils.widgets.removeAll
// dbutils.widgets.text("storagePrefix", "", "1. ETL Storage Prefix")
// dbutils.widgets.text("etlDBName", "overwatch_etl", "2. ETL Database Name")
// dbutils.widgets.text("consumerDBName", "overwatch", "3. Consumer DB Name")
// dbutils.widgets.text("secretsScope", "my_secret_scope", "4. Secret Scope")
// dbutils.widgets.text("dbPATKey", "my_key_with_api", "5. Secret Key (DBPAT)")
// dbutils.widgets.text("ehKey", "overwatch_eventhub_conn_string", "6. Secret Key (EH)")
// dbutils.widgets.text("ehName", "my_eh_name", "7. EH Topic Name")
// dbutils.widgets.text("primordialDateString", "2021-04-01", "8. Primordial Date")
// dbutils.widgets.text("maxDaysToLoad", "60", "9. Max Days")
// dbutils.widgets.text("scopes", "all", "A1. Scopes")

// COMMAND ----------

val workspaceID = dbutils.widgets.get("workspaceID")
val storagePrefix = dbutils.widgets.get("storagePrefix").toLowerCase // PRIMARY OVERWATCH OUTPUT PREFIX
val etlDB = dbutils.widgets.get("etlDBName").toLowerCase
val consumerDB = dbutils.widgets.get("consumerDBName").toLowerCase
val secretsScope = dbutils.widgets.get("secretsScope")
val dbPATKey = dbutils.widgets.get("dbPATKey")
val ehName = dbutils.widgets.get("ehName")
val ehKey = dbutils.widgets.get("ehKey")
val primordialDateString = dbutils.widgets.get("primordialDateString")
val maxDaysToLoad = dbutils.widgets.get("maxDaysToLoad").toInt
val scopes = if (dbutils.widgets.get("scopes") == "all") {
  "audit,sparkEvents,jobs,clusters,clusterEvents,notebooks,pools,accounts".split(",")
} else dbutils.widgets.get("scopes").split(",")

if (storagePrefix.isEmpty || consumerDB.isEmpty || etlDB.isEmpty || ehName.isEmpty || secretsScope.isEmpty || ehKey.isEmpty || dbPATKey.isEmpty) {
  throw new IllegalArgumentException("Please specify all required parameters!")
}

// COMMAND ----------

//val workspaceID = if (dbutils.notebook.getContext.tags("orgId") == "0") {
//  dbutils.notebook.getContext.tags("browserHostName").split("\\.")(0)
//} else dbutils.notebook.getContext.tags("orgId")

def pipReport(db: String): DataFrame = {
  val basePip = spark.table(s"${db}.pipeline_report")
    .filter('organization_id === workspaceID)
    .orderBy('Pipeline_SnapTS.desc, 'moduleID)
    .withColumn("fromTSt", from_unixtime('fromTS.cast("double") / lit(1000)).cast("timestamp"))
    .withColumn("untilTSt", from_unixtime('untilTS.cast("double") / lit(1000)).cast("timestamp"))
    .drop("runStartTS", "runEndTS", "dataFrequency", "lastOptimizedTS", "vacuumRetentionHours", "inputConfig", "parsedConfig")

  return basePip
}

// COMMAND ----------

// MAGIC %md
// MAGIC ## Setup Widgets For Simple Adjustments Or Job Configs
// MAGIC * Initiallize the widgets if running interactively
// MAGIC * Pull the widgets into usable variables to construct the config

// COMMAND ----------

// If first run this should be empty
// display(dbutils.fs.ls(s"${storagePrefix}/${workspaceID}").toDF)

// COMMAND ----------

// MAGIC %md
// MAGIC ## Construct the Overwatch Params and Instantiate Workspace

// COMMAND ----------

private val dataTarget = DataTarget(
  Some(etlDB), Some(s"${storagePrefix}/${workspaceID}/${etlDB}.db"), Some(s"${storagePrefix}/global_share"),
  Some(consumerDB), Some(s"${storagePrefix}/${workspaceID}/${consumerDB}.db")
)

private val tokenSecret = TokenSecret(secretsScope, dbPATKey)
private val ehConnString = s"{{secrets/${secretsScope}/${ehKey}}}"

private val ehStatePath = s"${storagePrefix}/${workspaceID}/ehState"
private val badRecordsPath = s"${storagePrefix}/${workspaceID}/sparkEventsBadrecords"
private val azureLogConfig = AzureAuditLogEventhubConfig(connectionString = ehConnString, eventHubName = ehName, auditRawEventsPrefix = ehStatePath)
private val interactiveDBUPrice = 0.56
private val automatedDBUPrice = 0.26

val params = OverwatchParams(
  auditLogConfig = AuditLogConfig(azureAuditLogEventhubConfig = Some(azureLogConfig)),
  dataTarget = Some(dataTarget),
  tokenSecret = Some(tokenSecret),
  badRecordsPath = Some(badRecordsPath),
  overwatchScope = Some(scopes),
  maxDaysToLoad = maxDaysToLoad,
  databricksContractPrices = DatabricksContractPrices(interactiveDBUPrice, automatedDBUPrice),
  primordialDateString = Some(primordialDateString)
)

private val args = JsonUtils.objToJson(params).compactString
val workspace = Initializer(args, debugFlag = true)

// COMMAND ----------

// MAGIC %md
// MAGIC ## Show the Config Strings
// MAGIC This is a good time to run the following commands for when you're ready to convert this to run as a job as a main class

// COMMAND ----------

JsonUtils.objToJson(params).escapedString

// COMMAND ----------

JsonUtils.objToJson(params).compactString

// COMMAND ----------

// MAGIC %md
// MAGIC ## Execute The Pipeline

// COMMAND ----------

Bronze(workspace).run()

// COMMAND ----------

Silver(workspace).run()

// COMMAND ----------

Gold(workspace).run()

// COMMAND ----------

// MAGIC %md
// MAGIC ## Show The Run Report

// COMMAND ----------

display(pipReport(etlDB))