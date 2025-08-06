# AWS VPC Endpoints
resource "aws_vpc_endpoint" "backend_rest" {
  vpc_id              = var.vpc_id
  service_name        = var.workspace_vpce_service
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [var.privatelink_security_group_id]
  subnet_ids          = var.privatelink_subnet_ids
  private_dns_enabled = true

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-databricks-backend-rest"
  })
}

resource "aws_vpc_endpoint" "backend_relay" {
  vpc_id              = var.vpc_id
  service_name        = var.relay_vpce_service
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [var.privatelink_security_group_id]
  subnet_ids          = var.privatelink_subnet_ids
  private_dns_enabled = true

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-databricks-backend-relay"
  })
}

# Databricks VPC Endpoints
resource "databricks_mws_vpc_endpoint" "backend_rest_vpce" {
  provider            = databricks.mws
  account_id          = var.databricks_account_id
  aws_vpc_endpoint_id = aws_vpc_endpoint.backend_rest.id
  vpc_endpoint_name   = "${var.resource_prefix}-vpc-backend-${var.vpc_id}"
  region              = var.region
  depends_on          = [aws_vpc_endpoint.backend_rest]
}

resource "databricks_mws_vpc_endpoint" "relay" {
  provider            = databricks.mws
  account_id          = var.databricks_account_id
  aws_vpc_endpoint_id = aws_vpc_endpoint.backend_relay.id
  vpc_endpoint_name   = "${var.resource_prefix}-vpc-relay-${var.vpc_id}"
  region              = var.region
  depends_on          = [aws_vpc_endpoint.backend_relay]
}