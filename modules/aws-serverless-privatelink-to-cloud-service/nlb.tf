# Create the Network Load Balancer.
resource "aws_lb" "this" {
  name_prefix                = var.prefix
  internal                   = true
  load_balancer_type         = "network"
  subnets                    = var.private_subnet_ids
  enable_deletion_protection = true

  # checkov:skip=CKV_AWS_152:CZLB is intentionally disabled.
  # checkov:skip=CKV_AWS_91:Only enable access logging if you need to.
}

# Create the target group for the NLB
resource "aws_lb_target_group" "this" {
  name        = "${var.prefix}-tg"
  port        = 443
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    protocol = "TCP"
    port     = 443
    enabled  = true
    timeout  = 10
    interval = 30
  }
}

# Attach your desired target IP addresses to the target group.
# In this case, the IPs of the VPCE ENIs.
resource "aws_lb_target_group_attachment" "this" {
  for_each         = toset(local.vpce_eni_ips)
  port             = 443
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = each.key
}
