# Databricks notebook source
# MAGIC %md
# MAGIC %md
# MAGIC ## READ ME
# MAGIC > 
# MAGIC -  **Overwatch version - 07x**
# MAGIC -  **Widgets are added to apply filters to the dashboards**
# MAGIC 
# MAGIC Widgets Used:
# MAGIC | # | Widgets | Value | Default
# MAGIC | ----------- | ----------- | ----------- | ----------- |
# MAGIC | 1 | ETL Database Name | Your ETL Database Name | overwatch_etl
# MAGIC | 2 | Consumer DB Name | Your Consumer Database Name | overwatch
# MAGIC | 3 | Workspace Name | List of workspace (overwatch deployed) name | all
# MAGIC | 4 | Start Date | Start date for analysis | Current Date
# MAGIC | 5 | End Date | End date for analysis | 30 days from current
# MAGIC | 6 | Cluster tags | To filter by cluster tag names | None
# MAGIC | 7 | Include weekends | To record all days, include weekends | Yes |
# MAGIC | 8 | Only weekends | To record only weekends | No |

# COMMAND ----------

# MAGIC %md
# MAGIC - **Use the widgets to apply filters in the dashboards**
# MAGIC - **Once the filters are applied, run the helper cmd (*""%run "./Helpers"""*) to reflect the filters in the master dataframe**
# MAGIC - **Go to View on topbar and select the *View* named as ClusterFinal under *Dashboards* to view the plots alone**

# COMMAND ----------

# To remove all the widgets. Run only for the first time and comment it out after the first run.
# dbutils.widgets.removeAll()

# COMMAND ----------

dbutils.widgets.text("etlDB", "overwatch_etl", "1. ETL Database Name")
dbutils.widgets.text("consumerDB", "overwatch", "2. Consumer DB Name")

# COMMAND ----------

# MAGIC %md
# MAGIC #### Update Boxes 1 and 2 with  your etl and consumer database names respectively
# MAGIC >
# MAGIC The following cells must know the Overwatch database names before they can execute. Please populate the cells before continuing.

# COMMAND ----------

# To get the database names from the widgets
etlDB = str(dbutils.widgets.get("etlDB"))
consumerDB = str(dbutils.widgets.get("consumerDB"))

# COMMAND ----------

# MAGIC %run "/Dashboards_Dev/In Progress/07x_rc_customer/Helpers" $etlDB = etlDB $consumerDB = consumerDB

# COMMAND ----------

dbutils.widgets.text("tags", "all", "6. Cluster tags")
dbutils.widgets.dropdown("include_weekends", "Yes", ["Yes", "No"], "7. Include weekends")
dbutils.widgets.dropdown("only_weekends", "No", ["Yes", "No"], "8. Only weekends")
cluster_tags = str(dbutils.widgets.get("tags"))
include_weekends = dbutils.widgets.get("include_weekends")
only_weekends = dbutils.widgets.get("only_weekends")

fetch_Name = spark.sql(f"select distinct workspace_name from {etlDB}.pipeline_report").rdd.flatMap(lambda x: x).collect()+["all"]
dbutils.widgets.multiselect("workspace_name","all",fetch_Name, "3. Workspace Name")
workspaceName =  spark.sql(f"select distinct workspace_name from {etlDB}.pipeline_report").rdd.flatMap(lambda x: x).collect() if 'all' in dbutils.widgets.get("workspace_name").split(',') else dbutils.widgets.get("workspace_name").split(',')
dbutils.widgets.combobox("4. Start Date", f"{date.today() - timedelta(days=30)}", "")
dbutils.widgets.combobox("5. End Date", f"{date.today()}", "")
start_date = str(dbutils.widgets.get("4. Start Date"))
end_date = str(dbutils.widgets.get("5. End Date"))

# COMMAND ----------

# MAGIC %md
# MAGIC #### Now that all the widgets are present and you can apply the filters wherever required 

# COMMAND ----------

masters = master(etlDB,consumerDB,workspaceName,start_date,end_date)

clsf_master = masters.cluster_master_filter(includeWeekend = include_weekends,onlyWeekend = only_weekends)

