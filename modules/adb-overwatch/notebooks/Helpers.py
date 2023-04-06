# Databricks notebook source
from pyspark.sql.functions import *
from pyspark.sql.window import Window, WindowSpec
import plotly.express as px
from operator import add
from functools import reduce
import pyspark.sql.functions as F
from pyspark.sql.functions import collect_list, collect_set, when
from pyspark.sql.window import Window
from pyspark.sql.functions import rank, col
import plotly.graph_objects as go
import pyspark.sql.functions as func
from pyspark.sql.functions import UserDefinedFunction
from pyspark.sql.types import StringType
from datetime import date, timedelta
import pandas as pd
import pyspark
from pyspark.sql.functions import concat_ws

# COMMAND ----------

class helpers:
  
  
  def __init__(self, _etl_db, _consumer_db):
    self.etl_db = _etl_db
    self.consumer_db = _consumer_db
#     try:
#       if _etl_db == "" or _etl_db is null:
#         print("add the database widget")
#     except:
#       print("add the database widget")
    self.org_ids_lookup = table(f"{_etl_db}.pipeline_report")\
      .select(col("organization_id"), col("workspace_name"))\
      .distinct()\
      .cache()
    self.org_ids_lookup.count()
#     self.masters = new master(...)
#   masters.clusterstatefact(...)
    
  def filter_workspaces(self, workspace_names) -> pyspark.sql.dataframe.DataFrame:
    """
    Returns a dataframe filter by selected workspace name.

            Parameters:
                    workspace_names (str): Workspace Name
                    
            Returns:
                    DataFrame: Filtered by selected workspace(From widgets)
                    
            Example:
                    outputDF = inputDF.transform(object_name.filter_workspaces("workspace_names"))
    """
    def inner(df):
      org_ids = self.org_ids_lookup\
        .filter(col("workspace_name").isin(workspace_names))\
        .select(col("organization_id"))\
        .rdd.flatMap(lambda x: x).collect()
      return df.filter(col("organization_id").isin(org_ids))
    return inner
  
  def filter_dates(self,dateColumn:str,start_date,end_date) -> pyspark.sql.dataframe.DataFrame:
    """
    Returns a dataframe filter by dates(between selected start and end date).

            Parameters:
                    dateColumn (str): Date column name
                    start_date (date): Start date
                    end_date (date): End date
                    
            Returns:
                    DataFrame: Data between selected dates
                    
            Example:
                    outputDF = inputDF.transform(object_name.filter_dates(date_column_name,start_date,end_date))
    """
    def inner(df):
      return df.filter(F.col(dateColumn).between(pd.to_datetime(start_date),pd.to_datetime(end_date))) 
    return inner
  
  def filter_by_weekdays(self,include_weekends,only_weekends) -> pyspark.sql.dataframe.DataFrame:
    """
    Returns a dataframe filter by weekends and weekdays.

            Parameters:
                    include_weekends (str): yes/no
                    only_weekends (str):  yes/no
                    
            Returns:
                    DataFrame: filter by weekends and weekdays.
                    
            Example:
                    outputDF = inputDF.transform(object_name.filter_dates(yes,no))
    """
    
    def inner(df):
      if include_weekends == 'Yes'and only_weekends == 'No':
        return df
      elif include_weekends == 'Yes' and only_weekends == 'Yes':
        return df.filter(col('is_weekend') == 1)
      elif include_weekends == 'No' and only_weekends == 'No':
        return df.filter(col('is_weekend') == 0)
      else:
        raise Exception("Sorry, Please check the widget values (If Include weekends is 'NO' you cant keep Only weekends as 'Yes')")
    return inner
  
  def filter_clusters(self,clusterTable) -> pyspark.sql.dataframe.DataFrame:
    """
      Returns a dataframe filter with selected cluster_ids.

              Parameters:
                      clusterTable (DataFrame): Contains only selected clusters

              Returns:
                      DataFrame: Data selected clusters

              Example:
                      outputDF = inputDF.transform(object_name.filter_clusters(clusterTableName))
      """
    def inner(df):
      data = clusterTable.join(df,on="cluster_id",how="inner")\
                  .select(df["*"])
      return data
    return inner
  
  # split_path
  def partition_split(self,folder_level, consumerDB):
    def inner(df):
      if int(folder_level) < 1:
        raise Exception("Please enter the folder depth level")
      num = int(folder_level) + 1  
      nb_df = df.withColumn("folder_path", concat_ws('/', slice(split(col('notebook_path'), '/'), 1, num)))
      return nb_df
    return inner

