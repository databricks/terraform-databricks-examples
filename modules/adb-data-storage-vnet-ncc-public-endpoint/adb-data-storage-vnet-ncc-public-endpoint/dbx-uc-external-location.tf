// Add storage credentials to the Databricks account using a managed identity
resource "databricks_storage_credential" "this" {
  # Use the Databricks provider configured for workspace-level operations
  provider = databricks.workspace

  # Name of the storage credential to create
  name = "${var.name_prefix}-storage-credential"

  # ID of the metastore where the credential will be stored
  metastore_id = data.databricks_metastore.this.id

  # Configure Azure managed identity for authentication
  azure_managed_identity {
    # ID of the access connector to use with the managed identity
    access_connector_id = azurerm_databricks_access_connector.this.id

    # ID of the user-assigned managed identity to use
    managed_identity_id = azurerm_user_assigned_identity.this.id
  }

  # Isolation mode for the credential (e.g., isolated)
  isolation_mode = "ISOLATION_MODE_ISOLATED"

  # Comment describing the credential
  comment = "Managed identity credential managed by TF"

  # Ensure the credential depends on both the access connector and storage account being created first
  depends_on = [azurerm_databricks_access_connector.this, azurerm_storage_account.this]
}

// Add an external location to the Databricks account
resource "databricks_external_location" "this" {
  # Use the Databricks provider configured for workspace-level operations
  provider = databricks.workspace

  # Name of the external location to create
  name = "${var.name_prefix}-external-location"

  # ID of the metastore where the external location will be stored
  metastore_id = data.databricks_metastore.this.id

  # URL of the external location (e.g., an Azure Data Lake Storage path)
  url = format("abfss://%s@%s.dfs.core.windows.net/", azurerm_storage_container.this.name, azurerm_storage_account.this.name)

  # Name of the storage credential to use with the external location
  credential_name = databricks_storage_credential.this.name

  # Isolation mode for the external location (e.g., isolated)
  isolation_mode = "ISOLATION_MODE_ISOLATED"

  # Allow force destruction of the external location
  force_destroy = true

  # Comment describing the external location
  comment = "Managed by TF"

  # Ensure the external location depends on the storage credential being created first
  depends_on = [databricks_storage_credential.this]
}

// Grant browse access to the external location for workspace admins
resource "databricks_grants" "admins_browse_access" {
  # Use the Databricks provider configured for workspace-level operations
  provider = databricks.workspace

  # ID of the external location to grant access to
  external_location = databricks_external_location.this.id

  # Grant access to the specified principal (e.g., workspace admins)
  grant {
    # Name of the principal to grant access to
    principal = var.principal_name

    # Privileges to grant (e.g., browse)
    privileges = ["BROWSE"]
  }

  # Ensure the grant depends on the external location being created first
  depends_on = [databricks_external_location.this]
}
