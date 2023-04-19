# Databricks notebook source
# MAGIC %md
# MAGIC ## READ ME
# MAGIC >
# MAGIC -  **Overwatch version - 07x**
# MAGIC -  **Widgets are added to apply filters to the dashboards**
# MAGIC -  **Please add your relevant ETL and consumer databases after the database widget appears**
# MAGIC -  **By default, the data is filtered as:**
# MAGIC    
# MAGIC | # | Widgets | Value | Default
# MAGIC | ----------- | ----------- | ----------- | ----------- |
# MAGIC | 1 | ETL Database Name | Your ETL Database Name | overwatch_etl
# MAGIC | 2 | Consumer DB Name | Your Consumer Database Name | overwatch
# MAGIC | 3 | Path Depth | Adjust folder/notebook path level | 2
# MAGIC | 4 | Workspace Name | List of workspace (overwatch deployed) name | all
# MAGIC | 5 | Start Date | Start date for analysis | 30 days from current date
# MAGIC | 6 | End Date | End date for analysis | current date
# MAGIC | 7 | Include weekends | To record all days, include weekends | Yes |
# MAGIC | 8 | Only weekends | To record only weekends | No |
# MAGIC >
# MAGIC - **Use the widgets to apply filters in the dashboards**
# MAGIC - **Once the filters applied, run the helper cmd (*""%run "./Helpers"""*) to reflect the filter in the master dataframe**
# MAGIC - **Go to View on topbar and select the *View* named as Notebook under *Dashboards* to view the plots alone**

# COMMAND ----------

# Removing all the widgets
# dbutils.widgets.removeAll()  # Run only for the first time

# COMMAND ----------

# Creating widget for getting database names
dbutils.widgets.text("etlDB", "overwatch_etl", "1. ETL Database Name")
dbutils.widgets.text("consumerDB", "overwatch", "2. Consumer DB Name")

# COMMAND ----------

# MAGIC %md
# MAGIC # Add the database names to the widgets

# COMMAND ----------

# To get the database names from widgets
etlDB = str(dbutils.widgets.get("etlDB"))
consumerDB = str(dbutils.widgets.get("consumerDB"))

# COMMAND ----------

# MAGIC %run "/Dashboards_Dev/In Progress/07x_rc_customer/Helpers" $etlDB = etlDB $consumerDB = consumerDB $folder_level = folder_level 

# COMMAND ----------

fetch_Name = spark.sql(f"select distinct workspace_name from {etlDB}.pipeline_report").rdd.flatMap(lambda x: x).collect()+["all"]
dbutils.widgets.multiselect("workspace_name","all",fetch_Name, "4. Workspace Name")

# COMMAND ----------

workspaceName =  spark.sql(f"select distinct workspace_name from {etlDB}.pipeline_report").rdd.flatMap(lambda x: x).collect() if 'all' in dbutils.widgets.get("workspace_name").split(',') else dbutils.widgets.get("workspace_name").split(',')

# COMMAND ----------

dbutils.widgets.combobox("5. Start Date", f"{date.today() - timedelta(days=30)}", "")
dbutils.widgets.combobox("6. End Date", f"{date.today()}", "")
dbutils.widgets.combobox("3. Path depth", "2", "")
dbutils.widgets.dropdown("include_weekends", "Yes", ["Yes", "No"], "7. Include weekends")
dbutils.widgets.dropdown("only_weekends", "No", ["Yes", "No"], "8. Only weekends")

# COMMAND ----------

folder_level = int(dbutils.widgets.get("3. Path depth"))
include_weekends = dbutils.widgets.get("include_weekends")
only_weekends = dbutils.widgets.get("only_weekends")
start_date = str(dbutils.widgets.get("5. Start Date"))
end_date = str(dbutils.widgets.get("6. End Date"))

# COMMAND ----------

# MAGIC %md
# MAGIC ### Once the filters applied, run the helper cmd (*""%run "./Helpers"""*) to reflect the filter in the master dataframe

# COMMAND ----------

master = master(etlDB, consumerDB, workspaceName, start_date, end_date)
sparkMaster = master.spark_notebook_master(includeWeekend = include_weekends, onlyWeekend = only_weekends, folder_level = folder_level)

notebook = spark.sql("select * from {}.notebook".format(consumerDB))
notebook = notebook.withColumn("folder_path", concat_ws('/', slice(split(col('notebook_path'), '/'), 1, folder_level + 1)))

