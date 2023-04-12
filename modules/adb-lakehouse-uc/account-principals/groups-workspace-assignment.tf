#retrieve existing AAD groups at Databricks account.
#You would normally use AAD enterprise application to synch groups from AAD to databricks account: https://learn.microsoft.com/en-us/azure/databricks/administration-guide/users-groups/scim/aad
data "databricks_group" "account_groups" {
  for_each     = var.account_groups
  display_name = each.value["group_name"]
}


resource "databricks_mws_permission_assignment" "groups-workspace-assignement" {
  depends_on   = [data.databricks_group.account_groups]
  for_each     = var.account_groups
  workspace_id = var.workspace_id
  principal_id = data.databricks_group.account_groups[each.key].id
  permissions  = each.value["permissions"]
}
