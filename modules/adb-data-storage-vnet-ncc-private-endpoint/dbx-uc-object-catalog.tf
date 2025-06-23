// Create a catalog in the Unity Catalog metastore using the external location created
resource "databricks_catalog" "this" {
  # Name of the catalog to create
  name = var.databricks_calalog
  
  # Use the Databricks provider configured for workspace-level operations
  provider = databricks.workspace
  
  # ID of the Unity Catalog metastore where the catalog will be stored
  metastore_id = data.databricks_metastore.this.id
  
  # Storage root URL for the catalog (linked to the external location)
  storage_root = databricks_external_location.this.url
  
  # Isolation mode for the catalog (e.g., isolated)
  isolation_mode = "ISOLATED"

  force_destroy = true
  
}

// Grant access to the catalog for workspace admins or specified principal
resource "databricks_grants" "grant_catalog_access" {
  # Use the Databricks provider configured for workspace-level operations
  provider = databricks.workspace
  
  # Name of the catalog to grant access to
  catalog = databricks_catalog.this.name
  
  # Grant access to the specified principal (e.g., workspace admins or other users)
  grant {
    # Name of the principal to grant access to (e.g., user or service principal)
    principal  = var.principal_name
    
    # List of privileges to grant to the principal (e.g., ALL_PRIVILEGES, BROWSE)
    privileges = var.catalog_privileges
  }
  
}