# COMMAND ----------

# MAGIC %md
# MAGIC ### Compute Overview 
# MAGIC 
# MAGIC > As a budget owner / admin I want to be able to quickly understand the cluster makeup in my environment their costs, etc.

# COMMAND ----------

df = clsf_master\
.select("cluster_category")\
.distinct()

display(df)

# COMMAND ----------

dbu_spend = clsf_master\
.groupBy("cluster_category",
         "state_start_date",
         "workspace_name")\
.agg(round(sum(col("total_DBU_cost")),2).alias("total_DBU_cost(USD)"))\
.toPandas()

display(dbu_spend)

# COMMAND ----------


fig = px.box(dbu_spend, 
             x = "cluster_category", 
             y = "total_DBU_cost(USD)",
             title = "DBU Spend by cluster category",
             hover_data = ["state_start_date"],
             points = "all", 
             color = "workspace_name")
##fig.update_traces(quartilemethod="exclusive")
fig.show()

# COMMAND ----------

from pyspark.sql import SparkSession, Row
from pyspark.sql.window import Window
from pyspark.sql.functions import col, row_number

daily_cluster_cost = clsf_master\
.withColumn("date", explode("state_dates"))\
.groupBy("date", "organization_id", "workspace_name", "days_in_state", "cluster_id", "cluster_name")\
.agg(round((sum(col("total_DBU_cost"))/col("days_in_state")),2).alias("total_DBU_cost_(USD)"),
    round((sum(col("total_compute_cost"))/col("days_in_state")),2).alias("total_compute_cost_(USD)"),
    round((sum(col("total_cost"))/col("days_in_state")),2).alias("total_cost_(USD)"),
    )\
.orderBy(col("total_DBU_cost_(USD)").desc())\
.distinct()


windowdf = Window.partitionBy(daily_cluster_cost["date"]).orderBy(daily_cluster_cost["total_DBU_cost_(USD)"].desc())

daily_cluster_cost = daily_cluster_cost\
.withColumn("row", row_number().over(windowdf))\
.filter(col("row") == 1 )\
.distinct()\
.toPandas()

display(daily_cluster_cost)

# COMMAND ----------

fig = px.bar(daily_cluster_cost, 
            x = "date",
            y = "total_DBU_cost_(USD)",
            title = "DBU spend by the most expensive cluster per day",
            hover_data = ["organization_id", 
                          "workspace_name", 
                          "date",
                          "cluster_id",
                          "cluster_name",
                          "total_DBU_cost_(USD)",
                          "total_compute_cost_(USD)",
                          "total_cost_(USD)"],
            color = "total_cost_(USD)")
fig.show()

# COMMAND ----------

from pyspark.sql import SparkSession, Row
from pyspark.sql.window import Window
from pyspark.sql.functions import col, row_number

daily_cluster_spent = clsf_master\
.withColumn("date", explode("state_dates"))\
.groupBy("date",
         "days_in_state",
         "cluster_id",
         "cluster_name",
         "organization_id", 
         "workspace_name")\
.agg(round((sum(col("total_DBU_cost"))/col("days_in_state")),2).alias("total_DBU_cost_(USD)"),
    round((sum(col("total_compute_cost"))/col("days_in_state")),2).alias("total_compute_cost_(USD)"),
    round((sum(col("total_cost"))/col("days_in_state")),2).alias("total_cost_(USD)"))\
.orderBy(col("date").asc())\
.distinct()

windowdf = Window.partitionBy(daily_cluster_spent["date"]).orderBy(daily_cluster_spent["total_DBU_cost_(USD)"].desc())

daily_cluster_spent = daily_cluster_spent\
.withColumn("row", row_number().over(windowdf))\
.filter(col("row") <= 20)

daily_cluster_spent_grouped = daily_cluster_spent\
.groupBy("date",
         "organization_id",
         "workspace_name"
        )\
.agg(round(sum("total_DBU_cost_(USD)"),2).alias("Total_DBU_cost_(USD)"))\
.orderBy(col("date").desc())\
.distinct()\
.toPandas()


