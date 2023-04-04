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

resource "databricks_external_location" "landing-external-location" {
  name            = var.landing_external_location_name
  url             = var.landing_adls_path
  credential_name = var.storage_credential_id
}