module "cloud_provider_network" {
  source = "../../common_modules_account/cloud_provider_network"

  vpc_cidr_range       = var.vpc_cidr_range
  availability_zones   = var.availability_zones
  resource_prefix      = var.resource_prefix
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  sg_ingress_protocol  = var.sg_ingress_protocol
  sg_egress_ports      = var.sg_egress_ports
  sg_egress_protocol   = var.sg_egress_protocol

}

module "cloud_provider_credential" {
  source = "../../common_modules_account/cloud_provider_credential"

  aws_account_id        = var.aws_account_id
  databricks_account_id = var.databricks_account_id
  resource_prefix       = var.resource_prefix
  region                = var.region
  vpc_id                = module.cloud_provider_network.cloud_provider_network_vpc
  security_group_ids    = module.cloud_provider_network.cloud_provider_network_security_groups

  depends_on = [ module.cloud_provider_network ]
}

module "cloud_provider_storage" {
  source = "../../common_modules_account/cloud_provider_storage"

  dbfsname = var.dbfsname
}