display(daily_cluster_spent_grouped)

# COMMAND ----------

fig = px.bar(daily_cluster_spent_grouped, 
            x = "date",
            y = "Total_DBU_cost_(USD)",
            title = "Daily cluster spend chart (top 20)",
            hover_data = ["organization_id", 
                          "workspace_name", 
                          "date",
                          "Total_DBU_cost_(USD)"
                          ],
            color = "workspace_name")
fig.show()

# COMMAND ----------

dbu_spend_without_autotermination = clsf_master\
.filter(((col("auto_termination_minutes") == 0) | (col("auto_termination_minutes").isNull())) 
        & (col("cluster_category") == "Interactive")
        
       )\
.fillna(0, subset=["core_hours"])\
.withColumn("date", explode("state_dates"))\
.groupBy("date", "organization_id", "workspace_name", "days_in_state", "cluster_id", "cluster_name")\
.agg(round((sum(col("total_DBU_cost"))/col("days_in_state")),2).alias("DBU_cost_(USD)"),
     round((sum(col("total_compute_cost"))/col("days_in_state")),2).alias("Compute_cost_(USD)"),
     round((sum(col("total_cost"))/col("days_in_state")),2).alias("total_cost_(USD)"),
     round((sum(col("core_hours"))/col("days_in_state")),2).alias("core_hours"))\
.orderBy(col("DBU_cost_(USD)").desc())\
.distinct()

Windowdf = Window.partitionBy(dbu_spend_without_autotermination["date"]).orderBy(dbu_spend_without_autotermination["DBU_cost_(USD)"].desc())

dbu_spend_without_autotermination = dbu_spend_without_autotermination\
.withColumn("row", row_number().over(Windowdf))\
.filter(col("row") <= 3 )

dbu_spend_without_autotermination = dbu_spend_without_autotermination\
.withColumn("rank", when(col("row") == 1, "Most expensive")\
            .when(col("row") == 2, "second expensive")\
            .when(col("row") == 3, "third expensive")\
           )\
.distinct()\
.toPandas()



display(dbu_spend_without_autotermination)

# COMMAND ----------

fig = px.scatter(dbu_spend_without_autotermination,
                x = "date",
                y = "DBU_cost_(USD)",
                title = "DBU Spent by the top 3 expensive Interactive clusters (without auto-termination) per day",
                color = "workspace_name",
                hover_data = ["organization_id",
                              "workspace_name",
                              "cluster_id",
                              "cluster_name",
                              "rank",
                              "DBU_cost_(USD)",
                              "Compute_cost_(USD)",
                              "total_cost_(USD)",
                              "core_hours"
                             ])
fig.update_traces(marker_size=15)
fig.show()

# COMMAND ----------

# import plotly.graph_objects as go
# from plotly.subplots import make_subplots

# def getValLabel(dataframe):
#   ji = dataframe.select(["workspace_name","Number_of_clusters"]).rdd.flatMap(lambda x: x).collect()
#   labels = []
#   values = []
#   for i in range(0, len(ji)):
#     if i%2 == 0:
#       labels.append(ji[i])
#     else:
#       values.append(ji[i])
#   return labels, values

# fig = make_subplots(2, 3, 
#                     specs = [[{'type':'domain'}, {'type':'domain'}, {'type':'domain'}],
#                                    [{'type':'domain'}, {'type':'domain'}, {'type':'domain'}]],
#                     subplot_titles = cluster_count.select("cluster_category").distinct().rdd.flatMap(lambda x: x).collect()
#                    )

# #name the dataframe
# cluster_category = cluster_count.select('cluster_category').distinct().rdd.flatMap(lambda x: x).collect()

# dataframe_list = []
# for i in cluster_category:
#   dataframe = cluster_count\
#               .filter(col("cluster_category") == i)\
#               .select(col("Number_of_clusters"), col("workspace_name"))
#   dataframe_list.append(dataframe)


# row = 1
# col = 1 
# for i in dataframe_list:
#   # split the labels and values in the dataframe
#   labels, values = getValLabel(i)