# COMMAND ----------

# Data Intensive Notebooks (top 40 descending) 
# Read + Shuffle + Write GBs (stacked bar)

nb_throughput = sparkMaster\
.groupBy(sparkMaster["folder_path"], sparkMaster["organization_id"], sparkMaster["workspace_name"])\
.agg(
  round(((
  sum(sparkMaster.task_metrics.ShuffleReadMetrics.LocalBytesRead)
    + sum(sparkMaster.task_metrics.ShuffleReadMetrics.RemoteBytesRead)
    + sum(sparkMaster.task_metrics.ShuffleReadMetrics.RemoteBytesReadToDisk)
    + sum(sparkMaster.task_metrics.ShuffleWriteMetrics.ShuffleBytesWritten)
    + sum(sparkMaster.task_metrics.ShuffleWriteMetrics.ShuffleRecordsWritten)
    + sum(sparkMaster.task_metrics.ShuffleWriteMetrics.ShuffleWriteTime)
  )/1000000000),2).alias("TotalShuffle (GBs)")
,
  round(((
    sum(sparkMaster.task_metrics.InputMetrics.BytesRead)
     + sum(sparkMaster.task_metrics.InputMetrics.RecordsRead)
  )/1000000000), 2).alias("TotalReads (GBs)")
,
  round(((
    sum(sparkMaster.task_metrics.OutputMetrics.BytesWritten)
     + (sum(sparkMaster.task_metrics.OutputMetrics.RecordsWritten))
  )/1000000000), 2).alias("TotalWrites (GBs)")
)

Total_throughput = nb_throughput\
.withColumn('TotalThroughput (GBs)', round((col("TotalShuffle (GBs)") + col("TotalReads (GBs)") + col("TotalWrites (GBs)")), 2))\
.where(col("folder_path").isNotNull() & (col("folder_path") != ""))\
.orderBy(col('TotalThroughput (GBs)').desc())\
.limit(10)\
.toPandas()  

fig = px.bar(Total_throughput,
             x = "folder_path",
             y = ["TotalShuffle (GBs)", "TotalReads (GBs)", "TotalWrites (GBs)"],
             hover_data = ["organization_id", "workspace_name"],
             title = "Data Throughput For Path Depth")

fig = fig.update_layout(
    xaxis_title = "Path",
    yaxis_title = "Throughput (GB/s)",
    legend_title = "Task_Metrics",
)

fig.show()

# COMMAND ----------

display(Total_throughput)

# COMMAND ----------

# MAGIC %md
# MAGIC #### ResultSize  - How much data pulled out into the notebook

# COMMAND ----------

# sparkTask resultSize (total result size -- colored by avg result size for tasks with resultSize > 10KB)

resultSize = sparkMaster\
.groupBy(sparkMaster["folder_path"], sparkMaster["organization_id"], sparkMaster["workspace_name"])\
.agg(round(avg(sparkMaster.task_metrics.ResultSize)/1000000,2).alias("ResultSize (MB)"))\
.where(col("folder_path").isNotNull() & (col("folder_path") != ""))\
.orderBy(col('ResultSize (MB)').desc())\
.limit(10)\
.toPandas()  

fig = px.bar(resultSize,
             x = "folder_path",
             y = "ResultSize (MB)",         
             hover_data = ["organization_id", "workspace_name"],
             color_continuous_scale = ["green", "red"],
             color = "ResultSize (MB)", 
             title = " Returning a lot of data to the UI (Top 40)")

fig = fig.update_layout(
    xaxis_title = "Path",
    yaxis_title = "Total Result Size (MB)",
)

fig.show()

# COMMAND ----------

display(resultSize)

# COMMAND ----------

# Spark executions (i.e. actions) Count 

sp_execution = sparkMaster\
.groupBy(sparkMaster["folder_path"],
         sparkMaster["organization_id"],
         sparkMaster["workspace_name"])\
.agg(countDistinct(col('execution_id')).alias('Execution_count')
    ,round(sum(col('task_runtime.runTimeH')),2).alias("Execution_Runtime_Hrs")
    )\
.where(col("folder_path").isNotNull() & (col("folder_path") != ""))\
.orderBy(col("Execution_count").desc())\
.limit(10)\
.toPandas()  

