# Databricks notebook source
# MAGIC %md
# MAGIC # Read Me
# MAGIC >
# MAGIC - **Replace the ETL DB and Consumer DB with your ETL database name and Consumer database name**
# MAGIC - **Workspace names are picked automatically from your overwatch data once completing the run of cmd 5**
# MAGIC - **Start Date and End Date will be picked up with past 30 days by default**
# MAGIC 
# MAGIC Widgets Used:
# MAGIC | # | Widgets | Value | Default
# MAGIC | ----------- | ----------- | ----------- | ----------- |
# MAGIC | 1 | ETL Database Name | Your ETL Database Name | None
# MAGIC | 2 | Consumer DB Name | Your Consumer Database Name | None
# MAGIC | 3 | Workspace Name | List of workspace (overwatch deployed) name | all
# MAGIC | 4 | Start Date | Start date for analysis | 30 days prior to the present
# MAGIC | 5 | End Date | End date for analysis | Current Date
# MAGIC | 6 | Include weekends | To record all days, include weekends | Yes |
# MAGIC | 7 | Only weekends | To record only weekends | No |
# MAGIC >
# MAGIC - **Use the widgets to filter the data based on your requirement**
# MAGIC - **Please skip the Azure code (27 & 28) if you are under AWS cloud and vice versa.**

# COMMAND ----------

# Run only for the first time and comment it out after the first run
# dbutils.widgets.removeAll()

# COMMAND ----------

dbutils.widgets.text("etlDB", "", "1. ETL Database Name")
dbutils.widgets.text("consumerDB", "", "2. Consumer DB Name")

# COMMAND ----------

# MAGIC %md
# MAGIC ###Populate Widget Boxes 1 and 2 before proceeding
# MAGIC ##### The following cells must know the Overwatch database names before they can execute. Please populate the cells before continuing.

# COMMAND ----------

etlDB = str(dbutils.widgets.get("etlDB"))
consumerDB = str(dbutils.widgets.get("consumerDB"))

# COMMAND ----------

# MAGIC %run "./Helpers" $etlDB = etlDB $consumerDB = consumerDB

# COMMAND ----------

fetch_Name = spark.sql(f"select distinct workspace_name from {etlDB}.pipeline_report").rdd.flatMap(lambda x: x).collect()+["all"]
dbutils.widgets.multiselect("workspace_name","all",fetch_Name, "4. Workspace Name")

# COMMAND ----------

workspaceName =  spark.sql(f"select distinct workspace_name from {etlDB}.pipeline_report").rdd.flatMap(lambda x: x).collect() if 'all' in dbutils.widgets.get("workspace_name").split(',') else dbutils.widgets.get("workspace_name").split(',')

# COMMAND ----------

dbutils.widgets.combobox("5. Start Date", f"{date.today() - timedelta(days=30)}", "")
dbutils.widgets.combobox("6. End Date", f"{date.today()}", "")

start_date = str(dbutils.widgets.get("5. Start Date"))
end_date = str(dbutils.widgets.get("6. End Date"))

dbutils.widgets.dropdown("include_weekends", "Yes", ["Yes", "No"], "6. Include weekends")
dbutils.widgets.dropdown("only_weekends", "No", ["Yes", "No"], "7. Only weekends")
include_weekends = dbutils.widgets.get("include_weekends")
only_weekends = dbutils.widgets.get("only_weekends")

# COMMAND ----------

# MAGIC %md
# MAGIC ### Once the filters applied, run the helper cmd (*""%run "./Helpers"""*) to reflect the filter in the master dataframe

# COMMAND ----------

masters = master(etlDB, consumerDB, workspaceName,start_date,end_date)

# COMMAND ----------

cluster_master = masters.cluster_master_filter(includeWeekend = include_weekends,onlyWeekend = only_weekends)
job_master = masters.job_test_filter(includeWeekend = include_weekends,
                                       onlyWeekend = only_weekends,
                                       dateColumn="job_start_date")

# COMMAND ----------

# MAGIC %md
# MAGIC **What is the cost of each workspace ?**

# COMMAND ----------

costByDate = cluster_master\
.groupBy(["state_start_date", "organization_id",
          "workspace_name", "cluster_id"])\
.agg(round(sum(cluster_master["total_dbu_cost"]/cluster_master["days_in_state"]), 2).alias("cost_by_date"))\
.groupBy(["state_start_date", "organization_id",
          "workspace_name"])\
.agg(round(sum(col("cost_by_date")), 2).alias("DBU_Cost (USD)"))\
.orderBy(col('DBU_Cost (USD)').desc())

# costByDate.loc[costByDate['DBU_Cost (USD)'] < 3,'workspace_name'] = 'Other Types'