# COMMAND ----------

class master(helpers):
  
  def __init__(self,_etl_db,_consumer_db,_workspace_name,_from_date,_until_date):
    
    self.etl_db = _etl_db
    self.consumer_db = _consumer_db
    self.start_date = _from_date
    self.end_date = _until_date
    self.workspace_name = _workspace_name
    helpers.__init__(self, self.etl_db, self.consumer_db)
    
    
  def spark_notebook_master(self, **kwargs):
    self.include_weekend = kwargs.get("includeWeekend",True)
    self.only_weekend = kwargs.get("onlyWeekend",False)
    self.path_depth = kwargs.get("folder_level")
    
    sparkJob = spark.sql(f"select * from {self.consumer_db}.sparkJob").withColumn("is_weekend",dayofweek("date").isin([1,7]).cast("int"))
    sparkTask = spark.sql(f"select * from {self.consumer_db}.sparkTask").withColumn("is_weekend",dayofweek("date").isin([1,7]).cast("int"))
#     sparkTask = spark.sql(f"select * from {self.etl_db}.sparkTask_gold").withColumn("is_weekend",dayofweek("date").isin([1,7]).cast("int"))

    notebook = spark.sql("select * from {}.notebook".format(self.consumer_db))
    
    SparkTask_master = sparkTask.join(sparkJob, 
                                      (sparkTask["cluster_id"] == sparkJob["cluster_id"]) &
                                      (sparkTask["workspace_name"] == sparkJob["workspace_name"]) &
                                      (sparkTask["timestamp"] == sparkJob["timestamp"]) &
                                      (sparkTask["organization_id"] == sparkJob["organization_id"])
                                      ,"inner")\
    .withColumn('MemoryBytesSpilled', sparkTask.task_metrics['MemoryBytesSpilled'])\
    .withColumn('DiskBytesSpilled', sparkTask.task_metrics['DiskBytesSpilled'])\
    .withColumn("Execution_type", expr("case when db_job_id is null and db_id_in_job is null then 'Manual_notebook' else 'Job_notebook' end"))\
    .select(sparkTask["*"]
           ,sparkJob["db_job_id"]
           ,sparkJob["db_id_in_job"]
           ,sparkJob["notebook_id"]
           ,sparkJob["notebook_path"]
           ,sparkJob["execution_id"]
           ,sparkJob["job_runtime"]
           ,sparkJob["job_result"]
           ,sparkJob["user_email"]
           ,explode(sparkJob["stage_ids"]).alias("stage_id")
           ,"MemoryBytesSpilled"
           ,"DiskBytesSpilled"
           ,"Execution_type"
           )