#   fig.add_trace(go.Pie(
#     labels = labels,
#     values = values,
#     name = str(i)
#     ), row, col)
  
#   if col == 3:
#     col = 1
#     row = row + 1
#   else: 
#     col = col + 1


# fig.update_layout(title_text='Cluster count in each category')

# fig.show()
                                     

# COMMAND ----------

cluster_count_SN = clsf_master\
.groupBy("organization_id", "workspace_name", "cluster_category")\
.agg(countDistinct("cluster_id").alias("Number_of_clusters"),
    round(sum(col("total_DBU_cost")),2).alias("Total_DBU_Cost_(USD)")
    )\
.filter(clsf_master["cluster_category"] == "Single Node")\
.toPandas()


display(cluster_count_SN)

# COMMAND ----------

fig = px.pie(cluster_count_SN,             
             values = 'Number_of_clusters', 
             names = 'workspace_name',
             title = 'Cluster count distribution in single node cluster category',
             hover_data = ['Total_DBU_Cost_(USD)'],          
             color_discrete_sequence = px.colors.sequential.Bluered,
            )
fig.update_traces(textinfo='percent+label', textfont_size=12, pull = [0, 0, 0.1, 0], hole = 0.3)
fig.show()

# COMMAND ----------

cluster_count_Interactive = clsf_master\
.groupBy("organization_id", "workspace_name", "cluster_category")\
.agg(countDistinct("cluster_id").alias("Number_of_clusters"),
    round(sum(col("total_DBU_cost")),2).alias("Total_DBU_Cost_(USD)")
    )\
.filter(clsf_master["cluster_category"] == "Interactive")\
.toPandas()


fig = px.pie(cluster_count_Interactive,             
             values = 'Number_of_clusters', 
             names = 'workspace_name',
             title = 'Cluster count distribution in Interactive cluster category',
             hover_data = ['Total_DBU_Cost_(USD)'],          
             color_discrete_sequence = px.colors.sequential.Bluered,
            )
fig.update_traces(textinfo='percent+label', textfont_size=12, pull = [0, 0, 0.1, 0], hole = 0.3)
fig.show()

# COMMAND ----------

cluster_count_Automated = clsf_master\
.groupBy("organization_id", "workspace_name", "cluster_category")\
.agg(countDistinct("cluster_id").alias("Number_of_clusters"),
    round(sum(col("total_DBU_cost")),2).alias("Total_DBU_Cost_(USD)")
    )\
.filter(clsf_master["cluster_category"] == "Automated")\
.toPandas()


fig = px.pie(cluster_count_Automated,             
             values = 'Number_of_clusters', 
             names = 'workspace_name',
             title = 'Cluster count distribution in Automated cluster category',
             hover_data = ['Total_DBU_Cost_(USD)'],          
             color_discrete_sequence = px.colors.sequential.Bluered,
            )
fig.update_traces(textinfo='percent+label', textfont_size=12, pull = [0, 0, 0.1, 0], hole = 0.3)
fig.show()

# COMMAND ----------

cluster_count_Warehouse = clsf_master\
.groupBy("organization_id", "workspace_name", "cluster_category")\
.agg(countDistinct("cluster_id").alias("Number_of_clusters"),
    round(sum(col("total_DBU_cost")),2).alias("Total_DBU_Cost_(USD)")
    )\
.filter(clsf_master["cluster_category"] == "Warehouse")\
.toPandas()


fig = px.pie(cluster_count_Warehouse,             
             values = 'Number_of_clusters', 
             names = 'workspace_name',
             title = 'Cluster count distribution in Warehouse cluster category',
             hover_data = ['Total_DBU_Cost_(USD)'],          
             color_discrete_sequence = px.colors.sequential.Bluered,
            )
fig.update_traces(textinfo='percent+label', textfont_size=12, pull = [0, 0, 0.1, 0], hole = 0.3)
fig.show()

# COMMAND ----------

cluster_count_HC = clsf_master\
.groupBy("organization_id", "workspace_name", "cluster_category")\
.agg(countDistinct("cluster_id").alias("Number_of_clusters"),
    round(sum(col("total_DBU_cost")),2).alias("Total_DBU_Cost_(USD)")
    )\