fig = px.bar(sp_execution,
             x = "folder_path",
             y = "Execution_count",      
             color_continuous_scale = ["green", "red"],
             color = "Execution_Runtime_Hrs", 
             hover_data = ["organization_id", "workspace_name"],
             title = "Spark Actions (count)")

fig = fig.update_layout(
    xaxis_title = "Path",
    yaxis_title = "Count",   
)

fig.show()

# COMMAND ----------

display(sp_execution)

# COMMAND ----------

# largest records (1000s of records / MB) (higher is better -- meaning lower number of rec/mb means larger records)

nb_records = sparkMaster\
.groupBy(sparkMaster["folder_path"]
         ,sparkMaster["organization_id"]
         ,sparkMaster["workspace_name"]
        )\
.agg(
  (round(((
  sum(sparkMaster.task_metrics.ShuffleReadMetrics.LocalBytesRead)
    + sum(sparkMaster.task_metrics.ShuffleReadMetrics.RemoteBytesRead)
    + sum(sparkMaster.task_metrics.ShuffleReadMetrics.RemoteBytesReadToDisk)
    + sum(sparkMaster.task_metrics.ShuffleWriteMetrics.ShuffleBytesWritten)
    + sum(sparkMaster.task_metrics.ShuffleWriteMetrics.ShuffleRecordsWritten)
    + sum(sparkMaster.task_metrics.ShuffleWriteMetrics.ShuffleWriteTime)
  )/1024)/1000,2)).alias("TotalShuffle (MBs)")
,
  (round(((
    sum(sparkMaster.task_metrics.InputMetrics.BytesRead)
     + sum(sparkMaster.task_metrics.InputMetrics.RecordsRead)
  )/1024)/1000, 2)).alias("TotalReads (MBs)")
,
  (round(((
    sum(sparkMaster.task_metrics.OutputMetrics.BytesWritten)
     + (sum(sparkMaster.task_metrics.OutputMetrics.RecordsWritten))
  )/1024)/1000, 2)).alias("TotalWrites (MBs)")
)

NBlargestRecords = nb_records\
.withColumn('TotalThroughput (MBs)', round((col("TotalShuffle (MBs)") + col("TotalReads (MBs)") + col("TotalWrites (MBs)")), 2))\
.where(col("folder_path").isNotNull() & (col("folder_path") != ""))\
.orderBy(col('TotalThroughput (MBs)').desc())\
.limit(10)\
.toPandas() 

fig = px.bar(NBlargestRecords,
             x = "folder_path",
             y = ["TotalShuffle (MBs)", "TotalReads (MBs)", "TotalWrites (MBs)"],   
             hover_data = ["organization_id", "workspace_name", "TotalThroughput (MBs)"],
             title = "Largest records per path depth")

fig = fig.update_layout(
    xaxis_title = "Path",
    yaxis_title = "1000s of records per MB", 
)

fig.show()

# COMMAND ----------

display(NBlargestRecords)

# COMMAND ----------

# Task count by task type (stacked bar of number of task's count group by path)

cnt_cond = lambda cond: F.sum(F.when(cond, 1).otherwise(0))

SparkTask_type = sparkMaster\
.groupBy(sparkMaster["folder_path"], sparkMaster["organization_id"], sparkMaster["workspace_name"])\
.agg(
  (
    cnt_cond(F.col('task_metrics.InputMetrics.BytesRead') > 0)
    + cnt_cond(F.col('task_metrics.InputMetrics.RecordsRead') > 0)
  ).alias('InputMetrics_count')
  ,
  (
    cnt_cond(F.col('task_metrics.OutputMetrics.BytesWritten') > 0)
    + cnt_cond(F.col('task_metrics.OutputMetrics.RecordsWritten') > 0)
  ).alias('OutputMetrics_count')
  ,
  (
    cnt_cond(F.col('task_metrics.ShuffleReadMetrics.RemoteBytesRead') > 0) 
    + cnt_cond(F.col('task_metrics.ShuffleReadMetrics.RemoteBytesReadToDisk') > 0)
    + cnt_cond(F.col('task_metrics.ShuffleReadMetrics.LocalBytesRead') > 0)
    + cnt_cond(F.col('task_metrics.ShuffleWriteMetrics.ShuffleBytesWritten') > 0)
    + cnt_cond(F.col('task_metrics.ShuffleWriteMetrics.ShuffleRecordsWritten') > 0)
    + cnt_cond(F.col('task_metrics.ShuffleWriteMetrics.ShuffleWriteTime') > 0)
  ).alias('ShuffleMetrics_count')
)

