resource "aws_vpc" "db_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(var.tags, {
    Name = "${local.prefix}-db-vpc"
  })
}

resource "aws_subnet" "db_private_subnet" {
  vpc_id                  = aws_vpc.db_vpc.id
  count                   = length(local.private_subnets_cidr)
  cidr_block              = element(local.private_subnets_cidr, count.index)
  availability_zone       = element(local.availability_zones, count.index)
  map_public_ip_on_launch = false
  tags = merge(var.tags, {
    Name = "${local.prefix}-db-private-${element(local.availability_zones, count.index)}"
  })
}