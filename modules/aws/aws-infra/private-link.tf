# Private Link Component
# Creates VPC endpoints for Databricks private connectivity

# Private Link Subnets (dedicated subnets for Databricks VPC endpoints)
resource "aws_subnet" "private_link" {
  count = var.security.enable_private_link ? length(local.availability_zones) : 0
  
  vpc_id            = module.vpc.vpc_id
  cidr_block        = cidrsubnet(var.networking.vpc_cidr, 8, count.index + 200)
  availability_zone = local.availability_zones[count.index]
  
  tags = merge(local.common_tags, {
    Name = "${var.prefix}-private-link-subnet-${count.index + 1}"
    Type = "PrivateLink"
    AZ   = local.availability_zones[count.index]
  })
}

# Route Table for Private Link Subnets
resource "aws_route_table" "private_link" {
  count = var.security.enable_private_link ? 1 : 0
  
  vpc_id = module.vpc.vpc_id
  
  tags = merge(local.common_tags, {
    Name = "${var.prefix}-private-link-rt"
    Type = "PrivateLink"
  })
}

# Route Table Association for Private Link Subnets
resource "aws_route_table_association" "private_link" {
  count = var.security.enable_private_link ? length(aws_subnet.private_link) : 0
  
  subnet_id      = aws_subnet.private_link[count.index].id
  route_table_id = aws_route_table.private_link[0].id
}

# Security Group for Private Link Endpoints
resource "aws_security_group" "private_link" {
  count = var.security.enable_private_link ? 1 : 0
  
  name_prefix = "${var.prefix}-private-link-"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for Databricks Private Link endpoints"
  
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.default.id]
    description     = "HTTPS from Databricks clusters"
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.networking.vpc_cidr]
    description = "HTTPS from VPC"
  }
  
  # Extended port range for Databricks communication
  ingress {
    from_port       = 6666
    to_port         = 6666
    protocol        = "tcp"
    security_groups = [aws_security_group.default.id]
    description     = "Databricks internal communication"
  }
  
  ingress {
    from_port   = 6666
    to_port     = 6666
    protocol    = "tcp"
    cidr_blocks = [var.networking.vpc_cidr]
    description = "Databricks internal communication from VPC"
  }
  
  # PostgreSQL port for Lakebase
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.default.id]
    description     = "Lakebase PostgreSQL from Databricks clusters"
  }
  
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.networking.vpc_cidr]
    description = "Lakebase PostgreSQL from VPC"
  }
  
  # Control Plane, Unity Catalog, and Future Extendability ports
  ingress {
    from_port       = 8443
    to_port         = 8451
    protocol        = "tcp"
    security_groups = [aws_security_group.default.id]
    description     = "Databricks Control Plane (8443), Unity Catalog (8444), Future Extendability (8445-8451) from clusters"
  }
  
  ingress {
    from_port   = 8443
    to_port     = 8451
    protocol    = "tcp"
    cidr_blocks = [var.networking.vpc_cidr]
    description = "Databricks Control Plane (8443), Unity Catalog (8444), Future Extendability (8445-8451) from VPC"
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }
  
  tags = merge(local.common_tags, {
    Name = "${var.prefix}-private-link-sg"
  })
}

# Databricks Backend Private Link Endpoint
resource "aws_vpc_endpoint" "backend" {
  count = var.security.enable_private_link && var.security.backend_service_name != null ? 1 : 0
  
  vpc_id              = module.vpc.vpc_id
  service_name        = var.security.backend_service_name
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private_link[*].id
  security_group_ids  = [aws_security_group.private_link[0].id]
  private_dns_enabled = false
  
  tags = merge(local.common_tags, {
    Name = "${var.prefix}-databricks-backend-endpoint"
    Type = "DatabricksPrivateLink"
  })
}

# Databricks Relay Private Link Endpoint
resource "aws_vpc_endpoint" "relay" {
  count = var.security.enable_private_link && var.security.relay_service_name != null ? 1 : 0
  
  vpc_id              = module.vpc.vpc_id
  service_name        = var.security.relay_service_name
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private_link[*].id
  security_group_ids  = [aws_security_group.private_link[0].id]
  private_dns_enabled = false
  
  tags = merge(local.common_tags, {
    Name = "${var.prefix}-databricks-relay-endpoint"
    Type = "DatabricksPrivateLink"
  })
}