windowDept = Window.partitionBy("state_start_date").orderBy(col("DBU_Cost (USD)").desc())
costByDate_p = costByDate.withColumn("row",row_number().over(windowDept)) \
  .filter(col("row") <= 20)

top20Workspaces = costByDate.join(costByDate_p, ((costByDate.state_start_date == costByDate_p.state_start_date) & (costByDate.organization_id == costByDate_p.organization_id) & (costByDate.workspace_name == costByDate_p.workspace_name)), 'left')\
.select(costByDate['*'], col('row'))

top20Workspaces_p = top20Workspaces.withColumn('organization_id', expr("case when row is null then 'Others' else organization_id end"))\
.withColumn('workspace_name', expr("case when row is null then 'Others' else workspace_name end"))\
.groupby('state_start_date', 'organization_id', 'workspace_name')\
.agg(round(sum(col('DBU_Cost (USD)')), 2).alias('DBU_Cost (USD)'))\
.orderBy(col('DBU_Cost (USD)').desc())

# Converting pyspark to pandas for visualization
costByDate_pandas = top20Workspaces_p.toPandas()


fig = px.bar(costByDate_pandas, 
             x = "state_start_date",
             y = "DBU_Cost (USD)",
             hover_data = ["organization_id",
                            "workspace_name"],
             color = "workspace_name", 
             color_discrete_sequence = px.colors.sequential.Rainbow,
             title = "Daily cluster spend chart")

# # Visualizing the graph
fig.show()

# COMMAND ----------

# MAGIC %md
# MAGIC **What is the cost of each workspace ?**

# COMMAND ----------

costByOrg = cluster_master\
.groupBy(["organization_id",
          "workspace_name"])\
.agg(round(sum(cluster_master["total_dbu_cost"]), 2).alias("DBU_Cost (USD)"))\
.orderBy(col('DBU_Cost (USD)').desc())

top20 = costByOrg\
.withColumn('row', lit('Nan'))\
.limit(20)

top20Workspaces = costByOrg.join(top20, top20['organization_id'] == costByOrg['organization_id'], 'left')\
.select(costByOrg['*'], 'row')

top20_p = top20Workspaces.withColumn('organization_id', expr("case when row is null then 'Others' else organization_id end"))\
.withColumn('workspace_name', expr("case when row is null then 'Others' else workspace_name end"))\
.groupby('organization_id', 'workspace_name')\
.agg(round(sum(col('DBU_Cost (USD)')), 2).alias('DBU_Cost (USD)'))\
.orderBy(col('DBU_Cost (USD)').desc())

# Converting pyspark to pandas for visualization
costByOrg_pandas = top20_p.toPandas()


# Plotting dataframe view using plotly library
fig = px.pie(costByOrg_pandas, 
             names = "workspace_name",
             values = "DBU_Cost (USD)",
             color_discrete_sequence = px.colors.sequential.Rainbow,
             title = "Cluster spend on each workspace",
             hole=.3)

# # Visualizing the graph
fig.show()

# COMMAND ----------

# MAGIC %md
# MAGIC **What is the dbu and compute cost of each workspace ?**

# COMMAND ----------

costByType = cluster_master\
.groupBy(["organization_id",
          "workspace_name"])\
.agg(round(sum(cluster_master["total_dbu_cost"]), 2).alias("DBU_Cost (USD)"), 
     round(sum(cluster_master["total_compute_cost"]), 2).alias("Compute_Cost (USD)"))\
.orderBy(col('DBU_Cost (USD)').desc())

top20 = costByType\
.withColumn('row', lit('Nan'))\
.limit(20)

top20Workspaces = costByType.join(top20, top20['organization_id'] == costByType['organization_id'], 'left')\
.select(costByType['*'], 'row')

top20_p = top20Workspaces.withColumn('organization_id', expr("case when row is null then 'Others' else organization_id end"))\
.withColumn('workspace_name', expr("case when row is null then 'Others' else workspace_name end"))\
.groupby('organization_id', 'workspace_name')\
.agg(round(sum(col('DBU_Cost (USD)')), 2).alias('DBU_Cost (USD)'),
     round(sum(col('Compute_Cost (USD)')), 2).alias('Compute_Cost (USD)'))

costMap = top20_p.withColumn("costMap",create_map(
        lit("DBU_Cost (USD)"),col("DBU_Cost (USD)"),
        lit("Compute_Cost (USD)"),col("Compute_Cost (USD)")
        )).drop("DBU_Cost (USD)","Compute_Cost (USD)")\
    .select(
    "organization_id",
    "workspace_name",
    F.explode("costMap").alias("Cost Type", "Cost (USD)"),
)\
.orderBy(col('DBU_Cost (USD)').desc())

# Converting pyspark to pandas for visualization
costMap_pandas = costMap.toPandas()

