data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-vpc"
  })
}

# Public subnets collection
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnets_cidr)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets_cidr[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-${aws_vpc.main.id}-public-subnet"
  })
}

# Private subnets collection for Private Link (VPC endpoints)
resource "aws_subnet" "privatelink" {
  count                   = length(var.privatelink_subnets_cidr)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.privatelink_subnets_cidr[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-${aws_vpc.main.id}-pl-vpce-subnet"
  })
}

resource "aws_route_table" "pl_subnet_rt" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-pl-local-route-tbl"
  })
}

resource "aws_route_table_association" "dataplane_vpce_rtb" {
  count          = length(var.privatelink_subnets_cidr)
  subnet_id      = aws_subnet.privatelink[count.index].id
  route_table_id = aws_route_table.pl_subnet_rt.id
}

# Nat gateway EIP
resource "aws_eip" "nat_gateway_elastic_ips" {
  count  = length(var.public_subnets_cidr)
  domain = "vpc"
}

# Nat gateway
resource "aws_nat_gateway" "nat_gateways" {
  count         = length(var.public_subnets_cidr)
  allocation_id = aws_eip.nat_gateway_elastic_ips[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-${aws_vpc.main.id}-nat-gateway"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# Public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-public-rt"
  })
}

# Public route table association
resource "aws_route_table_association" "public_route_table_associations" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}