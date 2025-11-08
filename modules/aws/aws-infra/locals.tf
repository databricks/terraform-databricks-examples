# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  # Common tags applied to all resources
  common_tags = merge(var.tags, {
    "ManagedBy"   = "terraform"
    "Module"      = "aws-infra"
    "Prefix"      = var.prefix
    "Region"      = var.region
    "CreatedDate" = formatdate("YYYY-MM-DD", timestamp())
  })

  # Availability Zones
  availability_zones = length(var.networking.availability_zones) > 0 ? var.networking.availability_zones : slice(data.aws_availability_zones.available.names, 0, min(length(data.aws_availability_zones.available.names), 3))

  # Subnet CIDR calculations
  private_subnet_cidrs = length(var.networking.private_subnet_cidrs) > 0 ? var.networking.private_subnet_cidrs : [
    for i in range(length(local.availability_zones)) : cidrsubnet(var.networking.vpc_cidr, 8, i + 1)
  ]

  public_subnet_cidrs = length(var.networking.public_subnet_cidrs) > 0 ? var.networking.public_subnet_cidrs : [
    for i in range(length(local.availability_zones)) : cidrsubnet(var.networking.vpc_cidr, 8, i + 101)
  ]

  # Storage configuration - hardcoded bucket names
  root_bucket_name      = "${var.prefix}-rootbucket"
  metastore_bucket_name = "${var.prefix}-metastore"
  data_bucket_name      = "${var.prefix}-data"


  # IAM configuration
  iam_config = {
    cross_account_role_name = "${var.prefix}-cross-account-role"
    unity_catalog_role_name = "${var.prefix}-unity-catalog-role"

    # Databricks trust relationship principal
    databricks_principals = ["arn:aws:iam::${var.databricks_account_id}:root"]

    # Unity Catalog specific configuration
    unity_catalog_external_id = var.external_id
    unity_catalog_principal   = "arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-14S5ZJVKOTYTL"
  }

  # Enable firewall if explicitly enabled OR if hub-spoke architecture is enabled
  enable_firewall = var.security.enable_network_firewall || var.advanced_networking.hub_spoke_architecture

  # Advanced networking configuration
  transit_gateway_config = var.advanced_networking.enable_transit_gateway ? {
    name           = "${var.prefix}-transit-gateway"
    hub_vpc_cidr   = var.advanced_networking.hub_vpc_cidr
    spoke_vpc_cidr = var.networking.vpc_cidr

    # Hub VPC subnets (single subnet for each type)
    hub_public_subnet_cidr   = cidrsubnet(var.advanced_networking.hub_vpc_cidr, 8, 1)
    hub_private_subnet_cidr  = cidrsubnet(var.advanced_networking.hub_vpc_cidr, 8, 10)
    hub_firewall_subnet_cidr = cidrsubnet(var.advanced_networking.hub_vpc_cidr, 8, 20)
  } : null

  # Current account ID
  account_id = data.aws_caller_identity.current.account_id

  # Current region name
  current_region = data.aws_region.current.id
}
