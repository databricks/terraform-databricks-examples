
resource "databricks_group" "data_eng" {
  display_name               = var.group_name
  allow_cluster_create       = true
  allow_instance_pool_create = true
}

resource "databricks_user" "de" {
  user_name = var.user_name
}

resource "databricks_group_member" "data_eng_member" {
  group_id  = databricks_group.data_eng.id
  member_id = databricks_user.de.id
}