#     sparkMaster = SparkTask_master.join(notebook, SparkTask_master["notebook_path"] == notebook["notebook_path"], "inner")\
#     .withColumn("Execution_type", expr("case when db_job_id is null and db_id_in_job is null then 'Manual_notebook' else 'Job_notebook' end"))\
#                   .select(sparkTask["*"]
#                    ,sparkJob["db_job_id"]
#                    ,sparkJob["db_id_in_job"]
#                    ,sparkJob["execution_id"]
#                    ,sparkJob["job_runtime"]
#                    ,notebook["notebook_id"]
#                    ,notebook["notebook_path"]
#                    ,"Execution_type" 
#                    ,"MemoryBytesSpilled"
#                    ,"DiskBytesSpilled"
#            )
    df = SparkTask_master\
      .transform(helpers.filter_dates(self,"date", self.start_date, self.end_date))\
      .transform(helpers.filter_workspaces(self, self.workspace_name))\
      .transform(helpers.filter_by_weekdays(self, self.include_weekend, self.only_weekend))\
      .transform(helpers.partition_split(self, self.path_depth, self.consumer_db))
    return df
    
  def job_master_filter(self,**kwargs):
    self.cluster_id = kwargs.get("clusterID","all")
    self.tags = kwargs.get("tags","all")
    self.include_weekend = kwargs.get("includeWeekend",True)
    self.only_weekend = kwargs.get("onlyWeekend",False)
    self.date_col = kwargs.get("dateColumn",False)
    self.cluster_table = kwargs.get("clusterTable",False)
         
    
    jrcp = spark\
           .sql(f"select *,DATE(task_runtime.startTS) as job_start_date from {self.consumer_db}.jobruncostpotentialfact")\
           .withColumn("is_weekend",dayofweek(self.date_col).isin([1,7]).cast("int"))

    job = spark\
          .sql(f"select * from {self.consumer_db}.job")\
          .select("job_id","tasks.notebook_task.notebook_path","created_by")
    
    jobrun = spark\
            .sql(f"select * from {self.consumer_db}.jobRun")


    jrcp_master = jrcp\
                  .join(jobrun, jrcp["run_id"] == jobrun["run_id"], "inner")\
                  .join(job, jrcp["job_id"] == job["job_id"], "inner")\
                  .select(jrcp["*"],
                          job["notebook_path"],
                          jobrun["cluster_type"]
                         )\
                  .transform(helpers.filter_dates(self,self.date_col,self.start_date,self.end_date))\
                  .transform(helpers.filter_workspaces(self,self.workspace_name))\
                  .transform(helpers.filter_by_weekdays(self,self.include_weekend,self.only_weekend))\
                  .transform(helpers.filter_clusters(self,self.cluster_table))\
                  .select("organization_id", "workspace_name","job_start_date","job_id","run_id","job_name"
                           ,"task_runtime.startTS","task_runtime.endTS","task_runtime.runTimeH","cluster_id","cluster_name","cluster_type"
                           ,"terminal_state","worker_potential_core_H","total_compute_cost","task_type"
                           ,"total_dbu_cost","total_cost","is_weekend","notebook_path","created_by","last_edited_by","job_run_cluster_util")
    return jrcp_master
  
  def expensive_jobs(self, **kwargs):
    self.dataframe = kwargs.get("data",True)
    expensive_jobs = self.dataframe\
                     .groupby("job_name","job_start_date","workspace_name")\
                     .agg(round(sum(col("total_dbu_cost")),2).alias("cost_in_USD"))\
                     .orderBy(col("cost_in_USD").desc())
    
    windowDate = Window.partitionBy("job_start_date").orderBy(col("cost_in_USD").desc())   
    
    top3_expensive_jobs = expensive_jobs.withColumn("row",row_number().over(windowDate))
  
    top3expensive_jobs = top3_expensive_jobs.where(top3_expensive_jobs.row <=3)\
                         .sort(["job_start_date","cost_in_USD"], ascending=False)\
                         .sort(["row"], ascending=False)
    
    top3expensive_jobs_daily = top3expensive_jobs\
                               .select(concat_ws('  :  ',top3expensive_jobs.workspace_name,top3expensive_jobs.job_name,top3expensive_jobs.cost_in_USD)\
                               .alias("Expensive_Jobs"),"job_start_date")\
                               .sort(["job_start_date"], ascending=False)\
                               .groupby("job_start_date")\
                               .agg(F.collect_list("Expensive_Jobs").alias("top_3_expensive_jobs"))
                               
    return top3expensive_jobs_daily
  
  def expensive_jobs_interactive_clusters(self,dataframe):
    data = self.dataframe
    expensive_int_jobs = self.dataframe\
                     .filter(col("cluster_type") != "job_cluster")\
                     .groupby("job_name","job_start_date","workspace_name")\
                     .agg(round(sum(col("total_dbu_cost")),2).alias("cost_in_USD"))\
                     .orderBy(col("cost_in_USD").desc())
    
    windowDate = Window.partitionBy("job_start_date").orderBy(col("cost_in_USD").desc())   
    
    top3_expensive_int_jobs = expensive_int_jobs.withColumn("row",row_number().over(windowDate))
  
    top3expensive_int_jobs = top3_expensive_int_jobs.where(top3_expensive_int_jobs.row <=3)\
                             .sort(["job_start_date","cost_in_USD"], ascending=False)\
                             .sort(["row"], ascending=False)
    
    top3expensive_jobs_int_daily = top3expensive_int_jobs\
                               .select(concat_ws('  : ',
                                                 top3expensive_int_jobs.workspace_name,
                                                 top3expensive_int_jobs.job_name,
                                                 top3expensive_int_jobs.cost_in_USD)\
                               .alias("Expensive_Jobs"),"job_start_date")\
                               .sort(["job_start_date"], ascending=False)\
                               .groupby("job_start_date")\
                               .agg(F.collect_list("Expensive_Jobs").alias("top3expensive_int_jobs"))
                               
    return top3expensive_jobs_int_daily
  
  def expensive_failure(self,dataframe):
    data = self.dataframe
    expensive_job_faliures = data\
                             .where(col("terminal_state") == "Failed")\
                             .groupby("job_name","job_start_date","workspace_name")\
                             .agg(round(sum(col("total_dbu_cost")),2).alias("cost_in_USD"))\
                             .orderBy(col("cost_in_USD").desc())
    windowDate = Window.partitionBy("job_start_date").orderBy(col("cost_in_USD").desc())
    
    top3_expensive_fails= expensive_job_faliures.withColumn("row",row_number().over(windowDate))
     
    top3_expensive_job_fails = top3_expensive_fails.where(top3_expensive_fails.row <=3)
    
    top3_expensive_job_faliures_daily = top3_expensive_job_fails\
                               .select(concat_ws('  :  ',
                                                 top3_expensive_job_fails.workspace_name,
                                                 top3_expensive_job_fails.job_name,
                                                 top3_expensive_job_fails.cost_in_USD)\
                               .alias("Expensive_Jobs"),"job_start_date")\
                               .sort(["job_start_date"], ascending=False)\
                               .groupby("job_start_date")\
                               .agg(F.collect_list("Expensive_Jobs").alias("top3_expensive_job_fails"))
    return top3_expensive_job_faliures_daily
  
  

  def cluster_master_filter(self,**kwargs):
    self.include_weekend = kwargs.get("includeWeekend",True)
    self.only_weekend = kwargs.get("onlyWeekend",False)
    
    clusterstatefact = spark.sql(f"select * from {self.consumer_db}.clusterstatefact")


    cluster = spark.sql(f"select * from {self.consumer_db}.cluster")
    
    clsf_master = clusterstatefact.join(cluster, clusterstatefact["cluster_id"] == cluster["cluster_id"], "inner")\
        .withColumn("cluster_category",
                  expr("""case when is_automated = 'true' and cluster_type not in ('Serverless','SQL Analytics','Single Node') then 'Automated'
                  when clusterstatefact.cluster_name like "dlt%" or cluster_type = 'Standard' then 'Standard' 
                  when is_automated = 'false' and cluster_type not in ('Serverless','SQL Analytics','Single Node') then 'Interactive'
                  when (is_automated = 'false' or is_automated = 'true' or is_automated is null) and cluster_type = 'SQL Analytics' then 'Warehouse' 
                  when (is_automated = 'false' or is_automated = 'true' or is_automated is null) and cluster_type = 'Serverless' then 'High-Concurrency'
                  when (is_automated = 'false' or is_automated = 'true' or is_automated is null) and cluster_type = 'Single Node' then 'Single Node'
                  else "Unidentified"
                  end"""))\
        .select(clusterstatefact["*"]
                ,cluster["created_by"]
                ,cluster["last_edited_by"]
                ,cluster["deleted_by"]
                ,cluster["driver_node_type"]
                ,cluster["node_type"].alias("worker_node_type")
                ,cluster["autoscale"]
                ,cluster["is_automated"]
                ,cluster["cluster_type"]
                ,cluster["auto_termination_minutes"]
                ,cluster["instance_pool_id"]
                ,cluster["instance_pool_name"]
                ,"cluster_category"
               )\
    .withColumn("is_weekend",dayofweek("state_start_date").isin([1,7]).cast("int"))\
    .withColumn('SqlEndpointId', json_tuple(col("custom_tags"), "SqlEndpointId"))\
    .transform(helpers.filter_dates(self,"state_start_date",self.start_date,self.end_date))\
    .transform(helpers.filter_workspaces(self,self.workspace_name))\
    .transform(helpers.filter_by_weekdays(self,self.include_weekend,self.only_weekend))

    return clsf_master
  
  def job_test_filter(self,**kwargs):
    self.cluster_id = kwargs.get("clusterID","all")
    self.tags = kwargs.get("tags","all")
    self.include_weekend = kwargs.get("includeWeekend",True)
    self.only_weekend = kwargs.get("onlyWeekend",False)
    self.date_col = kwargs.get("dateColumn",False)
    self.cluster_table = kwargs.get("clusterTable",False)
         
    
    jrcp = spark\
           .sql(f"select *,DATE(task_runtime.startTS) as job_start_date from {self.consumer_db}.jobruncostpotentialfact")\
           .withColumn("is_weekend",dayofweek(self.date_col).isin([1,7]).cast("int"))

    job = spark\
          .sql(f"select * from {self.consumer_db}.job")\
          .select("job_id","tasks.notebook_task.notebook_path","created_by")
    
    jobrun = spark\
            .sql(f"select * from {self.consumer_db}.jobRun")


    jrcp_master = jrcp\
                  .join(jobrun, jrcp["run_id"] == jobrun["run_id"], "inner")\
                  .join(job, jrcp["job_id"] == job["job_id"], "inner")\
                  .select(jrcp["*"],
                          job["notebook_path"],
                          jobrun["cluster_type"]
                         )\
                  .transform(helpers.filter_dates(self,self.date_col,self.start_date,self.end_date))\
                  .transform(helpers.filter_workspaces(self,self.workspace_name))\
                  .transform(helpers.filter_by_weekdays(self,self.include_weekend,self.only_weekend))\
                  .select("organization_id", "workspace_name","job_start_date","job_id","run_id","job_name"
                           ,"task_runtime.startTS","task_runtime.endTS","task_runtime.runTimeH","cluster_id","cluster_name","cluster_type"
                           ,"terminal_state","worker_potential_core_H","total_compute_cost"
                           ,"total_dbu_cost","total_cost","is_weekend","notebook_path","created_by","last_edited_by","job_run_cluster_util", "job_trigger_type")
