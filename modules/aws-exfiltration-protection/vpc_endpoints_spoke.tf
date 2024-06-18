module "vpc_endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id             = aws_vpc.spoke_vpc.id
  security_group_ids = [aws_security_group.default_spoke_sg.id]

  endpoints = {
    s3 = {
      service      = "s3"
      service_type = "Gateway"
      route_table_ids = flatten([
        aws_route_table.spoke_db_private_rt.id
      ])
      tags = {
        Name = "${local.prefix}-s3-vpc-endpoint"
      }
    },
    sts = {
      service             = "sts"
      private_dns_enabled = true
      subnet_ids          = aws_subnet.spoke_db_private_subnet[*].id
      tags = {
        Name = "${local.prefix}-sts-vpc-endpoint"
      }
    },
    kinesis-streams = {
      service             = "kinesis-streams"
      private_dns_enabled = true
      subnet_ids          = aws_subnet.spoke_db_private_subnet[*].id
      tags = {
        Name = "${local.prefix}-kinesis-vpc-endpoint"
      }
    },

  }

  tags = var.tags
}