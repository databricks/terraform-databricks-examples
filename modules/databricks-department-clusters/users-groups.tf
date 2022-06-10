
resource "databricks_group" "data_eng" {
  display_name = var.group_name
  #  allow_cluster_create       = true
  #  allow_instance_pool_create = true
}

resource "databricks_user" "de" {
  for_each  = toset(var.user_names)
  user_name = each.value
}

resource "databricks_group_member" "data_eng_member" {
  for_each  = toset(var.user_names)
  group_id  = databricks_group.data_eng.id
  member_id = databricks_user.de[each.value].id
}