SparkTask_typeCount = SparkTask_type\
.withColumn("Throughput_Count",
            SparkTask_type["InputMetrics_count"]
            + SparkTask_type["OutputMetrics_count"]
            + SparkTask_type["ShuffleMetrics_count"])\
.where(col("folder_path").isNotNull() & (col("folder_path") != ""))\
.orderBy(col('Throughput_Count').desc())\
.limit(10)\
.toPandas()  

fig = px.bar(SparkTask_typeCount,
             x = "folder_path",
             y = ["InputMetrics_count", "OutputMetrics_count", "ShuffleMetrics_count"],    
             hover_data = ["organization_id", "workspace_name"],
             title = "Task count by task type")

fig = fig.update_layout(
    xaxis_title = "Path",
    yaxis_title = "Task's Count", 
)

fig.show()

# COMMAND ----------

display(SparkTask_typeCount)

# COMMAND ----------

# Notebook Efficiency (most inefficient i.e. sorted -- top 40)
# Large tasks (count of tasks > 400MB) (lower is better)

spark_largeTask = sparkMaster\
.groupBy(sparkMaster["folder_path"], sparkMaster["organization_id"], sparkMaster["workspace_name"])\
.agg(
  round(((
  sum(sparkMaster.task_metrics.ShuffleReadMetrics.LocalBytesRead)
    + sum(sparkMaster.task_metrics.ShuffleReadMetrics.RemoteBytesRead)
    + sum(sparkMaster.task_metrics.ShuffleReadMetrics.RemoteBytesReadToDisk)
    + sum(sparkMaster.task_metrics.ShuffleWriteMetrics.ShuffleBytesWritten)
    + sum(sparkMaster.task_metrics.ShuffleWriteMetrics.ShuffleRecordsWritten)
    + sum(sparkMaster.task_metrics.ShuffleWriteMetrics.ShuffleWriteTime)
  )/1000000),2).alias("TotalShuffle (MBs)")
,
  round(((
    sum(sparkMaster.task_metrics.InputMetrics.BytesRead)
     + sum(sparkMaster.task_metrics.InputMetrics.RecordsRead)
  )/1000000), 2).alias("TotalReads (MBs)")
,
  round(((
    sum(sparkMaster.task_metrics.OutputMetrics.BytesWritten)
     + (sum(sparkMaster.task_metrics.OutputMetrics.RecordsWritten))
  )/1000000), 2).alias("TotalWrites (MBs)")
)

spark_largeTasks = spark_largeTask\
.withColumn('TotalThroughput (MBs)', round((col("TotalShuffle (MBs)") + col("TotalReads (MBs)") + col("TotalWrites (MBs)")), 2))\
.where((col("TotalShuffle (MBs)") > 400) | (col("TotalReads (MBs)") > 400) | (col("TotalWrites (MBs)") > 400))\
.where(col("folder_path").isNotNull() & (col("folder_path") != ""))\
.orderBy(col("TotalThroughput (MBs)").asc())\
.limit(10)\
.toPandas()  

fig = px.bar(spark_largeTasks,
             x = "folder_path",
             y = ["TotalShuffle (MBs)", "TotalReads (MBs)", "TotalWrites (MBs)"],
             hover_data = ["organization_id", "workspace_name"],
             title = " Large Tasks Count (> 400MB)")

fig = fig.update_layout(
    xaxis_title = "Path",
    yaxis_title = "Large tasks",
    legend_title = "Task_Metrics",
)

fig.show()

# COMMAND ----------

display(spark_largeTasks)

# COMMAND ----------

# Compute Intensive Notebooks
# Notebooks with longest compute times
  
longestNotebooks = sparkMaster\
.groupBy(sparkMaster["folder_path"], sparkMaster["organization_id"], sparkMaster["workspace_name"], sparkMaster["Execution_type"])\
.agg(round(sum("task_runtime.runTimeH"),2).alias("total_runtime (hrs)"))\
.where(col("folder_path").isNotNull() & (col("folder_path") != ""))\
.orderBy(col("total_runtime (hrs)").desc())\
.limit(10)\
.toPandas()  

fig = px.bar(longestNotebooks,
             x = "folder_path",
             y = "total_runtime (hrs)",
             color_continuous_scale = ["green", "red"],
             hover_data = ["organization_id", "workspace_name", "Execution_type"],
             color = "Execution_type",
             title = "Longest Running per path depth")

