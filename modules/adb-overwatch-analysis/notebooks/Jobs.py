# Databricks notebook source
# MAGIC %md
# MAGIC # Read me
# MAGIC >
# MAGIC - **Replace the ETL DB and Consumer DB with your ETL database name and Consumer database name**
# MAGIC 
# MAGIC - **As default the data will be filter:**
# MAGIC   - For 30days period
# MAGIC   - All workspaces included
# MAGIC   - All clusters included
# MAGIC   - Weekdays and Weekends included
# MAGIC 
# MAGIC Widgets Used:
# MAGIC | # | Widgets | Value | Default
# MAGIC | ----------- | ----------- | ----------- | ----------- |
# MAGIC | 1 | ETL Database Name | Your ETL Database Name | None
# MAGIC | 2 | Consumer DB Name | Your Consumer Database Name | None
# MAGIC | 3 | Workspace Name | List of workspace (overwatch deployed) name | all
# MAGIC | 4 | Cluster | List of clusters in the above workspaces | all
# MAGIC | 5 | Job Tags | Custom tags of jobs | None
# MAGIC | 6 | Start Date | Start date for analysis | 30 days back from current
# MAGIC | 7 | End Date | End date for analysis | Current date
# MAGIC | 8 | Include weekends | To record all days, include weekends | Yes |
# MAGIC | 9 | Only weekends | To record only weekends | No |
# MAGIC >
# MAGIC - **Use the widgets to filter the data further**

# COMMAND ----------

# MAGIC %md
# MAGIC - **%run in *cmd 2* replace the path with your path (*""/Dashboards_Dev/In Progress/07x/Helpers""*) to Helpers notebook**
# MAGIC - **Go to view on topbar and click the *View* under *Dashboard* to view the dashboards named:Job_overview or Job_micro_view**

# COMMAND ----------

# MAGIC %run "/Dashboards_Dev/In Progress/07x_rc_customer/Helpers" $etlDB = etlDB $consumerDB = consumerDB

# COMMAND ----------

# Run only for the first time and comment it out after the first run
# dbutils.widgets.removeAll()

# COMMAND ----------

dbutils.widgets.text("etlDB", "overwatch_etl", "1.ETL DB")
dbutils.widgets.text("consumerDB", "overwatch", "2. Consumer DB")

# COMMAND ----------

etlDB = str(dbutils.widgets.get("etlDB"))
consumerDB = str(dbutils.widgets.get("consumerDB"))

# COMMAND ----------

fetch_workspace_name = spark.sql(f"select distinct workspace_name from {etlDB}.pipeline_report").rdd.flatMap(lambda x: x).collect()+["all"]

# COMMAND ----------

dbutils.widgets.multiselect("workspace_name","all",fetch_workspace_name, "3. Workspace Name")
dbutils.widgets.text("cluster_id", "all", "4. Cluster ID")
dbutils.widgets.text("tags", "", "5. Job Tags")
dbutils.widgets.text("start_date", f"{date.today() - timedelta(days=30)}", "6. Start Date")
dbutils.widgets.text("end_date", f"{date.today()}", "7. End Date")
dbutils.widgets.dropdown("include_weekends", "Yes", ["Yes", "No"], "8. Include weekends")
dbutils.widgets.dropdown("only_weekends", "No", ["Yes", "No"], "9. Only weekends")

workspace_name =  spark.sql(f"select distinct workspace_name from {etlDB}.pipeline_report").rdd.flatMap(lambda x: x).collect() if 'all' in dbutils.widgets.get("workspace_name").split(',') else dbutils.widgets.get("workspace_name").split(',')

# COMMAND ----------

job_tags = str(dbutils.widgets.get("tags"))
start_date = str(dbutils.widgets.get("start_date"))
end_date = str(dbutils.widgets.get("end_date"))
include_weekends = dbutils.widgets.get("include_weekends")
only_weekends = dbutils.widgets.get("only_weekends")
cluster_filter = spark.sql(f"select distinct cluster_id from {consumerDB}.jobrun").select("cluster_id").distinct() if 'all' in dbutils.widgets.get("cluster_id").split(',') else spark.createDataFrame(dbutils.widgets.get("cluster_id").replace(" ", "").split(','),"string").toDF("cluster_id")

