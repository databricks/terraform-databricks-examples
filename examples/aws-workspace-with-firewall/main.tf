module "aws-workspace-with-firewall" {
  source                      = "github.com/databricks/terraform-databricks-examples/modules/aws-workspace-with-firewall"
  databricks_account_id       = var.databricks_account_id
}