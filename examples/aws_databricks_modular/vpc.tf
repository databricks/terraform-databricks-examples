data "aws_availability_zones" "available" {}

resource "aws_vpc" "mainvpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "${local.prefix}-vpc"
  })
}

# Public subnets and its peripherals
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnets_cidr)
  vpc_id                  = aws_vpc.mainvpc.id
  cidr_block              = var.public_subnets_cidr[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
}

# Nat gateway EIP
resource "aws_eip" "nat_gateway_elastic_ips" {
  count = length(var.public_subnets_cidr)
  vpc   = true
}

# Nat gateway
resource "aws_nat_gateway" "nat_gateways" {
  count         = length(var.public_subnets_cidr)
  allocation_id = aws_eip.nat_gateway_elastic_ips[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id
}

// Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.mainvpc.id
}

# Public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.mainvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Public route table association
resource "aws_route_table_association" "public_route_table_associations" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "test_sg" {
  name        = "default-security-group-${local.prefix}"
  description = "Default security group for ${local.prefix}"
  vpc_id      = aws_vpc.mainvpc.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = -1
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
