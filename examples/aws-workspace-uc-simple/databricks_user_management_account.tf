data "databricks_service_principal" "admin_service_principal" {
  provider       = databricks.mws
  application_id = var.databricks_client_id
}

resource "databricks_user" "unity_users" {
  provider  = databricks.mws
  for_each  = toset(concat(var.databricks_users, var.databricks_metastore_admins))
  user_name = each.key
  force     = true
}

resource "databricks_group" "admin_group" {
  provider     = databricks.mws
  display_name = local.unity_admin_group
}

resource "databricks_group" "users" {
  provider     = databricks.mws
  display_name = local.workspace_users_group
  depends_on   = [databricks_group.admin_group]
}

# Sleeping for 20s to wait for the workspace to enable identity federation
resource "time_sleep" "wait_for_permission_apis" {
  depends_on = [
    module.unity_catalog
  ]
  create_duration = "20s"
}

resource "databricks_mws_permission_assignment" "add_admin_group" {
  provider     = databricks.mws
  workspace_id = module.databricks_workspace.databricks_workspace_id
  principal_id = resource.databricks_group.admin_group.id
  permissions  = ["ADMIN"]
  depends_on = [
    resource.time_sleep.wait_for_permission_apis
  ]
}

resource "databricks_group_member" "admin_group_member" {
  provider  = databricks.mws
  for_each  = toset(var.databricks_metastore_admins)
  group_id  = databricks_group.admin_group.id
  member_id = databricks_user.unity_users[each.value].id
}

resource "databricks_group_member" "my_service_principal" {
  provider  = databricks.mws
  group_id  = databricks_group.admin_group.id
  member_id = data.databricks_service_principal.admin_service_principal.id
}

resource "databricks_group_member" "users_group_members" {
  provider  = databricks.mws
  for_each  = toset(var.databricks_users)
  group_id  = resource.databricks_group.users.id
  member_id = databricks_user.unity_users[each.value].id
}

resource "databricks_mws_permission_assignment" "add_user_group" {
  provider     = databricks.mws
  workspace_id = module.databricks_workspace.databricks_workspace_id
  principal_id = resource.databricks_group.users.id
  permissions  = ["USER"]
  depends_on = [
    resource.time_sleep.wait_for_permission_apis
  ]
}
