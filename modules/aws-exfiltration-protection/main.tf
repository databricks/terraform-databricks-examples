locals {
  prefix                         = "${var.prefix}${random_string.naming.result}"
  spoke_db_private_subnets_cidr  = [cidrsubnet(var.spoke_cidr_block, 3, 0), cidrsubnet(var.spoke_cidr_block, 3, 1)]
  spoke_tgw_private_subnets_cidr = [cidrsubnet(var.spoke_cidr_block, 3, 2), cidrsubnet(var.spoke_cidr_block, 3, 3)]
  hub_tgw_private_subnets_cidr   = [cidrsubnet(var.hub_cidr_block, 3, 0)]
  hub_nat_public_subnets_cidr    = [cidrsubnet(var.hub_cidr_block, 3, 1)]
  hub_firewall_subnets_cidr      = [cidrsubnet(var.hub_cidr_block, 3, 2)]
  sg_egress_ports                = [
                                      443,  # for Databricks infrastructure, cloud data sources, and library repositories
                                      3306, # for the metastore
                                      6666, # for secure cluster connectivity
                                    ]
  sg_ingress_protocol            = ["tcp", "udp"]
  sg_egress_protocol             = ["tcp", "udp"]
  availability_zones             = ["${var.region}a", "${var.region}b"]
  db_root_bucket                 = "${var.prefix}${random_string.naming.result}-rootbucket.s3.amazonaws.com"
  protocols                      = ["ICMP", "FTP", "SSH"]
  protocols_control_plane        = ["TCP"]

  regional_config                = {
                                      ap-northeast-1 = {
                                        db_web_app       = "tokyo.cloud.databricks.com"
                                        db_tunnel        = "tunnel.ap-northeast-1.cloud.databricks.com"
                                        db_rds           = "mddx5a4bpbpm05.cfrfsun7mryq.ap-northeast-1.rds.amazonaws.com"
                                        db_control_plane = "35.72.28.0/28"
                                     },
                                      ap-northeast-2 = {
                                        db_web_app       = "seoul.cloud.databricks.com"
                                        db_tunnel        = "tunnel.ap-northeast-2.cloud.databricks.com"
                                        db_rds           = "md1915a81ruxky5.cfomhrbro6gt.ap-northeast-2.rds.amazonaws.com"
                                        db_control_plane = "3.38.156.176/28"
                                     },
                                      ap-south-1 = {
                                        db_web_app       = "mumbai.cloud.databricks.com"
                                        db_tunnel        = "tunnel.ap-south-1.cloud.databricks.com"
                                        db_rds           = "mdjanpojt83v6j.c5jml0fhgver.ap-south-1.rds.amazonaws.com"
                                        db_control_plane = "65.0.37.64/28"
                                     },
                                      ap-southeast-1 = {
                                        db_web_app       = "singapore.cloud.databricks.com"
                                        db_tunnel        = "tunnel.ap-southeast-1.cloud.databricks.com"
                                        db_rds           = "md1n4trqmokgnhr.csnrqwqko4ho.ap-southeast-1.rds.amazonaws.com"
                                        db_control_plane = "13.214.1.96/28"
                                     },
                                      ap-southeast-2 = {
                                        db_web_app       = "sydney.cloud.databricks.com"
                                        db_tunnel        = "tunnel.ap-southeast-2.cloud.databricks.com"
                                        db_rds           = "mdnrak3rme5y1c.c5f38tyb1fdu.ap-southeast-2.rds.amazonaws.com"
                                        db_control_plane = "3.26.4.0/28"
                                     },
                                      ca-central-1 = {
                                        db_web_app       = "canada.cloud.databricks.com"
                                        db_tunnel        = "tunnel.ca-central-1.cloud.databricks.com"
                                        db_rds           = "md1w81rjeh9i4n5.co1tih5pqdrl.ca-central-1.rds.amazonaws.com"
                                        db_control_plane = "3.96.84.208/28"
                                     },
                                      eu-central-1 = {
                                        db_web_app       = "frankfurt.cloud.databricks.com"
                                        db_tunnel        = "tunnel.eu-central-1.cloud.databricks.com"
                                        db_rds           = "mdv2llxgl8lou0.ceptxxgorjrc.eu-central-1.rds.amazonaws.com"
                                        db_control_plane = "18.159.44.32/28"
                                     },
                                      eu-west-1 = {
                                        db_web_app       = "ireland.cloud.databricks.com"
                                        db_tunnel        = "tunnel.eu-west-1.cloud.databricks.com"
                                        db_rds           = "md15cf9e1wmjgny.cxg30ia2wqgj.eu-west-1.rds.amazonaws.com"
                                        db_control_plane = "3.250.244.112/28"
                                     },
                                      eu-west-2 = {
                                        db_web_app       = "london.cloud.databricks.com"
                                        db_tunnel        = "tunnel.eu-west-2.cloud.databricks.com"
                                        db_rds           = "mdio2468d9025m.c6fvhwk6cqca.eu-west-2.rds.amazonaws.com"
                                        db_control_plane = "18.134.65.240/28"
                                     },
                                      eu-west-3 = {
                                        db_web_app       = "paris.cloud.databricks.com"
                                        db_tunnel        = "tunnel.eu-west-3.cloud.databricks.com"
                                        db_rds           = "metastorerds-dbconsolidationmetastore-asda4em2u6eg.c2ybp3dss6ua.eu-west-3.rds.amazonaws.com"
                                        db_control_plane = "13.39.141.128/28"
                                     },
                                      sa-east-1 = {
                                        db_web_app       = "saopaulo.cloud.databricks.com"
                                        db_tunnel        = "tunnel.sa-east-1.cloud.databricks.com"
                                        db_rds           = "metastorerds-dbconsolidationmetastore-fqekf3pck8yw.cog1aduyg4im.sa-east-1.rds.amazonaws.com"
                                        db_control_plane = "15.229.120.16/28"
                                     },
                                      us-east-1 = {
                                        db_web_app       = "nvirginia.cloud.databricks.com"
                                        db_tunnel        = "tunnel.us-east-1.cloud.databricks.com"
                                        db_rds           = "mdb7sywh50xhpr.chkweekm4xjq.us-east-1.rds.amazonaws.com"
                                        db_control_plane = "3.237.73.224/28"
                                     },
                                      us-east-2 = {
                                        db_web_app       = "ohio.cloud.databricks.com"
                                        db_tunnel        = "tunnel.us-east-2.cloud.databricks.com"
                                        db_rds           = "md7wf1g369xf22.cluz8hwxjhb6.us-east-2.rds.amazonaws.com"
                                        db_control_plane = "3.128.237.208/28"
                                     },
                                      us-west-1 = {
                                        db_web_app       = "oregon.cloud.databricks.com"
                                        db_tunnel        = "tunnel.cloud.databricks.com"
                                        db_rds           = "mdzsbtnvk0rnce.c13weuwubexq.us-west-1.rds.amazonaws.com"
                                        db_control_plane = "44.234.192.32/28"
                                     },
                                      us-west-2 = {
                                        db_web_app       = "oregon.cloud.databricks.com"
                                        db_tunnel        = "tunnel.cloud.databricks.com"
                                        db_rds           = "mdpartyyphlhsp.caj77bnxuhme.us-west-2.rds.amazonaws.com"
                                        db_control_plane = "44.234.192.32/28"
                                     },
                                   }

  db_web_app = var.db_web_app != null ? var.db_web_app : lookup(local.regional_config, var.region).db_web_app
  db_tunnel = var.db_tunnel != null ? var.db_tunnel : lookup(local.regional_config, var.region).db_tunnel
  db_rds = var.db_rds != null ? var.db_rds : lookup(local.regional_config, var.region).db_rds
  db_control_plane = var.db_control_plane != null ? var.db_control_plane : lookup(local.regional_config, var.region).db_control_plane
}