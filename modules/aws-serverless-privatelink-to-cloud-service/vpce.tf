# Data query to validate that the VPC exists,
# and so we can retrieve the VPC's CIDR block.
data "aws_vpc" "this" {
  id = var.vpc_id
}

resource "aws_vpc_endpoint" "aws_service" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.${var.aws_service}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = [aws_security_group.this.id]
  private_dns_enabled = true
}

# Data source to fetch the private IPs of the ENIs created by the VPCE
data "aws_network_interface" "aws_service" {
  for_each = toset(aws_vpc_endpoint.aws_service.network_interface_ids)
  id       = each.key
}