# # Plotting dataframe view using plotly library
fig = px.bar(costMap_pandas, 
             x = "workspace_name",
             y = "Cost (USD)",
             hover_data = ["organization_id",
                            "workspace_name"],
             color = "Cost Type", 
             color_discrete_sequence = px.colors.sequential.Blackbody,
             title = "DBU Cost vs Compute Cost")

# # Visualizing the graph
fig.show()

# COMMAND ----------

# MAGIC %md
# MAGIC **What is the cost of each workspace by cluster type?**

# COMMAND ----------

# Obtain the total cost of clusters by category on daily basis on each workspace
costByType = cluster_master\
.withColumn('cluster_type', 
            expr("case when isAutomated = 'false' and SqlEndpointId is null then 'interactive'" 
                 + "when isAutomated = 'true' then 'automated'" 
                 + "when SqlEndpointId is not null then 'SQL' else cluster_name end"))\
.groupBy(["state_start_date", 
          "organization_id",
          "workspace_name",
          "cluster_category",
          "cluster_id"])\
.agg(round(sum(cluster_master["total_dbu_cost"]/cluster_master["days_in_state"]), 2).alias("cost_by_date"))\
.groupBy(["state_start_date",
          "organization_id",
          "workspace_name", 
          "cluster_category"])\
.agg(round(sum(col("cost_by_date")), 2).alias("DBU_Cost"),
     countDistinct('cluster_id').alias('cluster_count'))\
.filter(col('cluster_category').isNotNull())

# Calculate the worksapce cost on every day
costByType_p = costByType.withColumn('costMap', create_map(col('cluster_category'), col('DBU_Cost')))\
.withColumn('countMap', create_map(col('cluster_category'), col('cluster_count')))\
.groupBy(["state_start_date", 
          "organization_id", 
          "workspace_name"])\
.agg(round(sum(col("DBU_Cost")), 2).alias("DBU_Cost (USD)"), 
     collect_list(col('DBU_Cost')).alias('cost_by_type'), 
     collect_list(col('costMap')).alias('cost'),
     collect_list(col('countMap')).alias('cluster_count'))\
.orderBy(col('DBU_Cost (USD)').desc())

# Limit the workspaces to top 20 costing more
windowDept = Window.partitionBy("state_start_date")\
.orderBy(col("DBU_Cost (USD)").desc())

costByDate_p = costByType_p\
.withColumn("row",row_number().over(windowDept))\
.filter(col("row") <= 20)

# Grouping all the other workspaces apart from top 20 to Others category
top20Workspaces = costByType_p\
.join(costByDate_p, ((costByType_p.state_start_date == costByDate_p.state_start_date) & (costByType_p.organization_id == costByDate_p.organization_id) & (costByType_p.workspace_name == costByDate_p.workspace_name)), 'left')\
.select(costByType_p['*'], 
        col('row'))

top20Workspaces_p = top20Workspaces\
.withColumn('organization_id', expr("case when row is null then 'Others' else organization_id end"))\
.withColumn('workspace_name', expr("case when row is null then 'Others' else workspace_name end"))\
.select(
    "state_start_date",
    "organization_id",
    "workspace_name",
    explode(top20Workspaces.cost).alias("mapClusterTypes"),
    "cluster_count"
)

# Calculate the clusters cost by category
top20 = top20Workspaces_p\
.withColumn('cluster_type', map_keys(col("mapClusterTypes"))[0])\
.withColumn('Cost (USD)', map_values(col('mapClusterTypes'))[0])\
.groupby('state_start_date', 
         'organization_id', 
         'workspace_name', 
         'cluster_type')\
.agg(round(sum(col('Cost (USD)')), 2).alias('DBU_Cost (USD)'))\
.orderBy(col('DBU_Cost (USD)').desc())


# Converting pyspark to pandas for visualization
costByType_pandas = top20.toPandas()

# Plotting dataframe view using plotly library
fig = px.box(costByType_pandas, 
             x = "workspace_name",
             y = "DBU_Cost (USD)", 
             color = 'cluster_type', hover_data=['state_start_date'],
             title = "Cluster spend by type on each workspace",
            points = "all")

# # Visualizing the graph
fig.show()

# COMMAND ----------

# MAGIC %md
# MAGIC **What is the count of clusters breakdown by type on each workspace ?**

# COMMAND ----------

clusterCount = top20Workspaces\
.withColumn('organization_id', expr("case when row is null then 'Others' else organization_id end"))\
.withColumn('workspace_name', expr("case when row is null then 'Others' else workspace_name end"))\
.select(
    "state_start_date",
    "organization_id",
    "workspace_name",
    explode(top20Workspaces.cluster_count).alias("mapClusterCount")
)

clusterCount_p = clusterCount\
.withColumn('cluster_type', map_keys(col("mapClusterCount"))[0])\
.withColumn('Cluster Count', map_values(col('mapClusterCount'))[0])\
.groupby('state_start_date', 
         'organization_id', 
         'workspace_name', 
         'cluster_type')\
