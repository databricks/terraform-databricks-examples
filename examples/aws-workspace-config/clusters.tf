data "databricks_spark_version" "latest_lts" {
  long_term_support = true
}

resource "databricks_cluster" "tiny" {
  provider                = databricks.ws1
  cluster_name            = "tiny"
  spark_version           = data.databricks_spark_version.latest_lts.id
  node_type_id            = "m4.large"
  driver_node_type_id     = "m4.large"
  autotermination_minutes = 10
  autoscale {
    min_workers = 1
    max_workers = 2
  }
  aws_attributes {
    first_on_demand        = 1
    availability           = "SPOT_WITH_FALLBACK"
    zone_id                = "ap-southeast-1a" // required, must be in the same region as the workspace, it simply ignores other region's zone
    spot_bid_price_percent = 100
    ebs_volume_type        = "GENERAL_PURPOSE_SSD"
    ebs_volume_count       = 3
    ebs_volume_size        = 50
  }
}

output "sample_cluster_id" {
  value = databricks_cluster.tiny.cluster_id
}
