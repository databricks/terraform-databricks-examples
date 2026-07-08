resource "databricks_enhanced_security_monitoring_workspace_setting" "this" {
  count = var.enable_enhanced_security_monitoring ? 1 : 0

  enhanced_security_monitoring_workspace {
    is_enabled = true
  }
}
