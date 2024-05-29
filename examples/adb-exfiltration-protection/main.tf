/**
 * Azure Databricks workspace in custom VNet with traffic routed via firewall in the Hub VNet
 *
 * Module creates:
 * * Resource group with random prefix
 * * Tags, including `Owner`, which is taken from `az account show --query user`
 * * VNet with public and private subnet for Databricks
 * * VNet with subnet for deployment of Azure Firewall
 * * Azure Firewall with access enabled to Databricks-related resources
 * * Databricks workspace
 */

module "adb-exfiltration-protection" {
  source            = "../../modules/adb-exfiltration-protection"
  hubcidr           = var.hubcidr
  spokecidr         = var.spokecidr
  no_public_ip      = var.no_public_ip
  rglocation        = var.rglocation
  metastore         = var.metastore
  scc_relay         = var.scc_relay
  webapp_ips        = var.webapp_ips
  dbfs_prefix       = var.dbfs_prefix
  workspace_prefix  = var.workspace_prefix
  firewallfqdn      = var.firewallfqdn
  eventhubs         = var.eventhubs
  tags              = var.tags
}
