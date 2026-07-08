terraform {
  required_version = ">= 1.5"
  required_providers {
    databricks = { source = "databricks/databricks" }
  }
}

provider "databricks" {
  host  = "https://1234567890123456.7.gcp.databricks.com"
  token = "fixture-token"
}

module "security_settings" {
  source = "../.."

  enable_enhanced_security_monitoring = true
  enable_compliance_security_profile  = true
  compliance_standards                = ["HIPAA"]
  enable_automatic_cluster_update     = true

  ip_access_lists = [
    {
      label        = "corp-vpn"
      list_type    = "ALLOW"
      ip_addresses = ["203.0.113.0/24"]
    }
  ]
}
