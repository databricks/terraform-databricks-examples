#Retrieve service principals from Databricks account
data "databricks_service_principal" "sp" {
  depends_on     = [databricks_service_principal.databricks_service_principal]
  for_each       = var.service_principals
  application_id = each.value["sp_id"]
}

resource "databricks_mws_permission_assignment" "sp-workspace-assignement" {
  depends_on   = [data.databricks_service_principal.sp]
  for_each     = var.service_principals
  workspace_id = var.workspace_id
  principal_id = data.databricks_service_principal.sp[each.key].sp_id
  permissions  = each.value["permissions"]
}
