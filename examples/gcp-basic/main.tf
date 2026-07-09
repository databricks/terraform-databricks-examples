module "workspace" {
  source = "../../modules/gcp/databricks-workspace"

  prefix                = var.prefix
  databricks_account_id = var.databricks_account_id
  google_project        = var.google_project
  google_region         = var.google_region
  workspace_name        = var.workspace_name

  vpc_source = { spoke = "databricks_managed" }
}