# COMMAND ----------

# MAGIC %md
# MAGIC ### Load Data

# COMMAND ----------

# MAGIC %md
# MAGIC ### Master dataframe

# COMMAND ----------

masters = master(etlDB,consumerDB,workspace_name,start_date,end_date)

# COMMAND ----------

job = masters.job_master_filter(includeWeekend = include_weekends,
                                       onlyWeekend = only_weekends,
                                       dateColumn="job_start_date", 
                                       clusterTable = cluster_filter)\
             .distinct()
expensive_jobs = masters.expensive_jobs(data=job)
expensive_faliures = masters.expensive_failure(job)
expensive_jobs_int_clusters = masters.expensive_jobs_interactive_clusters(job)

# COMMAND ----------

# MAGIC %md
# MAGIC # Macro View Begin

# COMMAND ----------

# MAGIC %md
# MAGIC ## $DBUs by workflow by workspace by date
# MAGIC #### In the below dataframe and visulization:
# MAGIC ###### total_dbu_cost :-  is the DBU spend in USD for the day per workspace
# MAGIC ###### top_3_expensive_jobs :- Provides the list of three top expensive jobs of the day across workspaces and this is by $DBUs by date.
# MAGIC ###### top_3_expensive_job_fails -- Provides the list of three top expensive jobs of the day across workspaces and this is by $DBUs by date.

# COMMAND ----------

job_cost = job\
           .groupBy("job_start_date","workspace_name")\
           .agg(round(sum(col("total_dbu_cost")),2).alias("total_dbu_cost"))

job_cost_master = job_cost\
                  .join(expensive_jobs, ['job_start_date'])\
                  .join(expensive_faliures, ['job_start_date'])

dbu_cost = job_cost_master\
           .groupBy("job_start_date","workspace_name","top_3_expensive_jobs","top3_expensive_job_fails")\
           .agg(round(sum(col("total_dbu_cost")),2).alias("total_dbu_cost"))\
           .orderBy(col("job_start_date").asc())\
           .withColumn("top_1_expensive_job",col("top_3_expensive_jobs")[0])\
           .withColumn("top_2_expensive_job",col("top_3_expensive_jobs")[1])\
           .withColumn("top_3_expensive_job",col("top_3_expensive_jobs")[2])\
           .withColumn("top_1_expensive_fails",col("top3_expensive_job_fails")[0])\
           .withColumn("top_2_expensive_fails",col("top3_expensive_job_fails")[1])\
           .withColumn("top_3_expensive_fails",col("top3_expensive_job_fails")[2])\
           .withColumn('50%', F.expr('percentile(total_dbu_cost, 0.5)').over(Window.partitionBy('job_start_date')))\
           .withColumn('90%', F.expr('percentile(total_dbu_cost, 0.9)').over(Window.partitionBy('job_start_date')))\
           .withColumn('99%', F.expr('percentile(total_dbu_cost, 0.99)').over(Window.partitionBy('job_start_date')))\
           .withColumn('max', F.expr('percentile(total_dbu_cost, 1)').over(Window.partitionBy('job_start_date')))\
           .toPandas()
#compute
#filters job type
# jobs which are not runnu=ing for a period of time

try:
  display(job_cost_master)
  fig = px.bar(dbu_cost
              ,x=dbu_cost["job_start_date"]
              ,y=dbu_cost["total_dbu_cost"]
              ,hover_data=["top_1_expensive_job","top_2_expensive_job","top_3_expensive_job",
                           "top_1_expensive_fails","top_2_expensive_fails","top_3_expensive_fails",
                           "50%","90%","99%","max"]
              ,color = "workspace_name"
              ,color_discrete_sequence = px.colors.sequential.Electric
              ,title="$DBUs by workflow by workspace by date"
              ,labels={'job_start_date':'Job Start Date'
                      ,'total_dbu_cost':'Total DBU cost in USD(Daily/Workspace)'
                      ,'workspace_name':'Workspace Name'}
               )

  fig.update_layout(showlegend=True
                   ,xaxis_type='category')

  fig.show()
except ValueError:
  print("Its an empty dataframe - Kindly check the job_cost_master dataframe")
