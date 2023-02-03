data "aws_availability_zones" "available" {}

# Private subnets
resource "aws_subnet" "private_subnets" {
  count                   = length(var.private_subnet_pair)
  vpc_id                  = var.existing_vpc_id
  cidr_block              = var.private_subnet_pair[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = var.tags
}

# Private route table
resource "aws_route_table" "private_route_tables" {
  count  = length(var.private_subnet_pair)
  vpc_id = var.existing_vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.aws_nat_gateway_id
  }
  tags = var.tags
}

# Private route table association
resource "aws_route_table_association" "private_route_table_associations" {
  count          = length(var.private_subnet_pair)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_tables[count.index].id
}

resource "databricks_mws_networks" "mwsnetwork" {
  account_id         = var.databricks_account_id
  network_name       = "${var.prefix}-network"
  vpc_id             = var.existing_vpc_id
  subnet_ids         = [aws_subnet.private_subnets.0.id, aws_subnet.private_subnets.1.id]
  security_group_ids = var.security_group_ids

  vpc_endpoints {
    dataplane_relay = var.relay_vpce_id
    rest_api        = var.rest_vpce_id
  }
}
