resource "databricks_grants" "landing-external-location-grants" {
  depends_on        = [databricks_external_location.landing-external-location]
  external_location = var.landing_external_location_name
  dynamic "grant" {
    for_each = toset(var.metastore_admins)
    content {
      principal  = grant.key
      privileges = ["READ_FILES", "WRITE_FILES"]
    }
  }
}

resource "databricks_grants" "catalog_bronze-grants" {
  depends_on = [databricks_catalog.bronze-catalog]
  catalog    = "bronze_catalog_${var.environment_name}"
  dynamic "grant" {
    for_each = toset(var.metastore_admins)
    content {
      principal = grant.key
      privileges = ["USE_CATALOG", "USE_SCHEMA", "SELECT", "EXECUTE", "CREATE_SCHEMA",
      "CREATE_FUNCTION", "CREATE_TABLE", "MODIFY"]
    }
  }
}