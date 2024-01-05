resource "aws_vpc" "spoke_vpc" {
  cidr_block           = var.spoke_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(var.tags, {
    Name = "${local.prefix}-spoke-vpc"
  })
}

resource "aws_subnet" "spoke_db_private_subnet" {
  vpc_id                  = aws_vpc.spoke_vpc.id
  count                   = length(local.spoke_db_private_subnets_cidr)
  cidr_block              = element(local.spoke_db_private_subnets_cidr, count.index)
  availability_zone       = element(local.availability_zones, count.index)
  map_public_ip_on_launch = false
  tags = merge(var.tags, {
    Name = "${local.prefix}-spoke-db-private-${element(local.availability_zones, count.index)}"
  })
}

resource "aws_subnet" "spoke_tgw_private_subnet" {
  vpc_id                  = aws_vpc.spoke_vpc.id
  count                   = length(local.spoke_tgw_private_subnets_cidr)
  cidr_block              = element(local.spoke_tgw_private_subnets_cidr, count.index)
  availability_zone       = element(local.availability_zones, count.index)
  map_public_ip_on_launch = false
  tags = merge(var.tags, {
    Name = "${local.prefix}-spoke-tgw-private-${element(local.availability_zones, count.index)}"
  })
}

resource "aws_route_table" "spoke_db_private_rt" {
  vpc_id = aws_vpc.spoke_vpc.id
  tags = merge(var.tags, {
    Name = "${local.prefix}-spoke-db-private-rt"
  })
}

resource "aws_main_route_table_association" "spoke-set-worker-default-rt-assoc" {
  vpc_id         = aws_vpc.spoke_vpc.id
  route_table_id = aws_route_table.spoke_db_private_rt.id
}

resource "aws_route_table_association" "spoke_db_private_rta" {
  count          = length(local.spoke_db_private_subnets_cidr)
  subnet_id      = element(aws_subnet.spoke_db_private_subnet.*.id, count.index)
  route_table_id = aws_route_table.spoke_db_private_rt.id
}

resource "aws_security_group" "default_spoke_sg" {
  name        = "${local.prefix}-default_spoke_sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.spoke_vpc.id
  depends_on  = [aws_vpc.spoke_vpc]

  dynamic "ingress" {
    for_each = local.sg_ingress_protocol
    content {
      from_port = 0
      to_port   = 65535
      protocol  = ingress.value
      self      = true
    }
  }

  dynamic "egress" {
    for_each = local.sg_egress_protocol
    content {
      from_port = 0
      to_port   = 65535
      protocol  = egress.value
      self      = true
    }
  }

  dynamic "egress" {
    for_each = local.sg_ports
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = var.tags
}