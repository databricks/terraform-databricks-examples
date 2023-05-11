resource "databricks_sql_endpoint" "this" {
  name             = "Endpoint of ${var.department}"
  cluster_size     = "X-Small"
  max_num_clusters = 3
  min_num_clusters = 1
  auto_stop_mins   = 20

  tags {
    dynamic "custom_tags" {
      for_each = merge(var.tags, { Team = var.department })
      content {
        key   = custom_tags.key
        value = custom_tags.value
      }
    }
  }
}

resource "databricks_permissions" "can_manage_sql_endpoint" {
  sql_endpoint_id = databricks_sql_endpoint.this.id

  access_control {
    group_name       = databricks_group.data_eng.display_name
    permission_level = "CAN_MANAGE"
  }
}
