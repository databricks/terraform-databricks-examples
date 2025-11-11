# Hub Networking Module Locals

locals {
  # Transit Gateway configuration
  transit_gateway_name = "${var.prefix}-transit-gateway"
  
  # Hub VPC subnet CIDRs
  hub_public_subnet_cidr   = cidrsubnet(var.hub_vpc_cidr, 8, 1)
  hub_private_subnet_cidr  = cidrsubnet(var.hub_vpc_cidr, 8, 10)
  hub_firewall_subnet_cidr = cidrsubnet(var.hub_vpc_cidr, 8, 20)
  
  # Current region (for firewall rules)
  current_region = var.region
}

