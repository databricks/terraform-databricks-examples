// Create a catalog in the metastore using the external location created
resource "databricks_catalog" "this" {
  # Name of the catalog to create
  name = var.databricks_calalog

  # Use the Databricks provider configured for workspace-level operations
  provider = databricks.workspace

  # ID of the metastore where the catalog will be stored
  metastore_id = data.databricks_metastore.this.id

  # URL of the storage root for the catalog (e.g., an external location)
  storage_root = databricks_external_location.this.url

  # Isolation mode for the catalog (e.g., isolated)
  isolation_mode = "ISOLATED"

  force_destroy = true

}

// Grant access to the catalog for workspace admins
resource "databricks_grants" "grant_catalog_access" {
  # Use the Databricks provider configured for workspace-level operations
  provider = databricks.workspace

  # Name of the catalog to grant access to
  catalog = databricks_catalog.this.name

  # Grant access to the specified principal (e.g., workspace admins)
  grant {
    # Name of the principal to grant access to
    principal = var.principal_name

    # Privileges to grant (e.g., all privileges)
    privileges = var.catalog_privileges
  }

}
