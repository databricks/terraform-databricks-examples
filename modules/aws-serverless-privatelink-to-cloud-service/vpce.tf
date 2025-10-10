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
  count = length(var.private_subnet_ids)

  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "subnet-id"
    values = [var.private_subnet_ids[count.index]]
  }

  filter {
    name   = "description"
    values = ["VPC Endpoint Interface ${aws_vpc_endpoint.aws_service.id}"]
  }
}