.agg(round(sum(col('Cluster Count')), 2).alias('cluster_count'))\
.orderBy(col('cluster_count').desc())


# Converting pyspark to pandas for visualization
countByType_pandas = clusterCount_p.toPandas()

# Plotting dataframe view using plotly library
fig = px.box(countByType_pandas, 
             x = "workspace_name",
             y = "cluster_count", 
             color = 'cluster_type', hover_data=['state_start_date'],
             title = "Cluster count by type on each workspace",
            points = "all")

# # Visualizing the graph
fig.show()

# COMMAND ----------

scheduledJobs = job_master\
.filter(col('job_trigger_type') == 'cron')\
.groupBy(["job_start_date", 
          "organization_id",
          "workspace_name"])\
.agg(countDistinct(col('job_id')).alias('job_count'))\
.orderBy(col('job_count').desc())

windowDept = Window.partitionBy("job_start_date")\
.orderBy(col("job_count").desc())

costByDate_p = scheduledJobs\
.withColumn("row",row_number().over(windowDept))\
.filter(col("row") <= 20)

top20Workspaces = scheduledJobs\
.join(costByDate_p, ((scheduledJobs.job_start_date == costByDate_p.job_start_date) & (scheduledJobs.organization_id == costByDate_p.organization_id) & (scheduledJobs.workspace_name == costByDate_p.workspace_name)), 'left')\
.select(scheduledJobs['*'], 
        col('row'))

top20Workspaces_p = top20Workspaces\
.withColumn('organization_id', expr("case when row is null then 'Others' else organization_id end"))\
.withColumn('workspace_name', expr("case when row is null then 'Others' else workspace_name end"))\
.groupby('job_start_date', 
         'organization_id', 
         'workspace_name')\
.agg(round(sum(col('job_count')), 2).alias('Job Count'))\
.orderBy(col('Job Count').desc())

# Converting pyspark to pandas for visualization
scheduledJobs_pandas = top20Workspaces_p.toPandas()

# Plotting dataframe view using plotly library
fig = px.box(scheduledJobs_pandas, 
             x = "workspace_name",
             y = "Job Count",
             points = 'all',
             hover_data=['job_start_date'],
             color = "workspace_name", 
             title = "Count of scheduled jobs on each workspace")

# # Visualizing the graph
fig.show()

# COMMAND ----------

jobsComputeTime = job_master\
.filter(col('job_trigger_type') == 'cron')\
.groupBy(["job_start_date", 
          "organization_id",
          "workspace_name"])\
.agg(round(sum(job_master['runTimeH']), 2).alias('compute_time'))\
.orderBy(col('compute_time').desc())

windowDept = Window.partitionBy("job_start_date")\
.orderBy(col("compute_time").desc())

costByDate_p = jobsComputeTime\
.withColumn("row",row_number().over(windowDept))\
.filter(col("row") <= 20)

top20Workspaces = jobsComputeTime\
.join(costByDate_p, ((jobsComputeTime.job_start_date == costByDate_p.job_start_date) & (jobsComputeTime.organization_id == costByDate_p.organization_id) & (jobsComputeTime.workspace_name == costByDate_p.workspace_name)), 'left')\
.select(jobsComputeTime['*'], 
        col('row'))

jobComputeTime = top20Workspaces\
.withColumn('organization_id', expr("case when row is null then 'Others' else organization_id end"))\
.withColumn('workspace_name', expr("case when row is null then 'Others' else workspace_name end"))\
.groupby('job_start_date', 
         'organization_id', 
         'workspace_name')\
.agg(round(sum(col('compute_time')), 2).alias('Compute Time (hrs)'))\
.orderBy(col('Compute Time (hrs)').desc())

# Converting pyspark to pandas for visualization
jobsComputeTime_pandas = jobComputeTime.toPandas()

# Plotting dataframe view using plotly library
fig = px.box(jobsComputeTime_pandas, 
             x = "workspace_name",
             y = "Compute Time (hrs)",
             hover_data = ['job_start_date'],
             points='all',
             color = "workspace_name", 
             title = "Compute Time of scheduled jobs on each workspace")

# # Visualizing the graph
fig.show()

# COMMAND ----------

