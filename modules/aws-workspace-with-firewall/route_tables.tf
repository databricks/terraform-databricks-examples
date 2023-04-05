resource "aws_route_table" "db_private_rt" {
  vpc_id = aws_vpc.db_vpc.id
  tags = merge(var.tags, {
    Name = "${local.prefix}-db-private-rt"
  })
}

resource "aws_route_table" "db_nat_public_rt" {
  vpc_id = aws_vpc.db_vpc.id
  tags = merge(var.tags, {
    Name = "${local.prefix}-db-nat-rt"
  })
}

resource "aws_route_table" "db_firewall_rt" {
  vpc_id = aws_vpc.db_vpc.id
  tags = merge(var.tags, {
    Name = "${local.prefix}-db-firewall-rt"
  })
}

resource "aws_route_table" "db_igw_rt" {
  vpc_id = aws_vpc.db_vpc.id
  tags = merge(var.tags, {
    Name = "${local.prefix}-db-igw-rt"
  })
}

resource "aws_route_table_association" "db_private" {
  count          = length(local.private_subnets_cidr)
  subnet_id      = element(aws_subnet.db_private_subnet.*.id, count.index)
  route_table_id = aws_route_table.db_private_rt.id
}

resource "aws_route_table_association" "db_nat" {
  count          = length(local.nat_public_subnets_cidr)
  subnet_id      = element(aws_subnet.db_nat_public_subnet.*.id, count.index)
  route_table_id = aws_route_table.db_nat_public_rt.id
}

resource "aws_route_table_association" "db_firewall" {
  count          = length(local.firewall_public_subnets_cidr)
  subnet_id      = element(aws_subnet.db_firewall_subnet.*.id, count.index)
  route_table_id = aws_route_table.db_firewall_rt.id
}

resource "aws_route_table_association" "db_igw" {
  gateway_id     = aws_internet_gateway.db_igw.id
  route_table_id = aws_route_table.db_igw_rt.id
}

resource "aws_route" "db_private_nat_gtw" {
  route_table_id         = aws_route_table.db_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.db_nat.id
}

resource "aws_route" "db_firewall_gtw" {
  route_table_id         = aws_route_table.db_firewall_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.db_igw.id
}

resource "aws_main_route_table_association" "set-worker-default-rt-assoc" {
  vpc_id         = aws_vpc.db_vpc.id
  route_table_id = aws_route_table.db_firewall_rt.id
}

resource "aws_route" "db_nat_firewall" {
  route_table_id         = aws_route_table.db_nat_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = data.aws_vpc_endpoint.firewall.id
}

resource "aws_route" "db_igw_nat_firewall" {
  route_table_id         = aws_route_table.db_igw_rt.id
  count                  = length(local.nat_public_subnets_cidr)
  destination_cidr_block = element(local.nat_public_subnets_cidr, count.index)
  vpc_endpoint_id        = data.aws_vpc_endpoint.firewall.id
}