#                   .transform(helpers.filter_clusters(self,self.cluster_table))\
#                   .select("organization_id", "workspace_name","job_start_date","job_id","run_id","job_name"
#                            ,"task_runtime.startTS","task_runtime.endTS","task_runtime.runTimeH","cluster_id","cluster_name","cluster_type"
#                            ,"terminal_state","worker_potential_core_H","total_compute_cost"
#                            ,"total_dbu_cost","total_cost","is_weekend","notebook_path","created_by","last_edited_by","job_run_cluster_util")
    return jrcp_master

# COMMAND ----------

# def job_master_filter(self,**kwargs):
#     self.cluster_id = kwargs.get("clusterID","all")
#     self.tags = kwargs.get("tags","all")
#     self.include_weekend = kwargs.get("includeWeekend",True)
#     self.only_weekend = kwargs.get("onlyWeekend",False)
#     self.date_col = kwargs.get("dateColumn",False)
#     self.cluster_table = kwargs.get("clusterTable",False)
         
    
#     jrcp = spark\
#            .sql(f"select *,DATE(task_runtime.startTS) as job_start_date from {self.consumer_db}.jobruncostpotentialfact")\
#            .withColumn("is_weekend",dayofweek(self.date_col).isin([1,7]).cast("int"))

#     job = spark\
#           .sql(f"select * from {self.consumer_db}.job")\
#           .select("job_id","tasks.notebook_task.notebook_path","created_by")
    