.filter(clsf_master["cluster_category"] == "High-Concurrency")\
.toPandas()


fig = px.pie(cluster_count_HC,             
             values = 'Number_of_clusters', 
             names = 'workspace_name',
             title = 'Cluster count distribution in High concurrency cluster category',
             hover_data = ['Total_DBU_Cost_(USD)'],          
             color_discrete_sequence = px.colors.sequential.Bluered,
            )
fig.update_traces(textinfo='percent+label', textfont_size=12, pull = [0, 0, 0.1, 0], hole = 0.3)
fig.show()

# COMMAND ----------

cluster_count_ST = clsf_master\
.groupBy("organization_id", "workspace_name", "cluster_category")\
.agg(countDistinct("cluster_id").alias("Number_of_clusters"),
    round(sum(col("total_DBU_cost")),2).alias("Total_DBU_Cost_(USD)")
    )\
.filter(clsf_master["cluster_category"] == "Standard")\
.toPandas()


fig = px.pie(cluster_count_ST,             
             values = 'Number_of_clusters', 
             names = 'workspace_name',
             title = 'Cluster count distribution in Standard cluster category',
             hover_data = ['Total_DBU_Cost_(USD)'],          
             color_discrete_sequence = px.colors.sequential.Bluered,
            )
fig.update_traces(textinfo='percent+label', textfont_size=12, pull = [0, 0, 0.1, 0], hole = 0.3)
fig.show()

# COMMAND ----------

from pyspark.sql.functions import *
node_type_count_percent = clsf_master\
.groupBy("organization_id","workspace_name","node_type_id")\
.agg(countDistinct(col("cluster_id")).alias("cluster_count"))\
.orderBy(col("cluster_count").desc())\
.toPandas()

node_type_count_percent.loc[((node_type_count_percent['cluster_count'] / node_type_count_percent['cluster_count'].sum())* 100) < 2 ,'node_type_id'] = 'Other Types'

display(node_type_count_percent)

# COMMAND ----------

fig = px.pie(node_type_count_percent,             
             values = 'cluster_count', 
             names = 'node_type_id',
             title = 'Cluster node type breakdown',
             hover_data = ['workspace_name'],          
             color_discrete_sequence = px.colors.sequential.Bluered,
            )
fig.update_traces(textinfo='percent+label', textfont_size=12, pull = [0, 0, 0.1, 0])
fig.show()

# COMMAND ----------

from pyspark.sql.functions import *
node_type_potential = clsf_master\
.filter(col("worker_potential_core_H").isNotNull())\
.groupBy("organization_id", "workspace_name", "node_type_id")\
.agg(round(sum(col("worker_potential_core_H")),2).alias("Total_node_potential_hours"),
     round(sum(col("total_worker_cost")),2).alias("Total_worker_cost(USD)")
    )\
.orderBy(col("Total_node_potential_hours").desc())\
.toPandas()

display(node_type_potential)

# COMMAND ----------


minimum_cluster_count = int(node_type_potential["Total_node_potential_hours"].sum()*0.05)

node_type_potential.loc[node_type_potential['Total_node_potential_hours'] < minimum_cluster_count,'node_type_id'] = 'Other Types'

fig = px.pie(node_type_potential,               
             values = 'Total_node_potential_hours', 
             names = 'node_type_id',
             title = 'Cluster node type breakdown by potential',
             hover_data = ['Total_worker_cost(USD)'],
             color_discrete_sequence = px.colors.sequential.RdBu
            )

fig.update_traces(textinfo='percent+label', textfont_size=12)
fig.show()

# COMMAND ----------

node_type_potential_by_category = clsf_master\
.filter(col("worker_potential_core_H").isNotNull())\
.groupBy("organization_id", "workspace_name", "cluster_category")\
.agg(round(sum(col("worker_potential_core_H")),2).alias("Total_node_potential_hours"),
     round(sum(col("total_worker_cost")),2).alias("Total_worker_cost(USD)")
    )\