customTags = cluster_master.withColumn("job_id", (cluster_master["cluster_name"].substr(lit(1), instr(col("cluster_name"), 'run')-2)))\
.withColumn("clusterName", expr("case when cluster_name like '%-run-%' then job_id else cluster_name end"))\
.withColumn('JobId', json_tuple(col('custom_tags'), 'JobId'))\
.withColumn('RunName', json_tuple(col('custom_tags'), 'RunName'))\
.withColumn('KeepAlive', json_tuple(col('custom_tags'), 'KeepAlive'))\
.withColumn('end_date ', json_tuple(col('custom_tags'), 'end_date '))\
.withColumn('SqlEndpointId', json_tuple(col('custom_tags'), 'SqlEndpointId'))\
.withColumn('dbsql-channel', json_tuple(col('custom_tags'), 'dbsql-channel'))\
.withColumn('databricks-cloud', json_tuple(col('custom_tags'), 'databricks-cloud'))\
.withColumn('databricks-cloud-priority', json_tuple(col('custom_tags'), 'databricks-cloud-priority'))\
.withColumn('isTesting', json_tuple(col('custom_tags'), 'isTesting'))\
.withColumn('test_new_tag', json_tuple(col('custom_tags'), 'test_new_tag'))\
.withColumn('type', json_tuple(col('custom_tags'), 'type'))\
.withColumn('OwnerEmail', json_tuple(col('custom_tags'), 'OwnerEmail'))\
.withColumn('Owner', json_tuple(col('custom_tags'), 'Owner'))\
.withColumn('cluster_type', json_tuple(col('custom_tags'), 'cluster_type'))

costMap = customTags.withColumn("tagMap",create_map(
        lit("JobId"),col("JobId"),
        lit("RunName"),col("RunName"),
        lit("KeepAlive"),col("KeepAlive"), 
        lit("SqlEndpointId"),col("SqlEndpointId"), 
        lit("dbsql-channel"),col("dbsql-channel"), 
        lit("databricks-cloud"),col("databricks-cloud"), 
        lit("databricks-cloud-priority"),col("databricks-cloud-priority"), 
        lit("isTesting"),col("isTesting"), 
        lit("test_new_tag"),col("test_new_tag"), 
        lit("type"),col("type"), 
        lit("OwnerEmail"),col("OwnerEmail"), 
        lit("Owner"),col("Owner"), 
        lit("cluster_type"),col("cluster_type")
        ))\
    .select(
    "organization_id",
    "workspace_name",
    "clusterName",
    F.explode("tagMap").alias("Tag Type", "Tag Value")
)

tagCount = costMap.where(col('Tag Value').isNotNull()).groupby("organization_id", "workspace_name", "Tag Type")\
.agg(countDistinct(col('clusterName')).alias('Tag Count'))\
.orderBy(col('workspace_name').desc(), col('Tag Count'))

costByWorkspace = tagCount\
.withColumn('tagMap', create_map(col('Tag Type'), col('Tag Count')))\
.groupBy(["organization_id",		
          "workspace_name"])\
.agg(sum(col('Tag Count')).alias('workspace_tag_count'), collect_list(col('tagMap')).alias('tagCountByType'))\
.orderBy(col('workspace_tag_count').desc())

windowDept = Window\
.orderBy(col("workspace_tag_count").desc())

top20workspace = costByWorkspace\
.withColumn("row",row_number().over(windowDept))\
.filter(col("row") <= 20)

top20Workspaces = costByWorkspace\
.join(top20workspace, ((costByWorkspace.organization_id == top20workspace.organization_id) & (costByWorkspace.workspace_name == top20workspace.workspace_name)), 'left')\
.select(costByWorkspace['*'], 		
        col('row'))

jobComputeTime = top20Workspaces\
.withColumn('organization_id', expr("case when row is null then 'Others' else organization_id end"))\
.withColumn('workspace_name', expr("case when row is null then 'Others' else workspace_name end"))\
.select(		
    "organization_id",		
    "workspace_name",		
    explode(top20Workspaces.tagCountByType).alias("mapTagTypes")		
)		
# Calculate the clusters cost by category		
top20 = jobComputeTime\
.withColumn('tag_type', map_keys(col("mapTagTypes"))[0])\
.withColumn('tag_count', map_values(col('mapTagTypes'))[0])\
.groupby('organization_id', 		
         'workspace_name', 		
         'tag_type')\
.agg(sum(col('tag_count')).alias('Tag_Count'))\
.orderBy(col('Tag_Count').desc())

tagCount_pandas = top20.toPandas()
new_df = tagCount_pandas.pivot(index='tag_type', columns='workspace_name')['Tag_Count'].fillna(0)

fig = px.imshow(new_df, 
                labels=dict(x="Workspace Name", y="Tag Type", color="Tag Count"),
                x=new_df.columns, 
                y=new_df.index, 
                title='Workspace Tags count by workspace', 
                aspect='auto')
# fig.update_xaxes(side="top")
fig.show()

# COMMAND ----------

# MAGIC %md
# MAGIC # AZURE ONLY
# MAGIC Please skip the Azure code (24 & 25) if you are under AWS cloud and vice versa.

# COMMAND ----------

