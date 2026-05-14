resource "databricks_metastore" "this" {
  name          = var.metastore_name
  region        = var.google_region
  force_destroy = true
}

resource "databricks_metastore_assignment" "this" {
  workspace_id = var.databricks_workspace_id
  metastore_id = databricks_metastore.this.id
}

resource "databricks_storage_credential" "this" {
  provider = databricks.workspace
  name     = "${var.prefix}-storage-credential"
  databricks_gcp_service_account {}
  depends_on = [databricks_metastore_assignment.this]
}

resource "databricks_external_location" "this" {
  provider = databricks.workspace
  name     = "${var.prefix}-external-location"
  url      = "gs://${google_storage_bucket.ext_bucket.name}/"

  credential_name = databricks_storage_credential.this.id

  comment = "Managed by TF"
  depends_on = [
    databricks_metastore_assignment.this,
    google_storage_bucket_iam_member.unity_cred_reader,
    google_storage_bucket_iam_member.unity_cred_admin
  ]
}

resource "databricks_catalog" "main" {
  provider       = databricks.workspace
  name           = var.catalog_name
  storage_root   = databricks_external_location.this.url
  comment        = "This catalog is managed by terraform"
  isolation_mode = "OPEN"
}