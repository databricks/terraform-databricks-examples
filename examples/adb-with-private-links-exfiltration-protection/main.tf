/**
 * Azure Databricks workspace in custom VNet
 *
 * Module creates:
 * * Resource group with random prefix
 * * Tags, including `Owner`, which is taken from `az account show --query user`
 * * VNet with public and private subnet
 * * Databricks workspace
 */

module "adb_with_private_links_exfiltration_protection" {
  source           = "github.com/databricks/terraform-databricks-examples/modules/adb-with-private-links-exfiltration-protection"
  hubcidr          = var.hubcidr
  spokecidr        = var.spokecidr
  rglocation       = var.rglocation
  metastoreip      = var.metastoreip
  dbfs_prefix      = var.dbfs_prefix
  workspace_prefix = var.workspace_prefix
  firewallfqdn     = var.firewallfqdn
}

output "workspace_url" {
  value = module.adb_with_private_links_exfiltration_protection.workspace_url
}

output "workspace_azure_resource_id" {
  value = module.adb_with_private_links_exfiltration_protection.databricks_azure_workspace_resource_id
}

output "test_vm_public_ip" {
  value = module.adb_with_private_links_exfiltration_protection.test_vm_public_ip
}

output "resource_group" {
  value = module.adb_with_private_links_exfiltration_protection.resource_group
}