try:
  
  splitByCloud = spark.sql(f"select * from {etlDB}.pipeline_report")\
  .withColumn('Cloud', expr("case when inputConfig.auditLogConfig.azureAuditLogEventhubConfig is null then 'AWS' else 'Azure' end"))\
  .select('organization_id', 'workspace_name', 'Cloud').distinct()
  
  node_count = cluster_master\
  .join(splitByCloud, cluster_master.organization_id == splitByCloud.organization_id, "left").select(cluster_master['*'], splitByCloud.Cloud)\
  .withColumn("job_id", (cluster_master["cluster_name"].substr(lit(1), instr(col("cluster_name"), 'run')-2)))\
  .withColumn("clusterName", expr("case when cluster_name like '%-run-%' then job_id else cluster_name end"))\
  .withColumn('node_type', cluster_master['worker_node_type'])\
  .where((splitByCloud['Cloud'] == 'Azure') & (col('node_type').isNotNull()))\
  .groupBy(["organization_id",
            "workspace_name",
           "node_type"])\
  .agg(countDistinct(col('clusterName')).alias('nodeType_count'))\
  .orderBy(col('nodeType_count').desc())

  countByWorkspace = node_count\
  .withColumn('nodeMap', create_map(col('node_type'), col('nodeType_count')))\
  .groupBy(["organization_id",
            "workspace_name"])\
  .agg(sum(col('nodeType_count')).alias('workspace_node_count'), collect_list(col('nodeMap')).alias('nodeCountByType'))\
  .orderBy(col('workspace_node_count').desc())

  windowDept = Window\
  .orderBy(col("workspace_node_count").desc())

  top20workspace = countByWorkspace\
  .withColumn("row",row_number().over(windowDept))\
  .filter(col("row") <= 20)


  top20Workspaces = countByWorkspace\
  .join(top20workspace, ((countByWorkspace.organization_id == top20workspace.organization_id) & (countByWorkspace.workspace_name == top20workspace.workspace_name)), 'left')\
  .select(countByWorkspace['*'], 
          col('row'))

  jobComputeTime = top20Workspaces\
  .withColumn('organization_id', expr("case when row is null then 'Others' else organization_id end"))\
  .withColumn('workspace_name', expr("case when row is null then 'Others' else workspace_name end"))\
  .select(
      "organization_id",
      "workspace_name",
      explode(top20Workspaces.nodeCountByType).alias("mapNodeTypes")
  )

  # Calculate the clusters cost by category
  top20 = jobComputeTime\
  .withColumn('node_type', map_keys(col("mapNodeTypes"))[0])\
  .withColumn('node_count', map_values(col('mapNodeTypes'))[0])\
  .groupby('organization_id', 
           'workspace_name', 
           'node_type')\
  .agg(sum(col('node_count')).alias('Node Count'))\
  .orderBy(col('Node Count').desc())


  new_df_pandas = top20.toPandas()
  new_df = new_df_pandas.pivot(index='node_type', columns='workspace_name')['Node Count'].fillna(0)

  fig = px.imshow(new_df, 
                labels=dict(x="Workspace Name", y="Node Type", color="NodeType Count"),
                x=new_df.columns, 
                y=new_df.index, 
                aspect='auto',
                title='Node type count by azure workspace')
# fig.update_xaxes(side="top")
  fig.show()

except ValueError:
  print("Its an empty dataframe - There are no available Azure workspaces data.")
except Exception as e:
  print(f"An exception occurred due to no available Azure workspaces data : {e}")


# COMMAND ----------

