# Private link documentation:
# https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/aws-private-link-workspace

resource "aws_subnet" "privatelink" {
  count                   = length(local.spoke_pl_private_subnets_cidr)
  vpc_id                  = aws_vpc.spoke_vpc.id
  cidr_block              = local.spoke_pl_private_subnets_cidr[count.index]
  availability_zone       = element(local.availability_zones, count.index)
  map_public_ip_on_launch = false // explicit private subnet

  tags = merge(var.tags, {
    Name = "${local.prefix}-spoke-pl-vpce-subnet"
  })
}

resource "aws_route_table" "pl_subnet_rt" {
  vpc_id = aws_vpc.spoke_vpc.id
  count  = length(aws_subnet.privatelink) > 0 ? 1 : 0

  tags = merge(var.tags, {
    Name = "${local.prefix}-pl-spoke-route-tbl"
  })
}

resource "aws_route_table_association" "dataplane_vpce_rtb" {
  count          = length(aws_route_table.pl_subnet_rt)
  subnet_id      = aws_subnet.privatelink[count.index].id
  route_table_id = aws_route_table.pl_subnet_rt[count.index].id
}

resource "aws_security_group" "privatelink" {
  count  = length(aws_route_table.pl_subnet_rt)
  vpc_id = aws_vpc.spoke_vpc.id

  dynamic "ingress" {
    for_each = local.sg_private_link_ports
    content {
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = local.sg_private_link_protocol
      security_groups = [aws_security_group.default_spoke_sg.id]
    }
  }

  dynamic "egress" {
    for_each = local.sg_private_link_ports
    content {
      from_port       = egress.value
      to_port         = egress.value
      protocol        = local.sg_private_link_protocol
      security_groups = [aws_security_group.default_spoke_sg.id]
    }
  }

  tags = merge(var.tags, {
    Name = "${local.prefix}-privatelink-sg"
  })
}

resource "aws_vpc_endpoint" "backend_rest" {
  count               = length(aws_route_table.pl_subnet_rt)
  vpc_id              = aws_vpc.spoke_vpc.id
  service_name        = local.vpc_endpoint_backend_rest
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.privatelink[count.index].id]
  subnet_ids          = aws_subnet.privatelink[*].id
  private_dns_enabled = true // try to directly set this to true in the first apply

  tags = merge(var.tags, {
    Name = "${local.prefix}-databricks-backend-rest"
  })
}

resource "aws_vpc_endpoint" "backend_relay" {
  count               = length(aws_route_table.pl_subnet_rt)
  vpc_id              = aws_vpc.spoke_vpc.id
  service_name        = local.vpc_endpoint_backend_relay
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.privatelink[count.index].id]
  subnet_ids          = aws_subnet.privatelink[*].id
  private_dns_enabled = true

  tags = merge(var.tags, {
    Name = "${local.prefix}-databricks-backend-relay"
  })
}

resource "databricks_mws_vpc_endpoint" "backend_rest_vpce" {
  count               = length(aws_vpc_endpoint.backend_rest)
  account_id          = var.databricks_account_id
  aws_vpc_endpoint_id = aws_vpc_endpoint.backend_rest[count.index].id
  vpc_endpoint_name   = "${local.prefix}-vpc-spoke-backend"
  region              = var.region
}

resource "databricks_mws_vpc_endpoint" "relay_vpce" {
  count               = length(aws_vpc_endpoint.backend_relay)
  account_id          = var.databricks_account_id
  aws_vpc_endpoint_id = aws_vpc_endpoint.backend_relay[count.index].id
  vpc_endpoint_name   = "${local.prefix}-vpc-spoke-relay"
  region              = var.region
}

resource "databricks_mws_private_access_settings" "pla" {
  account_id                   = var.databricks_account_id
  private_access_settings_name = "Private Access Settings for ${local.prefix}"
  region                       = var.region
  public_access_enabled        = true # no private link for the web ui
}