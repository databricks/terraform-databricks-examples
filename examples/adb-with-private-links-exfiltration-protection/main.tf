module "adb_with_private_links_exfiltration_protection" {
  source                       = "../../modules/adb-with-private-links-exfiltration-protection"
  hubcidr                      = var.hubcidr
  spokecidr                    = var.spokecidr
  rglocation                   = var.rglocation
  metastoreip                  = var.metastoreip
  dbfs_prefix                  = var.dbfs_prefix
  workspace_prefix             = var.workspace_prefix
  firewallfqdn                 = var.firewallfqdn
  existing_resource_group_name = var.existing_resource_group_name
  create_resource_group        = var.create_resource_group
}