except Exception as e:
  print(f"An exception occurred : {e}")

# COMMAND ----------

# MAGIC %md
# MAGIC ## Job Count by workspace

# COMMAND ----------

job_count = job\
            .groupBy("workspace_name")\
            .agg(countDistinct("job_id").alias("job_count"),
                round(sum((col("total_dbu_cost"))),2).alias("total_dbu_cost_USD"))\
            .toPandas()

minimum_job_count = int(job_count["job_count"].sum()*0.2) 
#The value collects 20% of total number jobs, any Workspace with job count less than this value will go to other category
job_count.loc[job_count['job_count'] < minimum_job_count,'workspace_name'] = 'Other Workspaces'
try:
  fig = px.pie(job_count, values='job_count', names='workspace_name',
               hover_data=['total_dbu_cost_USD'] ,
               color_discrete_sequence = px.colors.sequential.Bluered,
               title='Job Count by workspace')
  fig.update_traces(textinfo='percent+label', textfont_size=12,pull=[0.05,0.05,0.05,0.05,0.05])
  fig.show()

except ValueError:
  print("Its an empty dataframe - Kindly check the dataframe")
except Exception as e:
  print(f"An exception occurred : {e}")

# COMMAND ----------

# MAGIC %md
# MAGIC ## Number of jobs running on interactive clusters

# COMMAND ----------

job_int_cost = job\
              .filter(col("cluster_type") != "job_cluster")\
              .groupBy("job_start_date","job_id","workspace_name","organization_id","created_by")\
              .agg(round(sum(col("total_dbu_cost")),2).alias("total_dbu_cost"))

job_int_cost_master = job_int_cost\
                      .join(expensive_jobs_int_clusters, ['job_start_date'])

jobrun_interactive_cluster = job_int_cost_master\
                             .groupby("organization_id","workspace_name","created_by","top3expensive_int_jobs")\
                             .agg(countDistinct("job_id").alias("job_on_interactive_count")
                                 ,round(sum(col("total_dbu_cost")),2).alias("total_dbu_cost"))\
                             .sort(col("job_on_interactive_count").desc())\
                             .withColumn("top_1_expensive_jobs",col("top3expensive_int_jobs")[0])\
                             .withColumn("top_2_expensive_jobs",col("top3expensive_int_jobs")[1])\
                             .withColumn("top_3_expensive_jobs",col("top3expensive_int_jobs")[2])\
                             .fillna(value="Unknown", subset=["created_by"])\
                             .limit(20)\
                             .toPandas()
try:
  display(jobrun_interactive_cluster)
  fig = px.box(jobrun_interactive_cluster, x="workspace_name", y="job_on_interactive_count"
              ,points="all",height = 650,width=1200
              ,hover_data=['organization_id','created_by','total_dbu_cost',"top_1_expensive_jobs","top_2_expensive_jobs","top_3_expensive_jobs"]
              ,title="Jobs running in Interactive Clusters (Top 20 workspaces)"
              ,labels={"workspace_name" : "Workspace name",
                        "job_on_interactive_count": "Jobs running on interactive Clusters(Count)"}
              ,color_discrete_sequence = px.colors.sequential.gray)

  fig.update_traces(quartilemethod="linear") 
  fig.update_layout(hovermode="x"
                   ,showlegend=True
                   ,xaxis_type='category'
                   ,yaxis=dict(type='linear'))
  fig.show()
except ValueError:
  print("Its an empty dataframe - Kindly check the dataframe")
except Exception as e:
  print(f"An exception occurred : {e}")

# COMMAND ----------

# MAGIC %md
# MAGIC ### Jobs per day per status

# COMMAND ----------

job_per_status = job\
                 .select("terminal_state","job_start_date","run_id","job_id")\
                 .where(col("terminal_state")!="null")\
                 .groupby("terminal_state","job_start_date")\
                 .agg(countDistinct("run_id").alias("number_of_runs"),
                     countDistinct("job_id").alias("number_of_jobs"))\
                 .orderBy(col("job_start_date"))\
                 .toPandas()

jb_fail = job_per_status[job_per_status.terminal_state=="Failed"]

