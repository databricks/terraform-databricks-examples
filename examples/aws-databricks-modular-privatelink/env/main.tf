terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "databricks" {
  alias      = "mws"
  host       = "https://accounts.cloud.databricks.com"
  client_id  = var.databricks_account_client_id
  client_secret = var.databricks_account_client_secret
}

resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

locals {
  prefix              = "adi-aws-resources"
  sg_egress_ports     = [443, 3306, 6666]
  sg_ingress_protocol = ["tcp", "udp"]
  sg_egress_protocol  = ["tcp", "udp"]
  workspace_confs = {
    workspace_1 = var.workspace_1_config
    workspace_2 = var.workspace_2_config
  }
}

# AWS IAM Module
module "aws_iam" {
  source = "../modules/aws/iam"
  
  providers = {
    databricks.mws = databricks.mws
  }
  
  databricks_account_id = var.databricks_account_id
  resource_prefix       = local.prefix
  tags                  = var.tags
}

# AWS Network Module
module "aws_network" {
  source = "../modules/aws/network"
  
  resource_prefix           = local.prefix
  vpc_cidr                  = var.vpc_cidr
  public_subnets_cidr       = var.public_subnets_cidr
  privatelink_subnets_cidr  = var.privatelink_subnets_cidr
  tags                      = var.tags
}

# AWS Security Module
module "aws_security" {
  source = "../modules/aws/security"
  
  resource_prefix         = local.prefix
  vpc_id                  = module.aws_network.vpc_id
  sg_ingress_protocol     = local.sg_ingress_protocol
  sg_egress_protocol      = local.sg_egress_protocol
  sg_egress_ports         = local.sg_egress_ports
  cross_account_role_arn  = module.aws_iam.cross_account_role_arn
  cmk_admin               = var.cmk_admin
  region                  = var.region
  tags                    = var.tags
}

# AWS Data Module
module "aws_data" {
  source = "../modules/aws/data"
  
  resource_prefix    = local.prefix
  data_bucket_name   = "data-bucket-for-test"
  tags               = var.tags
}


# Databricks Networking Module
module "databricks_networking" {
  source = "../modules/databricks/networking"
  
  providers = {
    databricks.mws = databricks.mws
  }
  
  resource_prefix                = local.prefix
  vpc_id                         = module.aws_network.vpc_id
  privatelink_subnet_ids         = module.aws_network.privatelink_subnet_ids
  privatelink_security_group_id  = module.aws_security.privatelink_security_group_id
  workspace_vpce_service         = var.workspace_vpce_service
  relay_vpce_service             = var.relay_vpce_service
  databricks_account_id          = var.databricks_account_id
  region                         = var.region
  tags                           = var.tags
}

# Workspace Collection Module (existing)
module "workspace_collection" {
  for_each = local.workspace_confs

  providers = {
    databricks = databricks.mws
    aws        = aws
  }

  source                = "../modules/mws_workspace"
  databricks_account_id = var.databricks_account_id
  credentials_id        = module.aws_iam.credentials_id
  prefix                = each.value.prefix
  region                = each.value.region
  workspace_name        = each.value.workspace_name
  tags                  = each.value.tags
  existing_vpc_id       = module.aws_network.vpc_id
  nat_gateways_id       = module.aws_network.nat_gateway_ids[0]
  security_group_ids    = [module.aws_security.databricks_security_group_id]
  private_subnet_pair   = [each.value.private_subnet_pair.subnet1_cidr, each.value.private_subnet_pair.subnet2_cidr]
  workspace_storage_cmk = module.aws_security.workspace_storage_cmk
  managed_services_cmk  = module.aws_security.managed_services_cmk
  root_bucket_name      = each.value.root_bucket_name
  relay_vpce_id         = [module.databricks_networking.relay_vpce_id]
  rest_vpce_id          = [module.databricks_networking.backend_rest_vpce_id]
  depends_on = [
    module.databricks_networking
  ]
}

data "http" "my" {
  url = "https://ifconfig.me"
}

# Save deployment info to local file for future configuration
resource "local_file" "deployment_information" {
  for_each = local.workspace_confs

  content = jsonencode({
    "prefix"        = "${local.workspace_confs[each.key].prefix}-${local.prefix}"
    "workspace_url" = module.workspace_collection[each.key].workspace_url
    "block_list"    = "${local.workspace_confs[each.key].block_list}"
    "allow_list"    = "${concat(local.workspace_confs[each.key].allow_list, ["${data.http.my.body}/32"])}"
  })
  filename = "../artifacts/${each.key}.json"
}