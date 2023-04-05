module "aws-workspace-basic" {
  source                      = "github.com/databricks/terraform-databricks-examples/modules/aws-workspace-basic"
  databricks_account_id       = var.databricks_account_id
  databricks_account_username = var.databricks_account_username
  databricks_account_password = var.databricks_account_password
}