jb_success = job_per_status[job_per_status.terminal_state=="Succeeded"]

jb_cancel = job_per_status[job_per_status.terminal_state=="Cancelled"]

jb_error = job_per_status[job_per_status.terminal_state=="Error"]
try:
  fig = go.Figure()

  fig.add_trace(go.Scatter(
      x=jb_success.job_start_date, y=jb_success.number_of_runs,
      mode='lines',
      line=dict(width=0.5, color='rgb(197, 83, 0)'),
      stackgroup='one',
      name='Succeeded',
      groupnorm='percent' # sets the normalization for the sum of the stackgroup
  ))

  fig.add_trace(go.Scatter(
      x=jb_fail.job_start_date, y=jb_fail.number_of_runs,
      mode='lines',
      line=dict(width=0.5, color='rgb(0, 0, 255)'),
      name='Failed',
      stackgroup='one'
  ))

  fig.add_trace(go.Scatter(
      x=jb_cancel.job_start_date, y=jb_cancel.number_of_runs,
      mode='lines',
      line=dict(width=0.5, color='rgb(128,0,0)'),
      name='Cancelled',
      stackgroup='one'
  ))

  fig.add_trace(go.Scatter(
      x=jb_error.job_start_date, y=jb_error.number_of_runs,
      mode='lines',
      line=dict(width=0.5, color='rgb(165,42,42)'),
      name='Error',
      stackgroup='one'
  ))

  fig.update_traces(mode="markers+lines")
  fig.update_layout(title="Daily Job status distribution",
                    xaxis_title="Job start Date",
                    yaxis_title="Job run count",
                    legend_title="Terminal States",
                    hovermode="x unified",
                    showlegend=True,
                    xaxis_type='category',
                    yaxis=dict(type='linear'
                               ,range=[1, 100]))
  fig.show()
except ValueError:
  print("Its an empty dataframe - Kindly check the dataframe")
except Exception as e:
  print(f"An exception occurred : {e}")

# COMMAND ----------

# MAGIC %md
# MAGIC # Number of job Runs (Succeeded vs Failed)

# COMMAND ----------

job_success_vs_failed =  job\
                         .select("terminal_state","workspace_name","run_id")\
                         .where(col("terminal_state").isin(["Succeeded","Failed","Cancelled"]))\
                         .groupby("workspace_name","terminal_state")\
                         .agg(countDistinct("run_id").alias("number_of_runs"))\
                         .toPandas()
try:
  fig = px.bar(job_success_vs_failed,
               x=job_success_vs_failed["workspace_name"],
               y=job_success_vs_failed["number_of_runs"],
               color = "terminal_state",
               color_discrete_sequence = px.colors.sequential.Blackbody,
               title="Number of job Runs (Succeeded vs Failed)",
               labels={'number_of_runs':'Job run Count'
                      ,'workspace_name':'Workspace name'},
               height=500
               )
  fig.update_xaxes(type='category')
  fig.show()
except ValueError:
  print("Its an empty dataframe - Kindly check the dataframe")
except Exception as e:
  print(f"An exception occurred : {e}")

# COMMAND ----------

# MAGIC %md
# MAGIC ## Cost of failure By Workspace

# COMMAND ----------

job_cost_faliure =  job\
                    .select("terminal_state","workspace_name","run_id","runTimeH")\
                    .where(col("terminal_state") != "Succeeded")\
                    .groupby("workspace_name")\
                    .agg(countDistinct("run_id").alias("number_of_runs")
                        ,round(sum("runTimeH"),2).alias("Compute_timeH"))\
                    .orderBy(col("number_of_runs").desc())\
                    .toPandas()
try:
  fig = px.bar(job_cost_faliure, x='workspace_name', y='Compute_timeH',
               hover_data=['number_of_runs'], color='Compute_timeH',
               color_continuous_scale = ["yellow","green","blue","red"],
               title = "Impact of Failure By Workspace",
               labels={'Compute_timeH':'Failed Compute time in Hours'
                      ,'workspace_name':'Workspace name'}, height=400)
  fig.show()
except ValueError:
  print("Its an empty dataframe - Kindly check the dataframe")
except Exception as e:
  print(f"An exception occurred : {e}")