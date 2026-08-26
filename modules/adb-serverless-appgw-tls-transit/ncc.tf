# Databricks NCC and workspace binding.
#
# Application Gateway v2 private endpoint rules require resource_id, group_id,
# and domain_names together. The Databricks Terraform resource does not expose
# that combination, so this module uses the documented account API.

resource "databricks_mws_network_connectivity_config" "this" {
  name   = "ncc-${var.appgw_name}"
  region = var.azure_region
}

resource "databricks_mws_ncc_binding" "this" {
  network_connectivity_config_id = databricks_mws_network_connectivity_config.this.network_connectivity_config_id
  workspace_id                   = tonumber(var.databricks_workspace_id)
}

resource "null_resource" "ncc_private_endpoint_rule" {
  triggers = {
    ncc_id       = databricks_mws_network_connectivity_config.this.network_connectivity_config_id
    resource_id  = azapi_resource.appgw.id
    group_id     = local.frontend_name
    domain_names = jsonencode(var.serverless_domain_names)
    account_id   = var.databricks_account_id
    host         = var.databricks_host
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command = <<-EOT
      set -euo pipefail

      TOKEN=$(az account get-access-token \
        --resource "2ff814a6-3304-4ab8-85cb-cd0e6f879c1d" \
        --query accessToken -o tsv)
      test -n "$TOKEN"

      API="${var.databricks_host}/api/2.0/accounts/${var.databricks_account_id}/network-connectivity-configs/${databricks_mws_network_connectivity_config.this.network_connectivity_config_id}/private-endpoint-rules"
      PAYLOAD_B64='${base64encode(jsonencode({
    domain_names = var.serverless_domain_names
    resource_id  = azapi_resource.appgw.id
    group_id     = local.frontend_name
}))}'
      DOMAIN_PAYLOAD_B64='${base64encode(jsonencode({ domain_names = var.serverless_domain_names }))}'
      TARGET_RESOURCE_ID_B64='${base64encode(azapi_resource.appgw.id)}'
      TARGET_GROUP_ID_B64='${base64encode(local.frontend_name)}'
      PAYLOAD=$(printf '%s' "$PAYLOAD_B64" | python3 -c 'import base64, sys; print(base64.b64decode(sys.stdin.buffer.read()).decode())')
      DOMAIN_PAYLOAD=$(printf '%s' "$DOMAIN_PAYLOAD_B64" | python3 -c 'import base64, sys; print(base64.b64decode(sys.stdin.buffer.read()).decode())')
      export TARGET_RESOURCE_ID_B64 TARGET_GROUP_ID_B64

      # Reconcile instead of blindly POSTing: changing the domain list should
      # update the existing rule, not create a duplicate rule in the NCC.
      RULES=$(curl --silent --show-error --fail \
        --header "Authorization: Bearer $TOKEN" \
        --header "Content-Type: application/json" "$API")
      RULE_ID=$(printf '%s' "$RULES" | python3 -c '
import base64
import json
import os
import sys

body = json.load(sys.stdin)
rules = body.get("private_endpoint_rules", body.get("privateEndpointRules", []))
target_resource_id = base64.b64decode(os.environ["TARGET_RESOURCE_ID_B64"]).decode()
target_group_id = base64.b64decode(os.environ["TARGET_GROUP_ID_B64"]).decode()
for rule in rules:
    if (rule.get("resource_id") == target_resource_id and
            rule.get("group_id") == target_group_id):
        print(rule.get("private_endpoint_rule_id", rule.get("privateEndpoint_rule_id", rule.get("id", ""))))
        break
')

      if test -n "$RULE_ID"; then
        curl --silent --show-error --fail --request PATCH \
          --header "Authorization: Bearer $TOKEN" \
          --header "Content-Type: application/json" \
          --data "$DOMAIN_PAYLOAD" "$API/$RULE_ID?update_mask=domain_names"
      else
        curl --silent --show-error --fail --request POST \
          --header "Authorization: Bearer $TOKEN" \
          --header "Content-Type: application/json" \
          --data "$PAYLOAD" "$API"
      fi
    EOT
}

provisioner "local-exec" {
  when        = destroy
  interpreter = ["bash", "-c"]
  command     = <<-EOT
      set -euo pipefail

      TOKEN=$(az account get-access-token \
        --resource "2ff814a6-3304-4ab8-85cb-cd0e6f879c1d" \
        --query accessToken -o tsv)
      test -n "$TOKEN"
      API="${self.triggers.host}/api/2.0/accounts/${self.triggers.account_id}/network-connectivity-configs/${self.triggers.ncc_id}/private-endpoint-rules"
      TARGET_RESOURCE_ID_B64='${base64encode(self.triggers.resource_id)}'
      TARGET_GROUP_ID_B64='${base64encode(self.triggers.group_id)}'
      export TARGET_RESOURCE_ID_B64 TARGET_GROUP_ID_B64
      RULES=$(curl --silent --show-error --fail \
        --header "Authorization: Bearer $TOKEN" "$API")
      RULE_ID=$(printf '%s' "$RULES" | python3 -c '
import base64
import json
import os
import sys
body = json.load(sys.stdin)
rules = body.get("private_endpoint_rules", body.get("privateEndpointRules", []))
target_resource_id = base64.b64decode(os.environ["TARGET_RESOURCE_ID_B64"]).decode()
target_group_id = base64.b64decode(os.environ["TARGET_GROUP_ID_B64"]).decode()
for rule in rules:
    if (rule.get("resource_id") == target_resource_id and
            rule.get("group_id") == target_group_id):
        print(rule.get("private_endpoint_rule_id", rule.get("privateEndpoint_rule_id", rule.get("id", ""))))
        break
')
      if test -n "$RULE_ID"; then
        curl --silent --show-error --fail --request DELETE \
          --header "Authorization: Bearer $TOKEN" "$API/$RULE_ID"
      fi
    EOT
}

depends_on = [
  databricks_mws_ncc_binding.this,
  azapi_resource.appgw,
]
}

# Give the Databricks-created private endpoint time to appear in Azure before
# optionally attempting approval.
resource "time_sleep" "wait_for_private_endpoint" {
  depends_on      = [null_resource.ncc_private_endpoint_rule]
  create_duration = "90s"
}

resource "null_resource" "approve_private_endpoint" {
  count = var.auto_approve_private_endpoint ? 1 : 0

  triggers = {
    appgw_name = var.appgw_name
    rg_name    = azurerm_resource_group.this.name
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<-EOT
      set -euo pipefail
      for attempt in 1 2 3 4 5 6; do
        CONNECTION_IDS=$(az network application-gateway show \
          --name "${var.appgw_name}" \
          --resource-group "${azurerm_resource_group.this.name}" \
          --query "privateLinkConfigurations[].privateEndpointConnections[?privateLinkServiceConnectionState.status=='Pending'].id" \
          --output tsv 2>/dev/null || true)
        if test -n "$CONNECTION_IDS"; then
          while IFS= read -r connection_id; do
            test -n "$connection_id" || continue
            az network private-endpoint-connection approve \
              --id "$connection_id" \
              --description "Approved for Databricks Serverless NCC"
          done <<< "$CONNECTION_IDS"
          exit 0
        fi
        echo "No pending App Gateway private endpoint yet; retry $attempt/6."
        sleep 30
      done
      echo "ERROR: no pending connection appeared after six attempts; approve it manually in Azure."
      exit 1
    EOT
  }

  depends_on = [time_sleep.wait_for_private_endpoint]
}
