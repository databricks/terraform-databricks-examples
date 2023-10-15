output "databricks_host" {
  value = module.aws-exfiltration-protection.databricks_host
}

output "databricks_token" {
  value = module.aws-exfiltration-protection.databricks_token
  sensitive = true
}
