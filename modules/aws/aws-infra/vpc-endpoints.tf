# VPC Endpoints Component
# Creates VPC endpoints for secure private access to AWS services using AWS VPC Endpoints module

module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.0"

  vpc_id = module.vpc.vpc_id

  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = concat(
        module.vpc.private_route_table_ids,
        var.networking.enable_nat_gateway ? module.vpc.public_route_table_ids : []
      )
      tags = {
        Name = "${var.prefix}-s3-vpc-endpoint"
        Type = "Gateway"
      }
    }

    sts = {
      service             = "sts"
      service_type        = "Interface"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags = {
        Name = "${var.prefix}-sts-vpc-endpoint"
        Type = "Interface"
      }
    }

    kinesis-streams = {
      service             = "kinesis-streams"
      service_type        = "Interface"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags = {
        Name = "${var.prefix}-kinesis-streams-vpc-endpoint"
        Type = "Interface"
      }
    }
  }

  tags = local.common_tags
}
