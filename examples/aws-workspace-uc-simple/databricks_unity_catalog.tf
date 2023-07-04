resource "databricks_catalog" "demo_catalog" {
  provider     = databricks.workspace
  metastore_id = module.unity_catalog.metastore_id
  name         = "sandbox_demo_catalog"
  comment      = "This catalog is managed by terraform"
  properties = {
    purpose = "Demoing catalog creation and management using Terraform"
  }

  depends_on = [
    databricks_group_member.my_service_principal,
    resource.databricks_mws_permission_assignment.add_admin_group,
    databricks_group.users
  ]

  force_destroy = true

}

resource "databricks_grants" "unity_catalog_grants" {
  provider = databricks.workspace
  catalog  = databricks_catalog.demo_catalog.name
  grant {
    principal  = local.workspace_users_group
    privileges = ["USE_CATALOG", "USE_SCHEMA", "CREATE_SCHEMA", "CREATE_TABLE"]
  }

  depends_on = [
    resource.databricks_mws_permission_assignment.add_admin_group
  ]
}
