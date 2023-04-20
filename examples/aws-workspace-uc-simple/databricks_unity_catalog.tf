resource "databricks_grants" "unity_catalog_grants" {
  provider  = databricks.workspace
  metastore = module.unity_catalog.metastore_id
  grant {
    principal  = local.unity_admin_group
    privileges = ["CREATE_CATALOG", "CREATE_EXTERNAL_LOCATION"]
  }
  depends_on = [
    resource.databricks_mws_permission_assignment.add_admin_group
  ]
}
