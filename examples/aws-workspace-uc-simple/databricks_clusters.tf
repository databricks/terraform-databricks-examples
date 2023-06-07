# Get the smallest cluster node possible on that cloud
data "databricks_node_type" "smallest" {
  provider   = databricks.workspace
  local_disk = true
  depends_on = [module.databricks_workspace]
}

# Get the latest LTS Version for Databricks Runtime
data "databricks_spark_version" "latest_version" {
  provider          = databricks.workspace
  long_term_support = true
  depends_on        = [module.databricks_workspace]
}

resource "databricks_cluster" "unity_catalog_cluster" {
  provider                    = databricks.workspace
  cluster_name                = "Demo Cluster"
  spark_version               = data.databricks_spark_version.latest_version.id
  node_type_id                = data.databricks_node_type.smallest.id
  apply_policy_default_values = true
  data_security_mode          = "USER_ISOLATION"
  autotermination_minutes     = 30
  aws_attributes {
    availability           = "SPOT"
    first_on_demand        = 1
    spot_bid_price_percent = 100
  }

  depends_on = [
    module.databricks_workspace
  ]

  autoscale {
    min_workers = 1
    max_workers = 3
  }


  custom_tags = {
    "ClusterScope" = "Initial Demo"
  }

}