fig = fig.update_layout(
    xaxis_title = "Path",
    yaxis_title = "Execution Runtime (Hrs)",
)

fig.show()

# COMMAND ----------

display(longestNotebooks)

# COMMAND ----------

# # Jobs Executing on Notebooks (count)

# JobsNotebook = sparkMaster.join(notebook, notebook.folder_path == sparkMaster.folder_path, "inner")\
# .where(sparkMaster["db_job_id"].isNotNull() & sparkMaster["db_id_in_job"].isNotNull())\
# .where((sparkMaster["folder_path"].isNotNull()) & (sparkMaster["folder_path"] != ""))\
# .groupBy(sparkMaster["folder_path"], sparkMaster["organization_id"], sparkMaster["workspace_name"])\
# .agg(countDistinct(notebook["notebook_id"]).alias("Notebook_Count"))\
# .limit(10)\
# .toPandas()  

# fig = px.bar(JobsNotebook,
#              x = "folder_path",
#              y = "Notebook_Count",
#              color_continuous_scale = ["green", "red"],
#              color = "Notebook_Count", 
#              hover_data = ["organization_id", "workspace_name"],
#              title = " No. of notebooks executing via jobs")

# fig = fig.update_layout(
#     xaxis_title = "Path",
#     yaxis_title = "Count",
# )

# fig.show()


# Jobs Executing on Notebooks (count)

jobrun = spark.sql("select job_id from {}.jobrun where task_type in ('notebook','pipeline','python')".format(consumerDB))

jb = jobrun.join(sparkMaster, jobrun['job_id'] == sparkMaster['db_job_id'], "inner")


JobsNotebook = jb.join(notebook, notebook.folder_path == jb.folder_path, "inner")\
.where(jb["db_job_id"].isNotNull() & jb["db_id_in_job"].isNotNull())\
.where((jb["folder_path"].isNotNull()) & (jb["folder_path"] != ""))\
.groupBy(jb["folder_path"], jb["organization_id"], jb["workspace_name"])\
.agg(countDistinct(notebook["notebook_id"]).alias("Notebook_Count"))\
.limit(10)\
.toPandas() 

fig = px.bar(JobsNotebook,
             x = "folder_path",
             y = "Notebook_Count",
             color_continuous_scale = ["green", "red"],
             color = "Notebook_Count", 
             hover_data = ["organization_id", "workspace_name"],
             title = "No. of notebooks executing via jobs per path depth")

fig = fig.update_layout(
    xaxis_title = "Path",
    yaxis_title = "Count",
)

fig.show()

# COMMAND ----------

display(JobsNotebook)

# COMMAND ----------

# Jobs Executing on Notebooks (count) which is not configured from workflow

jobrun = spark.sql("select job_id from {}.jobrun where task_type not in ('notebook','pipeline','python')".format(consumerDB))

jb1 = jobrun.join(sparkMaster, jobrun['job_id'] == sparkMaster['db_job_id'], "inner")


JobsNotebook1 = jb1.join(notebook, notebook.folder_path == jb1.folder_path, "inner")\
.where(jb1["db_job_id"].isNotNull() & jb1["db_id_in_job"].isNotNull())\
.where((jb1["folder_path"].isNotNull()) & (jb1["folder_path"] != ""))\
.groupBy(jb1["folder_path"], jb1["organization_id"], jb1["workspace_name"])\
.agg(countDistinct(notebook["notebook_id"]).alias("Notebook_Count"))\
.limit(10)\
.toPandas() 

fig = px.bar(JobsNotebook1,
             x = "folder_path",
             y = "Notebook_Count",
             color_continuous_scale = ["green", "red"],
             color = "Notebook_Count", 
             hover_data = ["organization_id", "workspace_name"],
             title = " No. of notebooks executing via jobs per path depth")

fig = fig.update_layout(
    xaxis_title = "Path",
    yaxis_title = "Count",
)

fig.show()

# COMMAND ----------

# Notebook Efficiency (most inefficient i.e. sorted -- top 40)
# Disk / Memory spill (stacked bar by notebook) (lower is better) (desc)

NotebookSpills = sparkMaster\
.groupBy(sparkMaster["folder_path"], sparkMaster["organization_id"], sparkMaster["workspace_name"])\
.agg((sum(col('MemoryBytesSpilled'))/1000000000).alias("MemorySpilled (GB)")
    ,(sum(col('DiskBytesSpilled'))/1000000000).alias("DiskSpilled (GB)")
    )\
