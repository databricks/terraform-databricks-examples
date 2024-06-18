module "aws-workspace-with-firewall" {
  source                = "github.com/databricks/terraform-databricks-examples/modules/aws-workspace-with-firewall"
  databricks_account_id = var.databricks_account_id
}

resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}
