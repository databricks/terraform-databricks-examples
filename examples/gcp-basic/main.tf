module "gcp-basic" {
  source                = "github.com/databricks/terraform-databricks-examples/modules/gcp-workspace-basic"
  databricks_account_id = var.databricks_account_id
  google_project        = var.google_project
  google_region         = var.google_region
  prefix                = var.prefix
  workspace_name        = var.workspace_name
  delegate_from         = var.delegate_from
}
