locals {
  prefix                         = "${var.prefix}${random_string.naming.result}"
  spoke_db_private_subnets_cidr  = [cidrsubnet(var.spoke_cidr_block, 3, 0), cidrsubnet(var.spoke_cidr_block, 3, 1)]
  spoke_tgw_private_subnets_cidr = [cidrsubnet(var.spoke_cidr_block, 3, 2), cidrsubnet(var.spoke_cidr_block, 3, 3)]
  spoke_pl_private_subnets_cidr  = var.enable_private_link && local.vpc_endpoint_backend_rest != "" && local.vpc_endpoint_backend_relay != "" ? [cidrsubnet(var.spoke_cidr_block, 3, 4)] : []
  hub_tgw_private_subnets_cidr   = [cidrsubnet(var.hub_cidr_block, 3, 0)]
  hub_nat_public_subnets_cidr    = [cidrsubnet(var.hub_cidr_block, 3, 1)]
  hub_firewall_subnets_cidr      = [cidrsubnet(var.hub_cidr_block, 3, 2)]
  domain_names = [
    ".cloud.databricks.com" # https://docs.databricks.com/en/security/network/firewall-rules.html
  ]
  db_root_bucket_fqdn = "${local.db_root_bucket}.s3.amazonaws.com"

  private_link_whitelisted_urls = concat(
    local.domain_names,
    [
      local.db_rds,              # not routed through the private link connection
      local.db_root_bucket_fqdn, # not routed through the private link connection
    ],
    var.whitelisted_urls
  )

  whitelisted_urls = concat(
    local.private_link_whitelisted_urls,
    [
      local.db_web_app,
      local.db_tunnel,
    ],
  )

  # based on: https://docs.databricks.com/en/administration-guide/cloud-configurations/aws/customer-managed-vpc.html#security-groups
  sg_ports = [
    443,                                                  # for Databricks infrastructure, cloud data sources, and library repositories
    3306,                                                 # for the metastore
    6666,                                                 # for private link
    2443,                                                 # only for use with compliance security profile
    8443, 8444, 8445, 8446, 8447, 8448, 8449, 8450, 8451, # Future extendability
  ]
  sg_ingress_protocol = ["tcp", "udp"]
  sg_egress_protocol  = ["tcp", "udp"]

  # based on: https://docs.databricks.com/en/administration-guide/cloud-configurations/aws/privatelink.html#step-1-configure-aws-network-objects
  sg_private_link_ports = [
    443,  # for Databricks infrastructure, cloud data sources, and library repositories
    6666, # for private link
    2443, # only for use with compliance security profile
  ]
  sg_private_link_protocol = "tcp"

  availability_zones      = ["${var.region}a", "${var.region}b"]
  db_root_bucket          = "${var.prefix}-dbfs-storage"
  protocols_to_drop       = ["ICMP", "FTP", "SSH"]
  protocols_control_plane = ["TCP"]

  # based on: https://docs.databricks.com/en/resources/supported-regions.html
  regional_config = {
    ap-northeast-1 = {
      db_web_app                 = "tokyo.cloud.databricks.com"
      db_tunnel                  = "tunnel.ap-northeast-1.cloud.databricks.com"
      db_rds                     = "mddx5a4bpbpm05.cfrfsun7mryq.ap-northeast-1.rds.amazonaws.com"
      db_control_plane           = "35.72.28.0/28"
      vpc_endpoint_backend_rest  = "com.amazonaws.vpce.ap-northeast-1.vpce-svc-02691fd610d24fd64"
      vpc_endpoint_backend_relay = "com.amazonaws.vpce.ap-northeast-1.vpce-svc-02aa633bda3edbec0"
    },
    ap-northeast-2 = {
      db_web_app                 = "seoul.cloud.databricks.com"
      db_tunnel                  = "tunnel.ap-northeast-2.cloud.databricks.com"
      db_rds                     = "md1915a81ruxky5.cfomhrbro6gt.ap-northeast-2.rds.amazonaws.com"
      db_control_plane           = "3.38.156.176/28"
      vpc_endpoint_backend_rest  = "com.amazonaws.vpce.ap-northeast-2.vpce-svc-0babb9bde64f34d7e"
      vpc_endpoint_backend_relay = "com.amazonaws.vpce.ap-northeast-2.vpce-svc-0dc0e98a5800db5c4"
    },
    ap-south-1 = {
      db_web_app                 = "mumbai.cloud.databricks.com"
      db_tunnel                  = "tunnel.ap-south-1.cloud.databricks.com"
      db_rds                     = "mdjanpojt83v6j.c5jml0fhgver.ap-south-1.rds.amazonaws.com"
      db_control_plane           = "65.0.37.64/28"
      vpc_endpoint_backend_rest  = "com.amazonaws.vpce.ap-south-1.vpce-svc-0dbfe5d9ee18d6411"
      vpc_endpoint_backend_relay = "com.amazonaws.vpce.ap-south-1.vpce-svc-03fd4d9b61414f3de"
    },
    ap-southeast-1 = {
      db_web_app                 = "singapore.cloud.databricks.com"
      db_tunnel                  = "tunnel.ap-southeast-1.cloud.databricks.com"
      db_rds                     = "md1n4trqmokgnhr.csnrqwqko4ho.ap-southeast-1.rds.amazonaws.com"
      db_control_plane           = "13.214.1.96/28"
      vpc_endpoint_backend_rest  = "com.amazonaws.vpce.ap-southeast-1.vpce-svc-02535b257fc253ff4"
      vpc_endpoint_backend_relay = "com.amazonaws.vpce.ap-southeast-1.vpce-svc-0557367c6fc1a0c5c"
    },
    ap-southeast-2 = {
      db_web_app                 = "sydney.cloud.databricks.com"
      db_tunnel                  = "tunnel.ap-southeast-2.cloud.databricks.com"
      db_rds                     = "mdnrak3rme5y1c.c5f38tyb1fdu.ap-southeast-2.rds.amazonaws.com"
      db_control_plane           = "3.26.4.0/28"
      vpc_endpoint_backend_rest  = "com.amazonaws.vpce.ap-southeast-2.vpce-svc-0b87155ddd6954974"
      vpc_endpoint_backend_relay = "com.amazonaws.vpce.ap-southeast-2.vpce-svc-0b4a72e8f825495f6"
    },
    ca-central-1 = {
      db_web_app                 = "canada.cloud.databricks.com"
      db_tunnel                  = "tunnel.ca-central-1.cloud.databricks.com"
      db_rds                     = "md1w81rjeh9i4n5.co1tih5pqdrl.ca-central-1.rds.amazonaws.com"
      db_control_plane           = "3.96.84.208/28"
      vpc_endpoint_backend_rest  = "com.amazonaws.vpce.ca-central-1.vpce-svc-0205f197ec0e28d65"
      vpc_endpoint_backend_relay = "com.amazonaws.vpce.ca-central-1.vpce-svc-0c4e25bdbcbfbb684"
    },
    eu-central-1 = {
      db_web_app                 = "frankfurt.cloud.databricks.com"
      db_tunnel                  = "tunnel.eu-central-1.cloud.databricks.com"
      db_rds                     = "mdv2llxgl8lou0.ceptxxgorjrc.eu-central-1.rds.amazonaws.com"
      db_control_plane           = "18.159.44.32/28"
      vpc_endpoint_backend_rest  = "com.amazonaws.vpce.eu-central-1.vpce-svc-081f78503812597f7"
      vpc_endpoint_backend_relay = "com.amazonaws.vpce.eu-central-1.vpce-svc-08e5dfca9572c85c4"
    },
    eu-west-1 = {
      db_web_app                 = "ireland.cloud.databricks.com"
      db_tunnel                  = "tunnel.eu-west-1.cloud.databricks.com"
      db_rds                     = "md15cf9e1wmjgny.cxg30ia2wqgj.eu-west-1.rds.amazonaws.com"
      db_control_plane           = "3.250.244.112/28"
      vpc_endpoint_backend_rest  = "com.amazonaws.vpce.eu-west-1.vpce-svc-0da6ebf1461278016"
      vpc_endpoint_backend_relay = "com.amazonaws.vpce.eu-west-1.vpce-svc-09b4eb2bc775f4e8c"
    },
    eu-west-2 = {
      db_web_app                 = "london.cloud.databricks.com"
      db_tunnel                  = "tunnel.eu-west-2.cloud.databricks.com"
      db_rds                     = "mdio2468d9025m.c6fvhwk6cqca.eu-west-2.rds.amazonaws.com"
      db_control_plane           = "18.134.65.240/28"
      vpc_endpoint_backend_rest  = "com.amazonaws.vpce.eu-west-2.vpce-svc-01148c7cdc1d1326c"
      vpc_endpoint_backend_relay = "com.amazonaws.vpce.eu-west-2.vpce-svc-05279412bf5353a45"
    },
    eu-west-3 = {
      db_web_app                 = "paris.cloud.databricks.com"
      db_tunnel                  = "tunnel.eu-west-3.cloud.databricks.com"
      db_rds                     = "metastorerds-dbconsolidationmetastore-asda4em2u6eg.c2ybp3dss6ua.eu-west-3.rds.amazonaws.com"
      db_control_plane           = "13.39.141.128/28"
      vpc_endpoint_backend_rest  = "com.amazonaws.vpce.eu-west-3.vpce-svc-008b9368d1d011f37"
      vpc_endpoint_backend_relay = "com.amazonaws.vpce.eu-west-3.vpce-svc-005b039dd0b5f857d"
    },
    sa-east-1 = {
      db_web_app                 = "saopaulo.cloud.databricks.com"
      db_tunnel                  = "tunnel.sa-east-1.cloud.databricks.com"
      db_rds                     = "metastorerds-dbconsolidationmetastore-fqekf3pck8yw.cog1aduyg4im.sa-east-1.rds.amazonaws.com"
      db_control_plane           = "15.229.120.16/28"
      vpc_endpoint_backend_rest  = "com.amazonaws.vpce.sa-east-1.vpce-svc-0bafcea8cdfe11b66"
      vpc_endpoint_backend_relay = "com.amazonaws.vpce.sa-east-1.vpce-svc-0e61564963be1b43f"
    },
    us-east-1 = {
      db_web_app                 = "nvirginia.cloud.databricks.com"
      db_tunnel                  = "tunnel.us-east-1.cloud.databricks.com"
      db_rds                     = "mdb7sywh50xhpr.chkweekm4xjq.us-east-1.rds.amazonaws.com"
      db_control_plane           = "3.237.73.224/28"
      vpc_endpoint_backend_rest  = "com.amazonaws.vpce.us-east-1.vpce-svc-09143d1e626de2f04"
      vpc_endpoint_backend_relay = "com.amazonaws.vpce.us-east-1.vpce-svc-00018a8c3ff62ffdf"
    },
    us-east-2 = {
      db_web_app                 = "ohio.cloud.databricks.com"
      db_tunnel                  = "tunnel.us-east-2.cloud.databricks.com"
      db_rds                     = "md7wf1g369xf22.cluz8hwxjhb6.us-east-2.rds.amazonaws.com"
      db_control_plane           = "3.128.237.208/28"
      vpc_endpoint_backend_rest  = "com.amazonaws.vpce.us-east-2.vpce-svc-041dc2b4d7796b8d3"
      vpc_endpoint_backend_relay = "com.amazonaws.vpce.us-east-2.vpce-svc-090a8fab0d73e39a6"
    },
    us-west-1 = {
      db_web_app                 = "oregon.cloud.databricks.com"
      db_tunnel                  = "tunnel.cloud.databricks.com"
      db_rds                     = "mdzsbtnvk0rnce.c13weuwubexq.us-west-1.rds.amazonaws.com"
      db_control_plane           = "44.234.192.32/28"
      vpc_endpoint_backend_rest  = "" # not supported
      vpc_endpoint_backend_relay = "" # not supported
    },
    us-west-2 = {
      db_web_app                 = "oregon.cloud.databricks.com"
      db_tunnel                  = "tunnel.cloud.databricks.com"
      db_rds                     = "mdpartyyphlhsp.caj77bnxuhme.us-west-2.rds.amazonaws.com"
      db_control_plane           = "44.234.192.32/28"
      vpc_endpoint_backend_rest  = "com.amazonaws.vpce.us-west-2.vpce-svc-0129f463fcfbc46c5"
      vpc_endpoint_backend_relay = "com.amazonaws.vpce.us-west-2.vpce-svc-0158114c0c730c3bb"
    },
  }

  db_web_app                 = var.db_web_app != null ? var.db_web_app : lookup(local.regional_config, var.region).db_web_app
  db_tunnel                  = var.db_tunnel != null ? var.db_tunnel : lookup(local.regional_config, var.region).db_tunnel
  db_rds                     = var.db_rds != null ? var.db_rds : lookup(local.regional_config, var.region).db_rds
  db_control_plane           = var.db_control_plane != null ? var.db_control_plane : lookup(local.regional_config, var.region).db_control_plane
  vpc_endpoint_backend_rest  = var.vpc_endpoint_backend_rest != null ? var.vpc_endpoint_backend_rest : lookup(local.regional_config, var.region).vpc_endpoint_backend_rest
  vpc_endpoint_backend_relay = var.vpc_endpoint_backend_relay != null ? var.vpc_endpoint_backend_relay : lookup(local.regional_config, var.region).vpc_endpoint_backend_relay
}

resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}