#     jobrun = spark\
#             .sql(f"select * from {self.consumer_db}.jobRun")


#     jrcp_master = jrcp\
#                   .join(jobrun, jrcp["run_id"] == jobrun["run_id"], "inner")\
#                   .join(job, jrcp["job_id"] == job["job_id"], "inner")\
#                   .select(jrcp["*"],
#                           job["notebook_path"],
#                           jobrun["cluster_type"]
#                          )\
#                   .transform(helpers.filter_dates(self,self.date_col,self.start_date,self.end_date))\
#                   .transform(helpers.filter_workspaces(self,self.workspace_name))\
#                   .transform(helpers.filter_by_weekdays(self,self.include_weekend,self.only_weekend))\
#                   .transform(helpers.filter_clusters(self,self.cluster_table))\
#                   .select("organization_id", "workspace_name","job_start_date","job_id","run_id","job_name"
#                            ,"task_runtime.startTS","task_runtime.endTS","task_runtime.runTimeH","cluster_id","cluster_name","cluster_type"
#                            ,"terminal_state","worker_potential_core_H","total_compute_cost"
#                            ,"total_dbu_cost","total_cost","is_weekend","notebook_path","created_by","last_edited_by","job_run_cluster_util")
#     return jrcp_master
  
#   def expensive_jobs(self):
#     jrcp_master = self.job_master_filter
#     expensive_jobs = jrcp_master\
#                      .groupby("job_name","job_start_date")\
#                      .agg(round(sum(col("total_dbu_cost")),2).alias("cost_in_USD"))\
#                      .orderBy(col("cost_in_USD").desc()).distinct()
    
