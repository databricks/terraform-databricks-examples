// Databricks notebook source
var diamonds = (spark.read
  .format("csv")
  .option("header", "true")
  .option("inferSchema", "true")
  .load("/databricks-datasets/Rdatasets/data-001/csv/ggplot2/diamonds.csv")
)

diamonds.write.format("delta").mode("overwrite").saveAsTable("diamonds")

// COMMAND ----------

display(diamonds)

// COMMAND ----------

// MAGIC %sql
// MAGIC SELECT color, avg(price) AS price 
// MAGIC FROM diamonds 
// MAGIC GROUP BY color 
// MAGIC ORDER BY COLOR
