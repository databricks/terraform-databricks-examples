# This security group is the firewall for the VPC Endpoint to the AWS service.
resource "aws_security_group" "this" {
  name_prefix = var.prefix
  description = "Allow inbound traffic from NLB to ${var.aws_service} VPCE"
  vpc_id      = var.vpc_id

  # Inbound rule: Allow TCP 443 (HTTPS) traffic from the NLB (source will be the NLB's own VPC CIDR or SG)
  # NOTE: Use your VPC's full CIDR block here, or ideally, the specific Security Group of the NLB nodes (if already defined).
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = length(var.allowed_ingress_cidr_blocks) == 0 ? [data.aws_vpc.this.cidr_block] : var.allowed_ingress_cidr_blocks
    security_groups = var.allowed_ingress_security_groups

    description = "Allow NLB to ${var.aws_service}"
  }

  # Outbound rule: Must allow return traffic to the NLB/compute (all outbound is fine here)
  # trivy:ignore:AVD-AWS-0104
  # checkov:skip=CKV_AWS_382:Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}