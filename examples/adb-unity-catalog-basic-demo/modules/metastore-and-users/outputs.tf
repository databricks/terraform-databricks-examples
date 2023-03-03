output "databricks_groups" {
  value = {
    for group in databricks_group.this : group.external_id => group.id
  }
}
output "databricks_users" {
  value = {
    for user in databricks_user.this : user.external_id => user.id
  }
}
output "databricks_sps" {
  value = {
    for sp in databricks_service_principal.sp : sp.external_id => sp.id
  }
}