.orderBy(col("Total_node_potential_hours").desc())\
.toPandas()

display(node_type_potential_by_category)

# COMMAND ----------

fig = px.pie(node_type_potential_by_category,             
             values = 'Total_node_potential_hours', 
             names = 'cluster_category',
             title = 'Cluster node potential breakdown by cluster category',
             hover_data = ['Total_worker_cost(USD)'],
             color_discrete_sequence = px.colors.sequential.RdBu
            )
fig.update_traces(textinfo='percent+label', textfont_size=12, pull = [0.08, 0.08, 0.08, 0.08, 0.08])
fig.show()

# COMMAND ----------

from pyspark.sql import SparkSession, Row
from pyspark.sql.window import Window
from pyspark.sql.functions import col, row_number

cluster_cost_per_category = (
    clsf_master.groupBy("state_start_date", "workspace_name", "cluster_category")
    .agg(
        round(sum(col("total_DBU_cost")), 2).alias("total_DBU_cost(USD)"),
        round(sum(col("total_compute_cost")), 2).alias("Total_compute_cost(USD)"),
        round(sum(col("total_cost")), 2).alias("Total_cost(USD)"),
    )
    .orderBy(round(sum(col("total_cost")), 2).desc())
)

windowDept = Window.partitionBy(cluster_cost_per_category["cluster_category"]).orderBy(
    cluster_cost_per_category["Total_cost(USD)"].desc()
)

cluster_cost_per_category = (
    cluster_cost_per_category.withColumn("row", row_number().over(windowDept))
    .filter(
        (col("row") <= 20)
        & (
            (cluster_cost_per_category["cluster_category"] == ("Interactive"))
            | (cluster_cost_per_category["cluster_category"] == ("Automated"))
            | (cluster_cost_per_category["cluster_category"] == ("High-Concurrency"))
        )
    )
    .toPandas()
)

display(cluster_cost_per_category)

# COMMAND ----------

fig = px.violin(cluster_cost_per_category,
                x = "cluster_category",
                y = "Total_cost(USD)",
                title = "Total cost (dbu cost + compute cost) incurred by top 20 clusters per cluster category",
                color = "workspace_name",
                box = True,
                points = "all",
                hover_data = cluster_cost_per_category.columns)

fig.show()

# COMMAND ----------

# MAGIC %md
# MAGIC ## Autoscaling clusters

# COMMAND ----------

# MAGIC %md
# MAGIC ### Auto-Scaling
# MAGIC > As an admin I want to understand how many clusters are utilizing auto-scaling, their scaling ranges, and their efficiencies

# COMMAND ----------

autoscaling_cluster = clsf_master\
.filter(col("autoscale").isNotNull())\
.groupBy("organization_id", "workspace_name", "cluster_category")\
.agg(countDistinct(col("cluster_id")).alias("cluster_count"),
    round(sum(col("total_DBU_cost")),2).alias("total_DBU_cost(USD)"))\
.orderBy(col("cluster_count").desc())\
.toPandas()

display(autoscaling_cluster)

# COMMAND ----------

fig = px.pie(autoscaling_cluster,             
             values = 'cluster_count', 
             names = 'cluster_category',
             title = 'Percentage of Autoscaling clusters per category',
             hover_data = ['total_DBU_cost(USD)']
            )
fig.update_traces(textinfo='percent+label', textfont_size=12, pull = [0.08, 0.08, 0.08, 0.08, 0.08])
fig.show()

# COMMAND ----------

scaleup_time_withoutPools = clsf_master\
.filter(
      (col("autoscale").isNotNull())
       & (col("state") == "RESIZING") 
       & (col("current_num_workers") < col("target_num_workers"))
       & (col("instance_pool_id").isNull())
      
      )\
.groupBy("state_start_date", "organization_id", "workspace_name", "cluster_category")\
.agg(round(avg("uptime_in_state_H"), 2).alias("average_scale_up_time(Hours)"))\
.orderBy(col("average_scale_up_time(Hours)").desc())\
.distinct()\
.toPandas()

display(scaleup_time_withoutPools)
# clusters with pools are not getting resized.

