# Databricks notebook source
# MAGIC %md
# MAGIC # Setup Widgets For Filtering The Data
# MAGIC >
# MAGIC - **Replace the ETL DB and Consumer DB with your ETL database name and Consumer database name**
# MAGIC - **As default the data will be filter:**
# MAGIC   - For 30days period
# MAGIC   - All workspaces included
# MAGIC   - All clusters included
# MAGIC   - Weekdays and Weekends included
# MAGIC >
# MAGIC - **Use the widgets to filter the data further**

# COMMAND ----------

# MAGIC %md
# MAGIC ## READ ME
# MAGIC 
# MAGIC Widgets Used:
# MAGIC | # | Widgets | Value | Default
# MAGIC | ----------- | ----------- | ----------- | ----------- |
# MAGIC | 1 | ETL Database Name | Your ETL Database Name | None
# MAGIC | 2 | Consumer DB Name | Your Consumer Database Name | None
# MAGIC | 3 | Path Depth | Adjust folder/notebook path level | 4
# MAGIC | 4 | Workspace Name | List of workspace (overwatch deployed) name | all
# MAGIC | 5 | Start Date | Start date for analysis | 30 days from current date
# MAGIC | 6 | End Date | End date for analysis | current date
# MAGIC | 7 | Include weekends | To record all days, include weekends | Yes |
# MAGIC | 8 | Only weekends | To record only weekends | No |

# COMMAND ----------

# MAGIC %md
# MAGIC ## Libraries Used:
# MAGIC 
# MAGIC 1. Plotly 
# MAGIC 2. Overwatch Latest Library "com.databricks.labs:overwatch_2.12:latest"

# COMMAND ----------

