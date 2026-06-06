# =============================================================================
# Databricks NCC + workspace binding + private endpoint rule
#
# IMPORTANT: For an Application Gateway target, the NCC private endpoint rule
# must be created via the Network Connectivity Configurations REST API — this is
# the method documented by Microsoft Learn, not a workaround. App Gateway v2
# requires resource_id + group_id + domain_names together, and the Terraform
# databricks_mws_ncc_private_endpoint_rule resource forbids group_id alongside
# domain_names. So we POST the rule via az + curl. group_id is the frontend IP
# configuration name that carries the Private Link configuration.
#
# Ref: https://learn.microsoft.com/en-us/azure/databricks/security/network/serverless-network-security/serverless-private-link#configure-private-link-to-azure-app-gateway-v2
#
# Requires the az CLI to be authenticated as a Databricks account admin on the
# machine running terraform.
# =============================================================================

resource "databricks_mws_network_connectivity_config" "this" {
  provider = databricks.accounts
  name     = var.ncc_name
  region   = var.azure_region
}

resource "databricks_mws_ncc_binding" "this" {
  provider                       = databricks.accounts
  network_connectivity_config_id = databricks_mws_network_connectivity_config.this.network_connectivity_config_id
  workspace_id                   = var.databricks_workspace_id
}

# Create the App Gateway private endpoint rule via the documented REST API.
resource "null_resource" "ncc_pe_rule_appgw" {
  triggers = {
    ncc_id       = databricks_mws_network_connectivity_config.this.network_connectivity_config_id
    appgw_id     = azapi_resource.appgw.id
    group_id     = local.frontend_pl_name
    domain_names = join(",", var.serverless_domain_names)
    account_id   = var.databricks_account_id
    host         = var.databricks_host
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<-EOT
      set -e
      TOKEN=$(az account get-access-token --resource "2ff814a6-3304-4ab8-85cb-cd0e6f879c1d" --query accessToken -o tsv)
      [ -n "$TOKEN" ] || { echo "ERROR: could not get a Databricks access token via az"; exit 1; }
      NCC_ID="${databricks_mws_network_connectivity_config.this.network_connectivity_config_id}"
      RESP=$(curl -sw "\n%%{http_code}" -X POST \
        "${var.databricks_host}/api/2.0/accounts/${var.databricks_account_id}/network-connectivity-configs/$NCC_ID/private-endpoint-rules" \
        -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
        -d '{"resource_id":"${azapi_resource.appgw.id}","group_id":"${local.frontend_pl_name}","domain_names":${jsonencode(var.serverless_domain_names)}}')
      CODE=$(echo "$RESP" | tail -1)
      BODY=$(echo "$RESP" | sed '$d')
      if [ "$CODE" -ge 200 ] && [ "$CODE" -lt 300 ]; then
        echo "NCC private endpoint rule created:"
        echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
      else
        echo "ERROR: HTTP $CODE"; echo "$BODY"; exit 1
      fi
    EOT
  }

  depends_on = [
    databricks_mws_ncc_binding.this,
    azapi_resource.appgw,
  ]
}

# Give Databricks time to provision its private endpoint before approving.
resource "time_sleep" "wait_for_pe" {
  depends_on      = [null_resource.ncc_pe_rule_appgw]
  create_duration = "90s"
}

# (Optional) Approve the inbound private endpoint connection on the App Gateway.
# Set auto_approve_private_endpoint = false to approve manually in the portal.
resource "null_resource" "approve_pe_on_appgw" {
  count      = var.auto_approve_private_endpoint ? 1 : 0
  depends_on = [time_sleep.wait_for_pe]

  triggers = {
    appgw_name = var.appgw_name
    rg_name    = azurerm_resource_group.this.name
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<-EOT
      set -e
      echo "Looking for pending PE connections on App Gateway ${var.appgw_name}..."
      for i in 1 2 3 4 5 6; do
        PENDING=$(az network application-gateway private-link list \
          --gateway-name "${var.appgw_name}" \
          --resource-group "${azurerm_resource_group.this.name}" \
          --query "[0].privateEndpointConnections[?privateLinkServiceConnectionState.status=='Pending']" \
          -o json 2>/dev/null || echo "[]")
        COUNT=$(echo "$PENDING" | python3 -c "import sys, json; print(len(json.load(sys.stdin)))")
        if [ "$COUNT" -gt 0 ]; then
          echo "$PENDING" | python3 -c "
import sys, json, subprocess
for c in json.load(sys.stdin):
    name = c['name']
    print(f'Approving {name}')
    subprocess.run(['az','network','application-gateway','private-link','connection','update',
                    '--gateway-name','${var.appgw_name}',
                    '--resource-group','${azurerm_resource_group.this.name}',
                    '--name', name, '--connection-status','Approved'], check=True)
"
          exit 0
        fi
        echo "  no pending connection yet, sleeping 30s ($i/6)..."
        sleep 30
      done
      echo "WARN: no pending PE connection appeared after ~3 min. Approve manually:"
      echo "  az network application-gateway private-link list --gateway-name ${var.appgw_name} --resource-group ${azurerm_resource_group.this.name} -o jsonc"
    EOT
  }
}
