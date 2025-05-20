# Define the environments we want to create
locals {
  environments = {
    env1 = {
      config_file_path = "${path.module}/configs/config-1.yaml"
    }
    /*
    env2 = {
      config_file_path = "${path.module}/configs/config-2.yaml"
    }
    */
    # You can add more environments here if needed
  }

  # Parse each config file once and store the results
  config_files = {
    for env_key, env in local.environments : env_key => yamldecode(file(env.config_file_path))
  }
}

# Single module block that creates multiple workspaces
module "multiple_workspaces" {
  for_each = local.environments

  providers = {
    aws            = aws
    databricks.mws = databricks.mws
    time           = time
  }

  source                = "./databricks_account_tf_pipeline"
  aws_account_id        = var.aws_account_id
  databricks_account_id = var.databricks_account_id
  region                = var.region
  client_id             = var.client_id
  client_secret         = var.client_secret

  # Use the values extracted from the YAML for this environment
  vpc_name         = local.config_files[each.key].vpc.name
  vpc_cidr         = local.config_files[each.key].vpc.cidr
  workspace_number = local.config_files[each.key].workspace_number
  number_of_azs    = local.config_files[each.key].subnets.number_of_azs

  private_subnets      = [for subnet in local.config_files[each.key].subnets.private : subnet.cidr]
  private_subnet_names = [for subnet in local.config_files[each.key].subnets.private : subnet.name]
  public_subnets       = [for subnet in local.config_files[each.key].subnets.public : subnet.cidr]
  public_subnet_names  = [for subnet in local.config_files[each.key].subnets.public : subnet.name]
  intra_subnets        = [for subnet in local.config_files[each.key].subnets.intra : subnet.cidr]
  intra_subnet_names   = [for subnet in local.config_files[each.key].subnets.intra : subnet.name]

  scc_relay = local.config_files[each.key].scc_relay
  workspace = local.config_files[each.key].workspace

  resource_prefix            = local.config_files[each.key].resource_prefix
  deploy_metastore           = local.config_files[each.key].deploy_metastore
  existing_metastore_id      = lookup(local.config_files[each.key], "existing_metastore_id", null)
  metastore_admin_group_name = lookup(local.config_files[each.key], "metastore_admin_group_name", null)
  deploy_log_delivery        = lookup(local.config_files[each.key], "deploy_log_delivery", false)
  tags                       = local.config_files[each.key].tags
}
