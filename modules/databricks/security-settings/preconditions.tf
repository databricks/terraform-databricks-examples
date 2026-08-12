resource "terraform_data" "preconditions" {
  lifecycle {
    precondition {
      condition     = !var.enable_compliance_security_profile || var.enable_enhanced_security_monitoring
      error_message = "enable_compliance_security_profile=true requires enable_enhanced_security_monitoring=true (CSP builds on ESM)."
    }
    precondition {
      condition     = length(var.compliance_standards) == 0 || var.enable_compliance_security_profile
      error_message = "compliance_standards requires enable_compliance_security_profile=true."
    }
  }
}
