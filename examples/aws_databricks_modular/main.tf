resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6

}

locals {
  prefix           = "demo${random_string.naming.result}"
  root_bucket_name = "${random_string.naming.result}-rootbucket"
  workspace_confs = { //add more workspaces here, remove from here to delete specific workspace
    workspace_1 = var.workspace_1_config
    workspace_2 = var.workspace_2_config
  }
}

module "databricks_cmk" {
  source                 = "./modules/databricks_cmk"
  cross_account_role_arn = aws_iam_role.cross_account_role.arn
  resource_prefix        = local.prefix
  region                 = var.region
  cmk_admin              = var.cmk_admin
}

module "workspace_collection" {
  for_each = local.workspace_confs

  providers = {
    databricks = databricks.mws
    aws        = aws
  }

  source                = "./modules/mws_workspace"
  databricks_account_id = var.databricks_account_id
  credentials_id        = databricks_mws_credentials.this.credentials_id
  prefix                = "${each.value.prefix}-${local.prefix}"
  region                = each.value.region
  workspace_name        = each.value.workspace_name
  existing_vpc_id       = aws_vpc.mainvpc.id
  nat_gateways_id       = aws_nat_gateway.nat_gateways[0].id
  security_group_ids    = [aws_security_group.test_sg.id]
  private_subnet_pair   = [each.value.private_subnet_pair.subnet1_cidr, each.value.private_subnet_pair.subnet2_cidr]
  workspace_storage_cmk = module.databricks_cmk.workspace_storage_cmk
  managed_services_cmk  = module.databricks_cmk.managed_services_cmk
  root_bucket_name      = each.value.root_bucket_name
}

/*
// create PAT token to provision entities within workspace
resource "databricks_token" "pat" {
  provider         = databricks.created_workspace
  comment          = "Terraform Provisioning"
  lifetime_seconds = 86400
}
*/
