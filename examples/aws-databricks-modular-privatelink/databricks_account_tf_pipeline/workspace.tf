resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

locals {
  prefix = "demo-${random_string.naming.result}"
}

# aws_network module creates the VPC, subnets, and security groups
module "aws_network" {
  providers = {
    aws = aws
  }
  source               = "./modules/aws_network"
  region               = var.region
  vpc_name             = var.vpc_name
  vpc_cidr             = var.vpc_cidr
  workspace_number     = var.workspace_number
  number_of_azs        = var.number_of_azs
  private_subnets      = var.private_subnets
  private_subnet_names = var.private_subnet_names
  public_subnets       = var.public_subnets
  public_subnet_names  = var.public_subnet_names
  intra_subnets        = var.intra_subnets
  intra_subnet_names   = var.intra_subnet_names
  resource_prefix      = var.resource_prefix
  sg_egress_ports      = var.sg_egress_ports
  scc_relay            = var.scc_relay
  workspace            = var.workspace
}

module "workspace_credential" {
  count = var.workspace_number

  providers = {
    aws        = aws
    databricks = databricks.mws
    time       = time
  }

  source                = "./modules/workspace_credential"
  region                = var.region
  aws_account_id        = var.aws_account_id
  databricks_account_id = var.databricks_account_id
  resource_prefix       = "${local.prefix}-${count.index}"
  vpc_id                = module.aws_network.vpc_id
  security_group_id     = module.aws_network.workspace_security_group_ids[count.index]
}

module "workspace_root_storage" {
  count = var.workspace_number

  providers = {
    aws        = aws
    databricks = databricks.mws
  }

  source                = "./modules/workspace_root_storage"
  resource_prefix       = "${local.prefix}-${count.index}"
  databricks_account_id = var.databricks_account_id
}

# Backend REST VPC Endpoint Configuration
resource "databricks_mws_vpc_endpoint" "backend_rest" {
  provider            = databricks.mws
  account_id          = var.databricks_account_id
  aws_vpc_endpoint_id = module.aws_network.workspace_endpoint_id
  vpc_endpoint_name   = "${var.resource_prefix}-vpce-backend"
  region              = var.region
}

# Backend Rest VPC Endpoint Configuration
resource "databricks_mws_vpc_endpoint" "backend_relay" {
  provider            = databricks.mws
  account_id          = var.databricks_account_id
  aws_vpc_endpoint_id = module.aws_network.scc_relay_endpoint_id
  vpc_endpoint_name   = "${var.resource_prefix}-vpce-relay"
  region              = var.region
}

// Private Access Setting Configuration, shared by multiple workspaces (or you can build multiple PAS for multiple workspaces)
resource "databricks_mws_private_access_settings" "pas" {
  provider                     = databricks.mws
  private_access_settings_name = "${var.resource_prefix}-PAS"
  region                       = var.region
  public_access_enabled        = true
  private_access_level         = "ACCOUNT"
}

module "workspace_network" {
  count = var.workspace_number

  providers = {
    aws        = aws
    databricks = databricks.mws
  }

  source                = "./modules/workspace_network"
  resource_prefix       = "${local.prefix}-${count.index}"
  databricks_account_id = var.databricks_account_id
  region                = var.region
  vpc_id                = module.aws_network.vpc_id
  security_group_id     = module.aws_network.workspace_security_group_ids[count.index]
  private_subnet_ids = [
    module.aws_network.private_subnets[count.index * 2],
    module.aws_network.private_subnets[count.index * 2 + 1]
  ] # each workspace will have 2 private subnets
  workspace_endpoint_id = databricks_mws_vpc_endpoint.backend_rest.vpc_endpoint_id
  scc_relay_endpoint_id = databricks_mws_vpc_endpoint.backend_relay.vpc_endpoint_id
}

# Create workspaces
resource "databricks_mws_workspaces" "workspaces_collection" {
  count                                    = var.workspace_number
  provider                                 = databricks.mws
  account_id                               = var.databricks_account_id
  aws_region                               = var.region
  workspace_name                           = "${local.prefix}-${count.index}"
  credentials_id                           = module.workspace_credential[count.index].storage_credential_id
  storage_configuration_id                 = module.workspace_root_storage[count.index].storage_configuration_id
  network_id                               = module.workspace_network[count.index].network_id
  private_access_settings_id               = databricks_mws_private_access_settings.pas.private_access_settings_id
  managed_services_customer_managed_key_id = databricks_mws_customer_managed_keys.managed_services.customer_managed_key_id
  storage_customer_managed_key_id          = databricks_mws_customer_managed_keys.storage.customer_managed_key_id

  token {
    comment = "Terraform"
  }
}

resource "databricks_metastore_assignment" "metastore_assignments" {
  count = var.deploy_metastore == "true" || var.existing_metastore_id != null ? var.workspace_number : 0

  provider     = databricks.mws
  workspace_id = databricks_mws_workspaces.workspaces_collection[count.index].workspace_id
  metastore_id = var.deploy_metastore == "true" ? databricks_metastore.this[0].id : var.existing_metastore_id
}

module "account_log_delivery" {
  count = var.deploy_log_delivery == "true" ? 1 : 0
  providers = {
    databricks = databricks.mws
  }
  source                = "./modules/account_log_delivery"
  resource_prefix       = var.resource_prefix
  tags                  = var.tags
  databricks_account_id = var.databricks_account_id
}
