resource "databricks_catalog" "bronze-catalog" {
  metastore_id  = var.metastore_id
  name          = "bronze_catalog_${var.environment_name}"
  comment       = "this catalog is for the bronze layer in the ${var.environment_name} environment"
  force_destroy = false
}

resource "databricks_schema" "bronze_source1-schema" {
  depends_on    = [databricks_catalog.bronze-catalog]
  catalog_name  = databricks_catalog.bronze-catalog.name
  name          = "bronze_source1"
  force_destroy = true
}

data "azurerm_storage_account" "ext_storage" {
  name                = var.landing_external_location_name
  resource_group_name = var.landing_adls_rg
}

resource "azurerm_role_assignment" "ext_storage" {
  scope                = data.azurerm_storage_account.ext_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.access_connector_id
}

resource "databricks_external_location" "landing-external-location" {
  name            = var.landing_external_location_name
  url             = var.landing_adls_path
  credential_name = var.storage_credential_name
  comment         = "Created by TF"
}
