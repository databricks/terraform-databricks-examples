locals {
  prefix                       = "${var.prefix}${random_string.naming.result}"
  private_subnets_cidr         = [cidrsubnet(var.cidr_block, 3, 0), cidrsubnet(var.cidr_block, 3, 1)]
  nat_public_subnets_cidr      = [cidrsubnet(var.cidr_block, 3, 2), cidrsubnet(var.cidr_block, 3, 3)]
  firewall_public_subnets_cidr = [cidrsubnet(var.cidr_block, 3, 4)]
  sg_egress_ports              = [443, 3306, 6666]
  sg_ingress_protocol          = ["tcp", "udp"]
  sg_egress_protocol           = ["tcp", "udp"]
  availability_zones           = ["${var.region}a", "${var.region}b"]
  db_root_bucket               = "${var.prefix}${random_string.naming.result}-rootbucket.s3.amazonaws.com"
  protocols                    = ["ICMP", "FTP", "SSH"]
  protocols_control_plane      = ["TCP"]
}

resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}
