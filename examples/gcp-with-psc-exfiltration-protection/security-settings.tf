module "security_settings" {
  source = "../../modules/databricks/security-settings"

  providers = {
    databricks = databricks.workspace
  }

  enable_compliance_security_profile  = var.enable_compliance_security_profile
  compliance_standards                = var.compliance_standards
  enable_enhanced_security_monitoring = var.enable_enhanced_security_monitoring
  enable_automatic_cluster_update     = var.enable_automatic_cluster_update
  ip_access_lists                     = var.ip_access_lists

  depends_on = [module.workspace]
}
