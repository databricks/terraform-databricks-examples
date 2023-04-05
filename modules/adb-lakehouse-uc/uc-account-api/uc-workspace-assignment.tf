#this will assign the metastore to to the workspace
resource "databricks_metastore_assignment" "this" {
  depends_on   = [databricks_metastore.databricks-metastore]
  metastore_id = var.metastore_id
  workspace_id = var.workspace_id
}