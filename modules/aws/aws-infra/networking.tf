# Networking Component
# Creates VPC, subnets, security groups, NAT gateways, and routing using AWS VPC module

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.prefix}-vpc"
  cidr = var.networking.vpc_cidr

  azs             = local.availability_zones
  private_subnets = local.private_subnet_cidrs
  public_subnets  = var.networking.enable_nat_gateway ? local.public_subnet_cidrs : []

  # DNS
  enable_dns_hostnames = true
  enable_dns_support   = true

  # NAT Gateway
  enable_nat_gateway = var.networking.enable_nat_gateway
  single_nat_gateway = true

  # Tags
  tags = local.common_tags

  vpc_tags = {
    Name = "${var.prefix}-vpc"
    Type = "Main"
  }

  private_subnet_tags = {
    Type = "Private"
  }

  public_subnet_tags = {
    Type = "Public"
  }

  private_route_table_tags = {
    Type = "Private"
  }

  public_route_table_tags = {
    Type = "Public"
  }

  igw_tags = {
    Name = "${var.prefix}-igw"
  }

  nat_gateway_tags = {
    Name = "${var.prefix}-nat-gateway"
  }

  nat_eip_tags = {
    Name = "${var.prefix}-nat-eip"
  }
}

# Security Group for Databricks
resource "aws_security_group" "default" {
  name_prefix = "${var.prefix}-databricks-"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for Databricks workspace"

  # Databricks-specific egress rules for internal communication
  dynamic "egress" {
    for_each = toset([443, 2443, 6666, 5432, 8443, 8444, 8445, 8446, 8447, 8448, 8449, 8450, 8451])
    content {
      description = "Databricks - Workspace SG - REST (443), Secure Cluster Connectivity (2443/6666), Lakebase PostgreSQL (5432), Compute Plane to Control Plane Internal Calls (8443), Unity Catalog Logging and Lineage Data Streaming (8444), Future Extendability (8445-8451)"
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = [var.networking.vpc_cidr]
    }
  }

  # Outbound rules to self (required for Databricks clusters)
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
    description = "Allow all internal TCP traffic to self"
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    self        = true
    description = "Allow all internal UDP traffic to self"
  }

  # Inbound rules from self (required for internal cluster communication)
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
    description = "Allow all internal TCP traffic from self"
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    self        = true
    description = "Allow all internal UDP traffic from self"
  }
  
  tags = merge(local.common_tags, {
    Name = "${var.prefix}-databricks-sg"
    Type = "Databricks"
  })
}
