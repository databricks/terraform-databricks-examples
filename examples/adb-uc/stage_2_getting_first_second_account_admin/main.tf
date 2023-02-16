variable "long_lasting_spn_id" {
}

resource "databricks_group" "this" {
  provider     = databricks.azure_account
  display_name = "test_tf_sp"
}

resource "databricks_service_principal_role" "sp_account_admin" {
  service_principal_id = var.long_lasting_spn_id // this is the long living SPN client id
  role                 = "account admin"
  depends_on = [
    databricks_group.this // force this to run after the group is created
  ]
}
