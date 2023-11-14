module "workspace" {
  source = "../../common_modules_account/workspace_creation"

  databricks_account_id  = var.databricks_account_id
  region                 = var.region
  resource_prefix        = var.resource_prefix
  cross_account_role_arn = var.cross_account_role_arn
  bucket_name            = var.bucket_name
  vpc_id                 = var.vpc_id
  subnet_ids             = var.subnet_ids
  security_group_ids     = var.security_group_ids

}

module "metastore_assignment" {
  source = "../../common_modules_account/metastore_assignment"

  metastore_id = var.metastore_id
  workspace_id = module.workspace.workspace_id

  depends_on = [module.workspace]

}

module "identity_assignment" {
  source = "../../common_modules_account/identity_assignment"

  workspace_id = module.workspace.workspace_id
  user_name    = var.user_name

  depends_on = [module.metastore_assignment]

}