.where(col("folder_path") != "")

NBTotalSpills = NotebookSpills\
.withColumn("TotalSpills (GB)", (NotebookSpills["MemorySpilled (GB)"] + NotebookSpills["DiskSpilled (GB)"]))\
.orderBy(col("TotalSpills (GB)").desc())\
.limit(10)\
.toPandas()

fig = px.bar(NBTotalSpills,
             x = "folder_path",
             y = ["MemorySpilled (GB)","DiskSpilled (GB)"],
             hover_data = ["organization_id", "workspace_name"],
             title = "Total Spills per path depth")

fig = fig.update_layout(
    xaxis_title = "Path",
    yaxis_title = "Total Spills",
)

fig.show()

# COMMAND ----------

display(NotebookSpills)

# COMMAND ----------

# Notebook Efficiency (most inefficient i.e. sorted -- top 40)  
# Processing speed (MB/sec) -- (read+shuffled+written) (mb) / taskRuntime (sec) (higher is better) (P0)

ProcessSpeed = sparkMaster\
.groupBy(sparkMaster["folder_path"], sparkMaster["organization_id"], sparkMaster["workspace_name"])\
.agg(
  round(((
  sum(sparkMaster.task_metrics.ShuffleReadMetrics.LocalBytesRead)
    + sum(sparkMaster.task_metrics.ShuffleReadMetrics.RemoteBytesRead)
    + sum(sparkMaster.task_metrics.ShuffleReadMetrics.RemoteBytesReadToDisk)
    + sum(sparkMaster.task_metrics.ShuffleWriteMetrics.ShuffleBytesWritten)
    + sum(sparkMaster.task_metrics.ShuffleWriteMetrics.ShuffleRecordsWritten)
    + sum(sparkMaster.task_metrics.ShuffleWriteMetrics.ShuffleWriteTime)
  )/1000000),2).alias("TotalShuffle (MBs)")
,
  round(((
    sum(sparkMaster.task_metrics.InputMetrics.BytesRead)
     + sum(sparkMaster.task_metrics.InputMetrics.RecordsRead)
  )/1000000), 2).alias("TotalReads (MBs)")
,
  round(((
    sum(sparkMaster.task_metrics.OutputMetrics.BytesWritten)
     + (sum(sparkMaster.task_metrics.OutputMetrics.RecordsWritten))
  )/1000000), 2).alias("TotalWrites (MBs)")
,
  round((sum(sparkMaster.task_runtime.runTimeS)),2).alias("TaskRunTime (sec)")    #take nanoseconds
)

ProcessSpeedDF = ProcessSpeed\
.withColumn('ProcessSpeed (MB/sec)',
            round(((col("TotalShuffle (MBs)") + col("TotalReads (MBs)") + col("TotalWrites (MBs)"))/(col("TaskRunTime (sec)"))), 2)
           )\
.where((col("folder_path") != "") & 
  (col("ProcessSpeed (MB/sec)")>0) 
)\
.orderBy(col("ProcessSpeed (MB/sec)").asc())\
.limit(10)\
.toPandas()cccccbgfbkbrbiucnruhcjligndiutjkjrfffeicubek


fig = px.bar(ProcessSpeedDF,
             x = "folder_path",
             y = "ProcessSpeed (MB/sec)",
             hover_data = ["organization_id", "workspace_name"],
             title = "Processing Speed (MB/sec)")

fig = fig.update_layout(
    xaxis_title = "Path",
    yaxis_title = "ProcessSpeed (MB/sec)"
)

fig.show()

# COMMAND ----------

display(ProcessSpeedDF)

# COMMAND ----------

Notebook_failedJobs = sparkMaster\
.where(
  (sparkMaster["job_result.Result"] == "JobFailed")
  & ((col("task_info.Failed") == True) | (col("task_info.Killed") == True))
  & ((col("task_info.speculative") == False))  
  & ((col("folder_path") != ""))
  )\
.withColumn("Failed_Count", when(((col("task_info.Failed") == True) | (col("task_info.Killed") == True)), lit(1)).otherwise(lit(0)))

JobRuntime = Notebook_failedJobs\
.groupBy(Notebook_failedJobs["folder_path"]
         ,Notebook_failedJobs["organization_id"]
         ,Notebook_failedJobs["workspace_name"]
        )\