#     windowDate = Window.partitionBy("job_start_date").orderBy(col("cost_in_USD").desc())   
    
#     top3_expensive_jobs = expensive_jobs.withColumn("row",row_number().over(windowDate))
  
#     top3expensive_jobs = top3_expensive_jobs.where(top3_expensive_jobs.row <=3)\
#                          .sort(["job_start_date","cost_in_USD"], ascending=False)\
#                          .sort(["row"], ascending=False)\
#                          .withColumnRenamed("job_start_date","start_date")
    
#     top3expensive_jobs_daily = top3expensive_jobs\
#                                .select(concat_ws('  :  ',top3expensive_jobs.job_name,top3expensive_jobs.cost_in_USD)\
#                                .alias("Expensive_Jobs"),"start_date","cost_in_USD")\
#                                .sort(["start_date","cost_in_USD"], ascending=False)\
#                                .groupby("start_date")\
#                                .agg(F.collect_list("Expensive_Jobs").alias("top_3_expensive_jobs"))\
                               
#     return top3expensive_jobs_daily
  
#   def expensive_failure(self):
#     jrcp_master = self.job_master_filter
#     expensive_job_faliures = jrcp_master\
#                              .where(col("terminal_state") == "Failed")\
#                              .groupby("job_name","job_start_date")\
#                              .agg(round(sum(col("total_dbu_cost")),2).alias("cost_in_USD"))\
#                              .orderBy(col("cost_in_USD").desc()).distinct()
    
#     top3_expensive_faliures = expensive_job_faliures.withColumn("row",row_number().over(windowDate))
     
#     top3_expensive_job_faliures = top3_expensive_faliures.where(top3_expensive_faliures.row <=3)\
#                                     .sort(["job_start_date","cost_in_USD"], ascending=False)\
#                                     .sort(["row"], ascending=False)\
#                                     .withColumnRenamed("job_start_date","date")
    
#     top3_expensive_job_faliures_daily = top3_expensive_job_faliures\
#                                        .select(concat_ws('  :  ',top3_expensive_job_faliures.job_name
#                                                          ,top3_expensive_job_faliures.cost_in_USD)\
#                                        .alias("Expensive_Jobs"),"date","cost_in_USD")\
#                                        .sort(["date","cost_in_USD"], ascending=False)\
#                                        .groupby("date")\
#                                        .agg(F.collect_list("Expensive_Jobs").alias("top_3_expensive_faliure_jobs"))
#     return top3_expensive_job_faliures_daily