module "managed_file_events" {
  source = "../../modules/aws-managed-file-events"

  prefix                = var.prefix
  region                = var.region
  aws_account_id        = var.aws_account_id
  databricks_account_id = var.databricks_account_id
  tags                  = var.tags
}