try:

  splitByCloud = spark.sql(f"select * from {etlDB}.pipeline_report")\
    .withColumn('Cloud', expr("case when inputConfig.auditLogConfig.azureAuditLogEventhubConfig is null then 'AWS' else 'Azure' end"))\
    .select('organization_id', 'workspace_name', 'Cloud').distinct()

  node_cost = cluster_master\
  .join(splitByCloud, cluster_master.organization_id == splitByCloud.organization_id, "left").select(cluster_master['*'], splitByCloud.Cloud)\
  .withColumn("job_id", (cluster_master["cluster_name"].substr(lit(1), instr(col("cluster_name"), 'run')-2)))\
  .withColumn("clusterName", expr("case when cluster_name like '%-run-%' then job_id else cluster_name end"))\
  .withColumn('node_type', cluster_master['worker_node_type'])\
  .where((splitByCloud['Cloud'] == 'Azure') & (col('node_type').isNotNull()))\
  .groupBy(["organization_id",
            "workspace_name",
           "node_type"])\
  .agg(round(sum(cluster_master['total_dbu_cost']), 2).alias('DBU Cost(USD)'))\
  .orderBy(col('DBU Cost(USD)').desc())

  costByWorkspace = node_cost\
  .withColumn('nodeMap', create_map(col('node_type'), col('DBU Cost(USD)')))\
  .groupBy(["organization_id",		
            "workspace_name"])\
  .agg(sum(col('DBU Cost(USD)')).alias('workspace_node_cost'), collect_list(col('nodeMap')).alias('nodeCostByType'))\
  .orderBy(col('workspace_node_cost').desc())

  windowDept = Window\
  .orderBy(col("workspace_node_cost").desc())

  top20workspace = costByWorkspace\
  .withColumn("row",row_number().over(windowDept))\
  .filter(col("row") <= 20)

  top20Workspaces = costByWorkspace\
  .join(top20workspace, ((costByWorkspace.organization_id == top20workspace.organization_id) & (costByWorkspace.workspace_name == top20workspace.workspace_name)), 'left')\
  .select(costByWorkspace['*'], 		
          col('row'))

  jobComputeTime = top20Workspaces\
  .withColumn('organization_id', expr("case when row is null then 'Others' else organization_id end"))\
  .withColumn('workspace_name', expr("case when row is null then 'Others' else workspace_name end"))\
  .select(		
      "organization_id",		
      "workspace_name",		
      explode(top20Workspaces.nodeCostByType).alias("mapNodeTypes")		
  )		
  # Calculate the clusters cost by category		
  top20 = jobComputeTime\
  .withColumn('node_type', map_keys(col("mapNodeTypes"))[0])\
  .withColumn('node_cost', map_values(col('mapNodeTypes'))[0])\
  .groupby('organization_id', 		
           'workspace_name', 		
           'node_type')\
  .agg(sum(col('node_cost')).alias('Node Cost'))\
  .orderBy(col('Node Cost').desc())

  new_df_pandas = top20.toPandas()
  new_df = new_df_pandas.pivot(index='node_type', columns='workspace_name')['Node Cost'].fillna(0)

  fig = px.imshow(new_df, 
                  labels=dict(x="Workspace Name", y="Node Type", color="DBU Cost (USD)"),
                  x=new_df.columns, 
                  y=new_df.index, 
                  title='Node type cost by azure workspace', 
                  aspect='auto')
  # fig.update_xaxes(side="top")
  fig.show()

except ValueError:
  print("Its an empty dataframe - There are no available Azure workspaces data.")
except Exception as e:
  print(f"An exception occurred due to no available Azure workspaces data : {e}")

# COMMAND ----------

# MAGIC %md
# MAGIC # AWS ONLY

# COMMAND ----------

try:

  splitByCloud = spark.sql(f"select * from {etlDB}.pipeline_report")\
    .withColumn('Cloud', expr("case when inputConfig.auditLogConfig.azureAuditLogEventhubConfig is null then 'AWS' else 'Azure' end"))\
    .select('organization_id', 'workspace_name', 'Cloud').distinct()

  node_count = cluster_master\
  .join(splitByCloud, cluster_master.organization_id == splitByCloud.organization_id, "left").select(cluster_master['*'], splitByCloud.Cloud)\
  .withColumn("job_id", (cluster_master["cluster_name"].substr(lit(1), instr(col("cluster_name"), 'run')-2)))\
  .withColumn("clusterName", expr("case when cluster_name like '%-run-%' then job_id else cluster_name end"))\
  .withColumn('node_type', cluster_master['worker_node_type'])\
  .where((splitByCloud['Cloud'] == 'AWS') & (col('node_type').isNotNull()))\
  .groupBy(["organization_id",
            "workspace_name",
           "node_type"])\
  .agg(countDistinct(col('clusterName')).alias('nodeType_count'))\
  .orderBy(col('nodeType_count').desc())

  countByWorkspace = node_count\
  .withColumn('nodeMap', create_map(col('node_type'), col('nodeType_count')))\
  .groupBy(["organization_id",	
            "workspace_name"])\
  .agg(sum(col('nodeType_count')).alias('workspace_node_count'), collect_list(col('nodeMap')).alias('nodeCountByType'))\
  .orderBy(col('workspace_node_count').desc())	

  windowDept = Window\
  .orderBy(col("workspace_node_count").desc())

  top20workspace = countByWorkspace\
  .withColumn("row",row_number().over(windowDept))\
  .filter(col("row") <= 1)

  top20Workspaces = countByWorkspace\
  .join(top20workspace, ((countByWorkspace.organization_id == top20workspace.organization_id) & (countByWorkspace.workspace_name == top20workspace.workspace_name)), 'left')\
  .select(countByWorkspace['*'], 	
          col('row'))

  jobComputeTime = top20Workspaces\
  .withColumn('organization_id', expr("case when row is null then 'Others' else organization_id end"))\
  .withColumn('workspace_name', expr("case when row is null then 'Others' else workspace_name end"))\
  .select(	
      "organization_id",	
      "workspace_name",	
      explode(top20Workspaces.nodeCountByType).alias("mapNodeTypes")	
  )	
  # Calculate the clusters cost by category	
  top20 = jobComputeTime\
  .withColumn('node_type', map_keys(col("mapNodeTypes"))[0])\
  .withColumn('node_count', map_values(col('mapNodeTypes'))[0])\
  .groupby('organization_id', 	
           'workspace_name', 	
           'node_type')\
  .agg(sum(col('node_count')).alias('Node Count'))\
  .orderBy(col('Node Count').desc())

  new_df_pandas = top20.toPandas()
  new_df = new_df_pandas.pivot(index='node_type', columns='workspace_name')['Node Count'].fillna(0)
  fig = px.imshow(new_df, 	
                  labels=dict(x="Workspace Name", y="Node Type", color="NodeType Count"),	
                  x=new_df.columns, 	
                  y=new_df.index, 	
                  aspect='auto',	
                  title='Node type count by AWS workspace')	
  # fig.update_xaxes(side="top")	
  fig.show()
  
