module "unity_catalog" {
  source = "../../modules/gcp-unity-catalog"

  providers = {
    databricks           = databricks,
    databricks.workspace = databricks.workspace
  }
  databricks_workspace_id  = module.gcp_with_data_exfiltration_protection.workspace_id
  databricks_workspace_url = module.gcp_with_data_exfiltration_protection.workspace_url
  google_project           = var.workspace_google_project
  google_region            = var.google_region
  metastore_name           = var.metastore_name
  catalog_name             = var.catalog_name
  prefix                   = var.prefix
}