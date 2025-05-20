terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azlookup = slice(data.aws_availability_zones.available.names, 0, var.number_of_azs)
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = var.vpc_name
  cidr   = var.vpc_cidr

  azs                  = local.azlookup
  private_subnet_names = var.private_subnet_names
  private_subnets      = var.private_subnets
  public_subnet_names  = var.public_subnet_names
  public_subnets       = var.public_subnets
  intra_subnet_names   = var.intra_subnet_names
  intra_subnets        = var.intra_subnets

  enable_dns_hostnames   = true
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true
  create_igw             = true

  tags = {
    Environment = "${var.resource_prefix}-env"
  }
}

resource "aws_security_group" "sg" {
  count      = var.workspace_number
  name       = "${var.resource_prefix}-workspace-sg-${count.index}"
  vpc_id     = module.vpc.vpc_id
  depends_on = [module.vpc]

  dynamic "ingress" {
    for_each = ["tcp", "udp"]
    content {
      description = "Databricks - Workspace SG - Internode Communication"
      from_port   = 0
      to_port     = 65535
      protocol    = ingress.value
      self        = true
    }
  }

  dynamic "egress" {
    for_each = ["tcp", "udp"]
    content {
      description = "Databricks - Workspace SG - Internode Communication"
      from_port   = 0
      to_port     = 65535
      protocol    = egress.value
      self        = true
    }
  }

  dynamic "egress" {
    for_each = var.sg_egress_ports
    content {
      description = "Databricks - Workspace SG - REST (443), Secure Cluster Connectivity (2443/6666), Future Extendability (8443-8451)"
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = {
    Name    = "${var.resource_prefix}-workspace-sg"
    Project = var.resource_prefix
  }
}


resource "aws_security_group" "privatelink" {
  vpc_id = module.vpc.vpc_id

  ingress {
    description     = "Databricks - PrivateLink Endpoint SG - REST API"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [for i, sg in aws_security_group.sg : sg.id]
  }

  ingress {
    description     = "Databricks - PrivateLink Endpoint SG - Secure Cluster Connectivity"
    from_port       = 6666
    to_port         = 6666
    protocol        = "tcp"
    security_groups = [for i, sg in aws_security_group.sg : sg.id]
  }

  ingress {
    description     = "Databricks - PrivateLink Endpoint SG - Secure Cluster Connectivity - Compliance Security Profile"
    from_port       = 2443
    to_port         = 2443
    protocol        = "tcp"
    security_groups = [for i, sg in aws_security_group.sg : sg.id]
  }

  ingress {
    description     = "Databricks - PrivateLink Endpoint SG - Future Extendability"
    from_port       = 8443
    to_port         = 8451
    protocol        = "tcp"
    security_groups = [for i, sg in aws_security_group.sg : sg.id]
  }

  tags = {
    Name    = "${var.resource_prefix}-private-link-sg",
    Project = var.resource_prefix
  }
  depends_on = [aws_security_group.sg]
}

module "vpc_endpoints" {
  source             = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  vpc_id             = module.vpc.vpc_id
  security_group_ids = [aws_security_group.privatelink.id]

  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc.private_route_table_ids
      tags = {
        Name    = "${var.resource_prefix}-s3-vpc-endpoint"
        Project = var.resource_prefix
      }
    },
    sts = {
      service             = "sts"
      private_dns_enabled = true
      subnet_ids          = module.vpc.intra_subnets
      tags = {
        Name    = "${var.resource_prefix}-sts-vpc-endpoint"
        Project = var.resource_prefix
      }
    },
    kinesis-streams = {
      service             = "kinesis-streams"
      private_dns_enabled = true
      subnet_ids          = module.vpc.intra_subnets
      tags = {
        Name    = "${var.resource_prefix}-kinesis-vpc-endpoint"
        Project = var.resource_prefix
      }
    }
  }
}

# Databricks REST endpoint
resource "aws_vpc_endpoint" "backend_rest" {
  vpc_id              = module.vpc.vpc_id
  service_name        = var.workspace
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.privatelink.id]
  subnet_ids          = module.vpc.intra_subnets
  private_dns_enabled = true
  tags = {
    Name    = "${var.resource_prefix}-databricks-backend-rest"
    Project = var.resource_prefix
  }
}

# Databricks SCC endpoint
resource "aws_vpc_endpoint" "backend_relay" {
  vpc_id              = module.vpc.vpc_id
  service_name        = var.scc_relay
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.privatelink.id]
  subnet_ids          = module.vpc.intra_subnets
  private_dns_enabled = true
  tags = {
    Name    = "${var.resource_prefix}-databricks-backend-relay"
    Project = var.resource_prefix
  }
}