.agg(
  round(avg(Notebook_failedJobs["task_runtime.runTimeH"]), 2).alias("AvgRunTimeH")
 ,  round(sum(Notebook_failedJobs["Failed_Count"]), 2).alias("Failed_Count")
  )\
.orderBy(col("AvgRunTimeH").desc())\
.limit(10)\
.toPandas()

fig = px.bar(JobRuntime,
             x = "folder_path",
             y = ["AvgRunTimeH", "Failed_Count"],
             color = "AvgRunTimeH",
             color_continuous_scale = ["green", "red"],
             hover_data = ["organization_id", "workspace_name"],
             title = "Longest Running Failed Spark Jobs")
             
fig = fig.update_layout(
    xaxis_title = "Path",
    yaxis_title = "Job runtime (hrs)"
)

fig.show()

# COMMAND ----------

display(JobRuntime)

# COMMAND ----------

# Notebook Efficiency (most inefficient i.e. sorted -- top 40)
# Serde time (stacked bar - ExecutorDeserializeTime + ResultSerializationTime)(minutes) (lower is better) (P0)

SerdeTime = sparkMaster\
.where(col("folder_path") != '')\
.where(col("db_job_id").isNull())\
.groupBy(sparkMaster["folder_path"], sparkMaster["organization_id"], sparkMaster["workspace_name"])\
.agg(
  round(sum("task_metrics.ExecutorDeserializeTime"), 2).alias("ExecutorDeserializeTime")
 ,round(sum("task_metrics.ResultSerializationTime"), 2).alias("ResultSerializationTime")
)\
.withColumn("Serde_Time (mins)", (col("ExecutorDeserializeTime") + col("ResultSerializationTime")))\
.orderBy(col("Serde_Time (mins)").desc())\
.limit(10)\
.toPandas()

fig = px.bar(SerdeTime,
             x = "folder_path",
             y = ["ExecutorDeserializeTime", "ResultSerializationTime"],
             hover_data = ["organization_id", "workspace_name", "Serde_Time (mins)"],
             title = "Serde time")
             
fig = fig.update_layout(
    xaxis_title = "Path",
    yaxis_title = "Serde_Time (mins)",
    legend_title = "Serde Time"
)

fig.show()

# COMMAND ----------

display(SerdeTime)

# COMMAND ----------

# Most popular (distinct users) notebooks -- top 10 -- bar chart 

DistinctUserNB = sparkMaster\
.where((col("folder_path") != '')
      & (col("db_job_id").isNull()))\
.groupBy(sparkMaster["folder_path"]
         ,sparkMaster["organization_id"]
         ,sparkMaster["workspace_name"])\
.agg(
  round(sum("task_runtime.runTimeH"), 2).alias("runTimeH")
 ,countDistinct("notebook_id").alias("Notebook_Count")
 ,countDistinct("user_email").alias("Distinct_Users")
 )\
.orderBy(col("Distinct_Users").desc())\
.limit(10)\
.toPandas()

fig = px.bar(DistinctUserNB,
             x = "folder_path",
             y = "Distinct_Users",
             color_continuous_scale = ["green", "red"],
             color = "runTimeH", 
             hover_data = ["organization_id", "workspace_name", "Notebook_Count", "runTimeH"],
             title = " Most popular (distinct users) notebooks per path depth")
             
fig = fig.update_layout(
    xaxis_title = "Path",
    yaxis_title = "Distinct Users",
)

fig.show()

# COMMAND ----------

display(DistinctUserNB)

# COMMAND ----------

NBComputeHrs = sparkMaster\
.where((col("folder_path") != '')
      & col("db_job_id").isNull())\
.groupBy(sparkMaster["organization_id"], sparkMaster["workspace_name"], sparkMaster["date"])\
.agg(
  round(sum("task_runtime.runTimeH"), 2).alias("runTimeH")
 )\
.orderBy(col("runTimeH").desc())\
.limit(50)\
.toPandas()

fig = px.box(
  NBComputeHrs,
  x = "workspace_name",
  y = "runTimeH",
  title = "Notebook Compute Hours per path depth",
  points = "outliers",
  height = 500,
  width = 900,
  color = "workspace_name")

fig.show()

# COMMAND ----------

display(NBComputeHrs)

# COMMAND ----------

NBExecutionID = sparkMaster\
.where((col("folder_path") != '')
      & col("db_job_id").isNull())\
