module "aws-workspace-basic" {
  source                = "github.com/databricks/terraform-databricks-examples/modules/aws-workspace-basic"
  databricks_account_id = var.databricks_account_id
}