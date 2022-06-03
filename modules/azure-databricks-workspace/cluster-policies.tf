
resource "databricks_cluster_policy" "fair_use" {
  name = "${var.department} Cluster Policy"
  definition = jsonencode({
    "dbus_per_hour" : {
      "type" : "range",
      "maxValue" : 10
    },
    "spark_conf.spark.databricks.cluster.profile" : {
      "type" : "fixed",
      "value" : "serverless",
      "hidden" : true
    },
    "instance_pool_id" : {
      "type" : "forbidden",
      "hidden" : true
    },
    "spark_version" : {
       "type" : "regex",
       "pattern" : "6\\.[0-9]+\\.x-scala.*",
       "defaultValue" : "6.6.x-scala2.11"
    },
    "driver_node_type_id" : {
      "type" : "fixed",
      "value" : "i3.2xlarge",
      "hidden" : true
    },
    "autoscale.min_workers" : {
      "type" : "fixed",
      "value" : 1,
      "hidden" : true
    },
    "custom_tags.Team" : {
      "type" : "fixed",
      "value" : var.department
    }
  })
}