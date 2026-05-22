module "unity_catalog" {
  source = "../../modules/gcp/unity-catalog"

  providers = {
    databricks           = databricks
    databricks.workspace = databricks.workspace
  }

  databricks_workspace_id  = module.workspace.workspace_id
  databricks_workspace_url = module.workspace.workspace_url
  google_project           = var.workspace_google_project
  google_region            = var.google_region
  prefix                   = var.prefix
  metastore_name           = var.metastore_name
  catalog_name             = var.catalog_name
}