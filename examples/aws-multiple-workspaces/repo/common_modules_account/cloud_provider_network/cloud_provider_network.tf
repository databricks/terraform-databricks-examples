// EXPLANATION: Create the customer managed-vpc and security group rules

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name = "${var.resource_prefix}-data-plane-VPC"
  cidr = var.vpc_cidr_range
  azs  = var.availability_zones

  enable_dns_hostnames   = true
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true
  create_igw             = true

  public_subnet_names = [for az in var.availability_zones : format("%s-public-%s", var.resource_prefix, az)]
  public_subnets      = var.public_subnets_cidr

  private_subnet_names = [for az in var.availability_zones : format("%s-private-%s", var.resource_prefix, az)]
  private_subnets      = var.private_subnets_cidr
}

// SG
resource "aws_security_group" "sg" {
  vpc_id     = module.vpc.vpc_id
  depends_on = [module.vpc]

  dynamic "ingress" {
    for_each = var.sg_ingress_protocol
    content {
      from_port = 0
      to_port   = 65535
      protocol  = ingress.value
      self      = true
    }
  }

  dynamic "egress" {
    for_each = var.sg_egress_protocol
    content {
      from_port = 0
      to_port   = 65535
      protocol  = egress.value
      self      = true
    }
  }

  dynamic "egress" {
    for_each = var.sg_egress_ports
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  tags = {
    Name = "${var.resource_prefix}-data-plane-sg"
  }
}

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "3.11.0"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [aws_security_group.sg.id]

  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc.private_route_table_ids
      tags = {
        Name = "${var.resource_prefix}-s3-vpc-endpoint"
      }
    },
    sts = {
      service             = "sts"
      private_dns_enabled = true
      subnet_ids          = length(module.vpc.private_subnets) > 0 ? slice(module.vpc.private_subnets, 0, min(2, length(module.vpc.private_subnets))) : []
      tags = {
        Name = "${var.resource_prefix}-sts-vpc-endpoint"
      }
    },
    kinesis-streams = {
      service             = "kinesis-streams"
      private_dns_enabled = true
      subnet_ids          = length(module.vpc.private_subnets) > 0 ? slice(module.vpc.private_subnets, 0, min(2, length(module.vpc.private_subnets))) : []
      tags = {
        Name = "${var.resource_prefix}-kinesis-vpc-endpoint"
      }
    }
  }
  depends_on = [
    module.vpc
  ]
}