# Create a cluster for each user
resource "databricks_cluster" "dedicated_user_clusters" {
  provider     = databricks.workspace
  for_each     = toset(var.databricks_users)
  cluster_name = "${each.value}-dedicated-cluster"

  spark_version           = "15.4.x-scala2.12"
  node_type_id            = "r5.xlarge"
  autotermination_minutes = 30
  is_single_node          = true
  kind                    = "CLASSIC_PREVIEW"
  data_security_mode      = "SINGLE_USER"
  enable_elastic_disk     = true

  custom_tags = {
    Owner = each.value
  }
}

# Separate permissions resource but with lifecycle rule to prevent cluster restarts due to permission changes
resource "databricks_permissions" "cluster_permissions" {
  provider = databricks.workspace
  for_each = databricks_cluster.dedicated_user_clusters

  cluster_id = each.value.id

  access_control {
    user_name        = each.key
    permission_level = "CAN_RESTART"
  }

  lifecycle {
    ignore_changes = [
      cluster_id
    ]
  }
}
