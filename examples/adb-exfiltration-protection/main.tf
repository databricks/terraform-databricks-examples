/**
 * Azure Databricks workspace in custom VNet
 *
 * Module creates:
 * * Resource group with random prefix
 * * Tags, including `Owner`, which is taken from `az account show --query user`
 * * VNet with public and private subnet
 * * Databricks workspace
 */

module "adb-exfiltration-protection" {
  #  source       = "github.com/databricks/terraform-databricks-examples/modules/adb-exfiltration-protection"
  source           = "../../modules/adb-exfiltration-protection"
  hubcidr          = var.hubcidr
  spokecidr        = var.spokecidr
  no_public_ip     = var.no_public_ip
  rglocation       = var.rglocation
  metastoreip      = var.metastoreip
  sccip            = var.sccip
  webappip         = var.webappip
  dbfs_prefix      = var.dbfs_prefix
  workspace_prefix = var.workspace_prefix
  firewallfqdn     = var.firewallfqdn

}