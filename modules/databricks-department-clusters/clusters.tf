data "databricks_node_type" "smallest" {
  local_disk = true
}

data "databricks_spark_version" "latest_lts" {
  long_term_support = true
}

resource "databricks_cluster" "team_cluster" {
  cluster_name            = "${var.department}-${var.cluster_name}"
  spark_version           = data.databricks_spark_version.latest_lts.id
  node_type_id            = data.databricks_node_type.smallest.id
  autotermination_minutes = 20

  autoscale {
    min_workers = 1
    max_workers = 10
  }

  custom_tags = merge(var.tags, {
    Team = var.department
  })
}

resource "databricks_permissions" "can_manage_team_cluster" {
  cluster_id = databricks_cluster.team_cluster.id
  access_control {
    group_name       = databricks_group.data_eng.display_name
    permission_level = "CAN_MANAGE"
  }
}