.groupBy(sparkMaster["organization_id"], sparkMaster["folder_path"], sparkMaster["workspace_name"])\
.agg(countDistinct("execution_id").alias("execution_id"))\
.where(col("execution_id") > 1)\
.orderBy(col("execution_id").desc())\
.limit(10)\
.toPandas()

fig = px.bar(NBExecutionID,
             x = "folder_path",
             y = "execution_id",      
             color_continuous_scale = ["green", "red"],
             color = "execution_id", 
             hover_data = ["organization_id", "workspace_name"],
             title = "Spark Actions (count)")

fig = fig.update_layout(
    xaxis_title = "Path",
    yaxis_title = "ExecutionID Count",  
)

fig.show()

# COMMAND ----------

display(NBExecutionID)

# COMMAND ----------

ShuffleExplosion = nb_throughput\
.where(nb_throughput["folder_path"] != '')\
.withColumn("Explosion_Ratio", (round((col("TotalWrites (GBs)")/col("TotalReads (GBs)")),2)))

ExplosionRatio = ShuffleExplosion\
.where(col("Explosion_Ratio").isNotNull() & (col("Explosion_Ratio") > 0))\
.orderBy(col("Explosion_Ratio").desc())\
.limit(10)\
.toPandas()

fig = px.bar(ExplosionRatio,
             x = "folder_path",
             y = "Explosion_Ratio",
             color_continuous_scale = ["green", "red"],
             color = "Explosion_Ratio", 
             hover_data = ["organization_id", "workspace_name"],
             title = "Largest Shuffle Explosions")
             
fig = fig.update_layout(
    xaxis_title = "Path",
    yaxis_title = "Explosion_Ratio",
)

fig.show()

# COMMAND ----------

display(ExplosionRatio)

# COMMAND ----------

# MAGIC %md
# MAGIC ## TESTING

# COMMAND ----------

# Jobs Executing on Notebooks (count)

jobrun = spark.sql("select job_id from {}.jobrun where task_type in ('notebook','pipeline','python')".format(consumerDB))

jb = jobrun.join(sparkMaster, jobrun['job_id'] == sparkMaster['db_job_id'], "inner")

JobsNotebook = jb.join(notebook, notebook.folder_path == jb.folder_path, "inner")\
.where(jb["db_job_id"].isNotNull() & jb["db_id_in_job"].isNotNull())\
.where((jb["folder_path"].isNotNull()) & (jb["folder_path"] != ""))\
.groupBy(jb["folder_path"], jb["organization_id"], jb["workspace_name"])\
.agg(countDistinct(notebook["notebook_id"]).alias("Notebook_Count"))\
.limit(10)\
.toPandas() 

fig = px.bar(JobsNotebook,
             x = "folder_path",
             y = "Notebook_Count",
             color_continuous_scale = ["green", "red"],
             color = "Notebook_Count", 
             hover_data = ["organization_id", "workspace_name"],
             title = " No. of notebooks executing via jobs")

fig = fig.update_layout(
    xaxis_title = "Path",
    yaxis_title = "Count",
)

fig.show()

# COMMAND ----------

# Jobs Executing on Notebooks (count)

jobrun = spark.sql("select job_id from {}.jobrun where task_type not in ('notebook','pipeline','python')".format(consumerDB))

jb1 = jobrun.join(sparkMaster, jobrun['job_id'] == sparkMaster['db_job_id'], "inner")


JobsNotebook1 = jb1.join(notebook, notebook.folder_path == jb1.folder_path, "inner")\
.where(jb1["db_job_id"].isNotNull() & jb1["db_id_in_job"].isNotNull())\
.where((jb1["folder_path"].isNotNull()) & (jb1["folder_path"] != ""))\
.groupBy(jb1["folder_path"], jb1["organization_id"], jb1["workspace_name"])\
.agg(countDistinct(notebook["notebook_id"]).alias("Notebook_Count"))\
.limit(10)\
.toPandas() 

fig = px.bar(JobsNotebook1,
             x = "folder_path",
             y = "Notebook_Count",
             color_continuous_scale = ["green", "red"],
             color = "Notebook_Count", 
             hover_data = ["organization_id", "workspace_name"],
             title = " No. of notebooks executing via jobs")

fig = fig.update_layout(
    xaxis_title = "Path",
    yaxis_title = "Count",
)

fig.show()