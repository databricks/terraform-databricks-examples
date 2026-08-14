resource "databricks_catalog" "file_events" {
  count          = var.create_catalog ? 1 : 0
  name           = var.catalog_name
  storage_root   = databricks_external_location.file_events.url
  comment        = "Catalog with managed file events - Managed by Terraform"
  isolation_mode = var.catalog_isolation_mode
  owner          = var.catalog_owner

  force_destroy = var.force_destroy_bucket

  depends_on = [databricks_external_location.file_events]
}

resource "databricks_grants" "catalog" {
  count   = var.create_catalog && length(var.catalog_grants) > 0 ? 1 : 0
  catalog = databricks_catalog.file_events[0].name

  dynamic "grant" {
    for_each = var.catalog_grants
    content {
      principal  = grant.value.principal
      privileges = grant.value.privileges
    }
  }
}
