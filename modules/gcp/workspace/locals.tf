locals {
  workspace_name     = coalesce(var.workspace_name, "${var.prefix}-ws-${var.suffix}")
  emit_mws_networks  = var.vpc_source != "databricks_managed"
  emit_vpc_endpoints = var.enable_frontend && var.enable_backend
  emit_pas           = var.private_access_only

  manage_serverless_egress = var.serverless_egress_mode != "unmanaged"
  serverless_restricted    = var.serverless_egress_mode == "restricted"
}
