module "adb-exfiltration-protection" {
  source           = "../../modules/adb-exfiltration-protection"
  hubcidr          = var.hubcidr
  spokecidr        = var.spokecidr
  rglocation       = var.rglocation
  metastore        = var.metastore
  scc_relay        = var.scc_relay
  webapp_ips       = var.webapp_ips
  dbfs_prefix      = var.dbfs_prefix
  workspace_prefix = var.workspace_prefix
  firewallfqdn     = var.firewallfqdn
  eventhubs        = var.eventhubs
  tags             = var.tags
}
