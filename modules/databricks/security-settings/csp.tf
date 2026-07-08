resource "databricks_compliance_security_profile_workspace_setting" "this" {
  count = var.enable_compliance_security_profile ? 1 : 0

  compliance_security_profile_workspace {
    is_enabled           = true
    compliance_standards = var.compliance_standards
  }
}
