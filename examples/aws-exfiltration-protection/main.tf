module "aws-exfiltration-protection" {
  source                      = "github.com/databricks/terraform-databricks-examples/modules/aws-exfiltration-protection"
  databricks_account_id       = var.databricks_account_id
  databricks_account_username = var.databricks_account_username
  databricks_account_password = var.databricks_account_password
  prefix                      = var.prefix
  tags                        = var.tags
  spoke_cidr_block            = var.spoke_cidr_block
  hub_cidr_block              = var.hub_cidr_block
  region                      = var.region
  whitelisted_urls            = var.whitelisted_urls
  enable_private_link         = var.enable_private_link

  resource "random_string" "naming" {
    special = false
    upper   = false
    length  = 6
}
