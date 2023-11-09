resource "aws_subnet" "db_nat_public_subnet" {
  vpc_id                  = aws_vpc.db_vpc.id
  count                   = length(local.nat_public_subnets_cidr)
  cidr_block              = element(local.nat_public_subnets_cidr, count.index)
  availability_zone       = element(local.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags = merge(var.tags, {
    Name = "${local.prefix}-db-nat-public-${element(local.availability_zones, count.index)}"
  })
}

resource "aws_internet_gateway" "db_igw" {
  vpc_id = aws_vpc.db_vpc.id
  tags = merge(var.tags, {
    Name = "${local.prefix}-db-igw"
  })
}

resource "aws_eip" "db_nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.db_igw]
}

resource "aws_nat_gateway" "db_nat" {
  allocation_id = aws_eip.db_nat_eip.id
  subnet_id     = element(aws_subnet.db_nat_public_subnet.*.id, 0)
  depends_on    = [aws_internet_gateway.db_igw]
  tags = merge(var.tags, {
    Name = "${local.prefix}-db-nat"
  })
}

