locals {
  workspace_name     = coalesce(var.workspace_name, "${var.prefix}-ws-${var.suffix}")
  emit_mws_networks  = var.vpc_source != "databricks_managed"
  emit_vpc_endpoints = var.frontend_forwarding_rule_name != null && var.backend_forwarding_rule_name != null
  emit_pas           = var.private_access_only
}
