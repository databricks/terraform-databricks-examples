data "databricks_user" "user" {
  user_name = var.user_name
}

resource "databricks_mws_permission_assignment" "user" {
  workspace_id = var.workspace_id
  principal_id = data.databricks_user.user.id
  permissions  = ["ADMIN"]
}