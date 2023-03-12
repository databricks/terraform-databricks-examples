/**
 * Azure Databricks workspace in custom VNet
 *
 * Module creates:
 * * Resource group with random prefix
 * * Tags, including `Owner`, which is taken from `az account show --query user`
 * * VNet with public and private subnet
 * * Databricks workspace
 */

module "adb-with-private-links-exfiltration-protection" {
  source           = "github.com/databricks/terraform-databricks-examples/modules/adb-with-private-links-exfiltration-protection"
  hubcidr          = var.hubcidr
  spokecidr        = var.spokecidr
  no_public_ip     = var.no_public_ip
  rglocation       = var.rglocation
  metastoreip      = var.metastoreip
  dbfs_prefix      = var.dbfs_prefix
  workspace_prefix = var.workspace_prefix
  firewallfqdn     = var.firewallfqdn
}