except ValueError:
  print("Its an empty dataframe - There are no available AWS workspaces data.")
except Exception as e:
  print(f"An exception occurred due to no available AWS workspaces data : {e}")


# COMMAND ----------

try:

  splitByCloud = spark.sql(f"select * from {etlDB}.pipeline_report")\
    .withColumn('Cloud', expr("case when inputConfig.auditLogConfig.azureAuditLogEventhubConfig is null then 'AWS' else 'Azure' end"))\
    .select('organization_id', 'workspace_name', 'Cloud').distinct()

  node_cost = cluster_master\
  .join(splitByCloud, cluster_master.organization_id == splitByCloud.organization_id, "left").select(cluster_master['*'], splitByCloud.Cloud)\
  .withColumn("job_id", (cluster_master["cluster_name"].substr(lit(1), instr(col("cluster_name"), 'run')-2)))\
  .withColumn("clusterName", expr("case when cluster_name like '%-run-%' then job_id else cluster_name end"))\
  .withColumn('node_type', cluster_master['worker_node_type'])\
  .where((splitByCloud['Cloud'] == 'AWS') & (col('node_type').isNotNull()))\
  .groupBy(["organization_id",
            "workspace_name",
           "node_type"])\
  .agg(round(sum(cluster_master['total_dbu_cost']), 2).alias('DBU Cost(USD)'))\
  .orderBy(col('DBU Cost(USD)').desc())

  costByWorkspace = node_cost\
  .withColumn('nodeMap', create_map(col('node_type'), col('DBU Cost(USD)')))\
  .groupBy(["organization_id",		
            "workspace_name"])\
  .agg(sum(col('DBU Cost(USD)')).alias('workspace_node_cost'), collect_list(col('nodeMap')).alias('nodeCostByType'))\
  .orderBy(col('workspace_node_cost').desc())

  windowDept = Window\
  .orderBy(col("workspace_node_cost").desc())

  top20workspace = costByWorkspace\
  .withColumn("row",row_number().over(windowDept))\
  .filter(col("row") <= 20)

  top20Workspaces = costByWorkspace\
  .join(top20workspace, ((costByWorkspace.organization_id == top20workspace.organization_id) & (costByWorkspace.workspace_name == top20workspace.workspace_name)), 'left')\
  .select(costByWorkspace['*'], 		
          col('row'))

  jobComputeTime = top20Workspaces\
  .withColumn('organization_id', expr("case when row is null then 'Others' else organization_id end"))\
  .withColumn('workspace_name', expr("case when row is null then 'Others' else workspace_name end"))\
  .select(		
      "organization_id",		
      "workspace_name",		
      explode(top20Workspaces.nodeCostByType).alias("mapNodeTypes")		
  )		
  # Calculate the clusters cost by category		
  top20 = jobComputeTime\
  .withColumn('node_type', map_keys(col("mapNodeTypes"))[0])\
  .withColumn('node_cost', map_values(col('mapNodeTypes'))[0])\
  .groupby('organization_id', 		
           'workspace_name', 		
           'node_type')\
  .agg(sum(col('node_cost')).alias('Node Cost'))\
  .orderBy(col('Node Cost').desc())

  new_df_pandas = top20.toPandas()
  new_df = new_df_pandas.pivot(index='node_type', columns='workspace_name')['Node Cost'].fillna(0)

  fig = px.imshow(new_df, 
                  labels=dict(x="Workspace Name", y="Node Type", color="DBU Cost (USD)"),
                  x=new_df.columns, 
                  y=new_df.index, 
                  title='Node type cost by AWS workspace', 
                  aspect='auto')
  # fig.update_xaxes(side="top")
  fig.show()
  
except ValueError:
  print("Its an empty dataframe - There are no available AWS workspaces data.")
except Exception as e:
  print(f"An exception occurred due to no available AWS workspaces data : {e}")