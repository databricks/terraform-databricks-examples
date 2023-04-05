locals {
  prefix                         = "${var.prefix}${random_string.naming.result}"
  spoke_db_private_subnets_cidr  = [cidrsubnet(var.spoke_cidr_block, 3, 0), cidrsubnet(var.spoke_cidr_block, 3, 1)]
  spoke_tgw_private_subnets_cidr = [cidrsubnet(var.spoke_cidr_block, 3, 2), cidrsubnet(var.spoke_cidr_block, 3, 3)]
  hub_tgw_private_subnets_cidr   = [cidrsubnet(var.hub_cidr_block, 3, 0)]
  hub_nat_public_subnets_cidr    = [cidrsubnet(var.hub_cidr_block, 3, 1)]
  hub_firewall_subnets_cidr      = [cidrsubnet(var.hub_cidr_block, 3, 2)]
  sg_egress_ports                = [443, 3306, 6666]
  sg_ingress_protocol            = ["tcp", "udp"]
  sg_egress_protocol             = ["tcp", "udp"]
  availability_zones             = ["${var.region}a", "${var.region}b"]
  db_root_bucket                 = "${var.prefix}${random_string.naming.result}-rootbucket.s3.amazonaws.com"
  protocols                      = ["ICMP", "FTP", "SSH"]
  protocols_control_plane        = ["TCP"]
}