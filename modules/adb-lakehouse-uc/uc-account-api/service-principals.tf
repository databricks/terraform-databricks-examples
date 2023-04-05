#Create Databricks service principal in Databricks account. The external_id is the id of the service principal in AAD
resource "databricks_service_principal" "databricks_service_principal" {
  for_each       = var.service_principals
  display_name   = each.value["display_name"]
  application_id = each.value["sp_id"]
  external_id    = each.value["sp_id"]
}