module "aws-workspace-basic" {
  source                = "github.com/databricks/terraform-databricks-examples/modules/aws-workspace-basic"
  databricks_account_id = var.databricks_account_id
  region                = var.region
  tags                  = var.tags
  prefix                = var.prefix
  cidr_block            = var.cidr_block
}
