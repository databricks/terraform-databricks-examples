module "gcp_with_data_exfiltration_protection" {
  source = "../../modules/gcp-with-psc-exfiltration-protection"

  databricks_account_id    = var.databricks_account_id
  hub_vpc_google_project   = var.hub_vpc_google_project
  is_spoke_vpc_shared      = var.is_spoke_vpc_shared
  prefix                   = var.prefix
  spoke_vpc_google_project = var.spoke_vpc_google_project
  workspace_google_project = var.workspace_google_project
  gke_master_ip_range      = var.gke_master_ip_range
  google_region            = var.google_region
  hive_metastore_ip        = var.hive_metastore_ip
  hub_vpc_cidr             = var.hub_vpc_cidr
  pod_ip_cidr_range        = var.pod_ip_cidr_range
  psc_subnet_cidr          = var.psc_subnet_cidr
  service_ip_cidr_range    = var.service_ip_cidr_range
  spoke_vpc_cidr           = var.spoke_vpc_cidr
  tags                     = var.tags
}