# COMMAND ----------

fig = px.box(scaleup_time_withoutPools, 
             x = "cluster_category", 
             y = "average_scale_up_time(Hours)",
             title = "Scale up time of clusters (Without pools) by cluster category", 
             points = "all", 
             color = "workspace_name")
##fig.update_traces(quartilemethod="exclusive")

fig.show()

# COMMAND ----------

scaleup_time_withPools = clsf_master\
.filter(
      (col("autoscale").isNotNull())
       & (col("state") == "RESIZING") 
       & (col("current_num_workers") < col("target_num_workers"))
       & (col("instance_pool_id").isNotNull())
      )\
.groupBy("state_start_date", "organization_id", "workspace_name", "cluster_category")\
.agg(round(avg("uptime_in_state_H"), 2).alias("average_scale_up_time(Hours)"))\
.orderBy(col("average_scale_up_time(Hours)").desc())\
# .toPandas()

display(scaleup_time_withPools)

# COMMAND ----------

# fig = px.box(scaleup_time_withPools, 
#              x = "cluster_category", 
#              y = "average_scale_up_time(Hours)",
#              title = "Scale up time of clusters (With pools) by cluster category", 
#              points = "all", 
#              color = "workspace_name")
# ##fig.update_traces(quartilemethod="exclusive")

# fig.show()

# COMMAND ----------

cost_of_autoscaling_clusters_per_category = clsf_master\
.filter(col("autoscale").isNotNull())\
.groupBy("state_start_date","workspace_name","cluster_category")\
.agg(
     round(sum(col("total_DBU_cost")),2).alias("total_DBU_cost(USD)"),
     round(sum(col("total_compute_cost")),2).alias("Total_compute_cost(USD)"),
     round(sum(col("total_cost")),2).alias("Total_cost(USD)")
    )\
.orderBy((col("Total_cost(USD)")).desc())

windowDept = Window.partitionBy(cost_of_autoscaling_clusters_per_category["cluster_category"]).orderBy(
    cost_of_autoscaling_clusters_per_category["Total_cost(USD)"].desc()
)

cost_of_autoscaling_clusters_per_category = (
    cost_of_autoscaling_clusters_per_category.withColumn("row", row_number().over(windowDept))\
    .filter(
        (col("row") <= 20))\
    .drop("row")\
    .toPandas()
)


display(cost_of_autoscaling_clusters_per_category)

# COMMAND ----------

fig = px.violin(cost_of_autoscaling_clusters_per_category,
                x = "cluster_category",
                y = "Total_cost(USD)",
                title = "Total cost of autoscaling clusters (top 20) per cluster category",
                color = "workspace_name",
                box = True,
                points = "all",
                hover_data = cost_of_autoscaling_clusters_per_category.columns)

fig.show()

# COMMAND ----------

# MAGIC %md
# MAGIC ### Cluster Stability
# MAGIC 
# MAGIC > As an admin I want to understand my cluster stability. I operate under the premise that unstable clusters are restarted when they become unstable
# MAGIC 
# MAGIC 
# MAGIC 
# MAGIC 
# MAGIC   

# COMMAND ----------

ClusterFailedCount = clsf_master\
.where(
  ((col("state") == "SPARK_EXCEPTION")
      |(col("state") == "DRIVER_UNAVAILABLE")
      |(col("state") == "DBFS_DOWN")
      |(col("state") == "NODES_LOST")
      |(col("state") == "DRIVER_NOT_RESPONDING")
      |(col("state") == "METASTORE_DOWN")
      ) &
      (col("is_automated") == "false")
  )\
.groupBy(clsf_master["state"], clsf_master["node_type_id"])\
.agg(countDistinct("cluster_id").alias("Count_ClusterID"))\
.orderBy(col("Count_ClusterID").desc())\
.limit(20)\
.toPandas()


display(ClusterFailedCount)


# COMMAND ----------

fig = px.bar(ClusterFailedCount,
             x = "state",
             y = "Count_ClusterID",
             color_continuous_scale = ["green", "red"],
             color = "Count_ClusterID",
             hover_data = ["node_type_id"],
             title = "Cluster Failure States and count of failures")
             
