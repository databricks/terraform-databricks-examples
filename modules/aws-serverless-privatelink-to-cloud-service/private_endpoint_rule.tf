# Create a PrivateLink VPC Endpoint Service backed by the NLB.
resource "aws_vpc_endpoint_service" "private_link_service" {
  # Bind the VPCE Service to the NLB's ARN
  network_load_balancer_arns = [aws_lb.this.arn]

  # This is crucial for cross-account sharing. Databricks must request a connection.
  acceptance_required = true

  # In case we provide own private DNS name:
  private_dns_name = var.private_dns_name
}

# Below we must know the Databricks AWS principal to trust.
# The following allowed principal is exactly that.
resource "aws_vpc_endpoint_service_allowed_principal" "databricks_access_rule" {
  # Databricks Serverless Principal ARN
  principal_arn = local.databricks_allowed_principal

  # The service must point to the VPCE Service we just created
  vpc_endpoint_service_id = aws_vpc_endpoint_service.private_link_service.id
}

# Lastly, create the private endpoint rule on your Databricks NCC.
# This instructs Databricks to create a VPC Endpoint to connect to your VPCE Service.
resource "databricks_mws_ncc_private_endpoint_rule" "this" {
  provider                       = databricks.mws
  network_connectivity_config_id = var.network_connectivity_config_id
  endpoint_service               = aws_vpc_endpoint_service.private_link_service.service_name
  domain_names = compact([
    "${aws_vpc_endpoint_service.private_link_service.service_name}.${var.region}.vpce.amazonaws.com",
    aws_vpc_endpoint_service.private_link_service.private_dns_name
  ])
}
