module "aws-exfiltration-protection" {
  source                      = "github.com/databricks/terraform-databricks-examples/modules/aws-exfiltration-protection"
  databricks_account_id       = var.databricks_account_id
  databricks_account_username = var.databricks_account_username
  databricks_account_password = var.databricks_account_password
}

resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}
