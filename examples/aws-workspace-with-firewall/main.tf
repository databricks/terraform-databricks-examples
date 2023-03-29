module "aws-workspace-with-firewall" {
  source                      = "github.com/databricks/terraform-databricks-examples/modules/aws-workspace-with-firewall"
  databricks_account_id       = var.databricks_account_id
  databricks_account_username = var.databricks_account_username
  databricks_account_password = var.databricks_account_password
}