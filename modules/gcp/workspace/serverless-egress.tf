resource "databricks_account_network_policy" "this" {
  count = local.manage_serverless_egress ? 1 : 0

  network_policy_id = "${var.prefix}-serverless-egress-${var.suffix}"

  egress = {
    network_access = {
      restriction_mode = local.serverless_restricted ? "RESTRICTED_ACCESS" : "FULL_ACCESS"

      allowed_internet_destinations = local.serverless_restricted ? [
        for d in var.serverless_allowed_internet_destinations : {
          destination               = d
          internet_destination_type = "DNS_NAME"
        }
      ] : null

      allowed_storage_destinations = local.serverless_restricted ? [
        for b in var.serverless_allowed_storage_destinations : {
          bucket_name              = b
          region                   = var.google_region
          storage_destination_type = "GOOGLE_CLOUD_STORAGE"
        }
      ] : null

      policy_enforcement = {
        enforcement_mode = var.serverless_egress_enforcement == "dry_run" ? "DRY_RUN" : "ENFORCED"
      }
    }
  }
}

resource "databricks_workspace_network_option" "this" {
  count = local.manage_serverless_egress ? 1 : 0

  workspace_id      = databricks_mws_workspaces.this.workspace_id
  network_policy_id = databricks_account_network_policy.this[0].network_policy_id
}
