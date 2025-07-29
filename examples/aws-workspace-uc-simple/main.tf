module "aws_base" {
  providers = {
    databricks.mws = databricks.mws
  }
  source                = "../../modules/aws-databricks-base-infra"
  prefix                = local.prefix
  region                = var.region
  databricks_account_id = var.databricks_account_id
  cidr_block            = var.cidr_block
  tags                  = local.tags
  roles_to_assume       = [local.aws_access_services_role_arn]
}

module "databricks_workspace" {
  providers = {
    databricks = databricks.mws
  }
  source                 = "../../modules/aws-databricks-workspace"
  prefix                 = local.prefix
  workspace_name         = var.workspace_name
  region                 = var.region
  databricks_account_id  = var.databricks_account_id
  security_group_ids     = module.aws_base.security_group_ids
  vpc_private_subnets    = module.aws_base.subnets
  vpc_id                 = module.aws_base.vpc_id
  root_storage_bucket    = module.aws_base.root_bucket
  cross_account_role_arn = module.aws_base.cross_account_role_arn
  tags                   = local.tags

  depends_on = [
    module.aws_base
  ]

}

module "unity_catalog" {
  source = "../../modules/aws-databricks-unity-catalog"
  providers = {
    databricks = databricks.mws
  }
  prefix                   = local.prefix
  region                   = var.region
  databricks_account_id    = var.databricks_account_id
  aws_account_id           = local.aws_account_id
  unity_metastore_owner    = databricks_group.admin_group.display_name
  databricks_workspace_ids = [module.databricks_workspace.databricks_workspace_id]
  tags                     = local.tags
}