fig = fig.update_layout(
    xaxis_title = "Failure states",
    yaxis_title = "Count of failure",
)



fig.show()

# COMMAND ----------

ClusterFailedCountbyWorkspace = clsf_master\
.where(
  ((col("state") == "SPARK_EXCEPTION")
      |(col("state") == "DRIVER_UNAVAILABLE")
      |(col("state") == "DBFS_DOWN")
      |(col("state") == "NODES_LOST")
      |(col("state") == "DRIVER_NOT_RESPONDING")
      |(col("state") == "METASTORE_DOWN")
      ) &
      (col("is_automated") == "false")
  )\
.groupBy(clsf_master["organization_id"], clsf_master["workspace_name"], clsf_master["state"], clsf_master["node_type_id"])\
.agg(countDistinct("cluster_id").alias("Count_ClusterID"),
     round(sum(col("total_cost")),2).alias("cost_of_failure")
    )\
.orderBy(col("cost_of_failure").desc())\
.toPandas()


display(ClusterFailedCountbyWorkspace)


# COMMAND ----------

fig = px.bar(ClusterFailedCountbyWorkspace,
             x = "state",
             y = "cost_of_failure",
             color_continuous_scale = ["green", "red"],
             color = "workspace_name",
             hover_data = ["organization_id", "workspace_name", "node_type_id", "Count_ClusterID"],
             title = "Cost of cluster failures per Failure states per workspace")
             
fig = fig.update_layout(
    xaxis_title = "Failure states",
    yaxis_title = "Cost of Failure",
)

fig.show()

# COMMAND ----------


ClusterFailedCountViolin = clsf_master\
.where(
  ((col("state") == "SPARK_EXCEPTION")
      |(col("state") == "DRIVER_UNAVAILABLE")
      |(col("state") == "DBFS_DOWN")
      |(col("state") == "NODES_LOST")
      |(col("state") == "DRIVER_NOT_RESPONDING")
      |(col("state") == "METASTORE_DOWN")
      ) & (col("is_automated") == "false")
)\
.groupBy(clsf_master["organization_id"],
         clsf_master["workspace_name"],
         clsf_master["cluster_category"],
         clsf_master["state"],
         clsf_master["node_type_id"]
        )\
.agg(countDistinct("cluster_id").alias("Count_ClusterID"))\
.orderBy(col("Count_ClusterID").desc())\
.limit(30)\
.distinct()\
.toPandas()

display(ClusterFailedCountViolin)

# COMMAND ----------

fig = px.violin(ClusterFailedCountViolin,
                x = "state",
                y = "Count_ClusterID",
                title = "Cluster Failure States and failure count distribution",
                color = "workspace_name",
                box = True,
                points = "all",
                hover_data = ["organization_id", "workspace_name", "node_type_id", "cluster_category"]
               )

fig = fig.update_layout(
    xaxis_title = "Failure states",
    yaxis_title = "Count of failure")

fig.show()

# COMMAND ----------

restart_count = clsf_master\
.where((col("cluster_category") == "Interactive")
       & (col("state") == "RESTARTING")
      )\
.groupBy("state_start_date",
         "organization_id",
         "cluster_id",
         "cluster_name",
         "workspace_name",
         "state"
        )\
.agg(countDistinct("unixTimeMS_state_start").alias("cluster_restart_count"),
     round(sum(col("total_cost")),2).alias("Restarting_cost_(USD)"),
     round(sum(col("uptime_in_state_H")),2).alias("Uptime_in_state_Hours"))\
.toPandas()


display(restart_count)

# COMMAND ----------

fig = px.bar(restart_count,
             x = "state_start_date",
             y = "cluster_restart_count",
             title = "Interactive cluster restarts per day per cluster",
             color = "workspace_name",
             hover_data = ["organization_id", "workspace_name", "cluster_id", "cluster_name", "Restarting_cost_(USD)", "Uptime_in_state_Hours"]
            )
fig.show()

# COMMAND ----------

