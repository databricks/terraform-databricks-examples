resource "databricks_cluster_policy" "fair_use" {
  name = "${var.department} Cluster Policy"
  definition = jsonencode({
    "dbus_per_hour" : {
      "type" : "range",
      "maxValue" : 10
    },
    # "spark_conf.spark.databricks.cluster.profile" : {
    #   "type" : "fixed",
    #   "value" : "serverless",
    #   "hidden" : true
    # },
    "instance_pool_id" : {
      "type" : "forbidden",
      "hidden" : true
    },
    "driver_node_type_id" : {
      "type" : "fixed",
      "value" : data.databricks_node_type.smallest.id,
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

resource "databricks_permissions" "can_use_cluster_policy" {
  cluster_policy_id = databricks_cluster_policy.fair_use.id
  access_control {
    group_name       = databricks_group.data_eng.display_name
    permission_level = "CAN_USE"
  }
}
