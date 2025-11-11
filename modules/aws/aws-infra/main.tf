# AWS Infrastructure Module
# This module provides comprehensive AWS infrastructure for Databricks workloads
# All .tf files in this directory are automatically loaded by Terraform

# Core Components (Always Created):
# - networking.tf        - VPC, Subnets, Security Groups, NAT Gateway
# - workspacestorage.tf  - Root S3 Bucket for Databricks workspace
# - ucstorage.tf         - Unity Catalog S3 Buckets (metastore & data)
# - iam.tf               - IAM Roles (cross-account, Unity Catalog, instance profiles)
# - vpc-endpoints.tf     - VPC Endpoints (S3, STS, Kinesis)

# Conditional Components (Created based on variables):
# - private-link.tf      - Databricks Private Link (when enable_private_link = true)

# Submodules:
# - modules/hub-networking - Transit Gateway, Hub VPC, and Network Firewall (when hub_spoke_architecture = true)

# Configuration:
# - variables.tf         - Input variables
# - locals.tf            - Local values and computed configurations
# - outputs.tf           - Module outputs
# - versions.tf          - Provider version requirements

# Hub Networking Module (Transit Gateway + Firewall)
module "hub_networking" {
  count  = var.advanced_networking.hub_spoke_architecture ? 1 : 0
  source = "./modules/hub-networking"
  
  prefix = var.prefix
  region = var.region
  
  common_tags = local.common_tags
  
  # Spoke VPC configuration
  spoke_vpc_id              = module.vpc.vpc_id
  spoke_vpc_cidr            = var.networking.vpc_cidr
  spoke_private_subnet_ids  = module.vpc.private_subnets
  spoke_route_table_ids     = module.vpc.private_route_table_ids
  
  # Hub VPC configuration
  hub_vpc_cidr       = var.advanced_networking.hub_vpc_cidr
  availability_zones = local.availability_zones
  
  # Network Firewall configuration
  enable_firewall        = local.enable_firewall
  allowed_fqdns          = var.security.allowed_fqdns
  allowed_network_rules  = var.security.allowed_network_rules
}
