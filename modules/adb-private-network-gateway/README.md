# Module adb-private-network-gateway

## Description

This module creates an Azure Databricks [private network gateway](https://learn.microsoft.com/azure/databricks/security/network/serverless-network-security/private-network-gateway) (Public Preview) in an existing network connectivity configuration (NCC). Serverless compute in workspaces attached to that NCC can then reach resources in your VNet and in networks your VNet routes to, such as peered VNets or on-premises systems over ExpressRoute or VPN.

The module creates:

* A dedicated subnet in an existing VNet, delegated to `Microsoft.Databricks/workspaces`.
* Optionally, an association between that subnet and an existing NAT gateway.
* A `databricks_private_network_gateway` in the NCC, connected to the subnet.

> **Note**
> Private network gateway is in Public Preview. It requires the Premium plan, account admin privileges, and the preview enabled on the account console Previews page. See [Configure a private network gateway](https://learn.microsoft.com/azure/databricks/security/network/serverless-network-security/private-network-gateway/configure-private-network-gateway).

## What traffic it handles

Serverless egress uses the first matching path ([routing order](https://learn.microsoft.com/azure/databricks/security/network/serverless-network-security/private-network-gateway#how-it-works)):

1. NCC private endpoint rules.
2. Azure service endpoints. The gateway cannot override these. Blob storage always uses this path.
3. The private network gateway: the listed destinations in `SPECIFIC_DESTINATIONS` mode, or all remaining egress in `ALL_TRAFFIC` mode.
4. Default serverless egress.

Traffic modes:

* `SPECIFIC_DESTINATIONS` (default): only the DNS names in `destinations` (1 to 100) use the gateway. Suffix matching applies, so `mydb.contoso.com` also matches `sub.mydb.contoso.com`. These destinations are allowed in serverless egress control automatically.
* `ALL_TRAFFIC`: all remaining serverless egress uses the gateway. `destinations` must be empty. Add every destination you intend to reach to the serverless egress network policy. Internet-bound traffic needs an egress path from the gateway subnet, such as a NAT gateway (`attach_nat_gateway = true`) or a route to a firewall.

Use NCC private endpoint rules (`databricks_mws_ncc_private_endpoint_rule`), not the gateway, for Azure Storage, Key Vault and Service Bus or Event Hubs. The API rejects these names as gateway destinations with `The following destinations are reserved and cannot be used as PNG destinations`. The module checks for these suffixes at plan time:

* `blob`, `dfs`, `queue`, `table`, `file` and `web.core.windows.net`
* `vault.azure.net` and `vaultcore.azure.net`
* `servicebus.windows.net`
* the `privatelink.*` forms of the above

## Usage

Pass an account-level Databricks provider.

```hcl
provider "databricks" {
  alias      = "account"
  host       = "https://accounts.azuredatabricks.net"
  account_id = var.databricks_account_id
}

module "private_network_gateway" {
  source = "github.com/databricks/terraform-databricks-examples//modules/adb-private-network-gateway"

  providers = {
    databricks = databricks.account
  }

  databricks_account_id          = var.databricks_account_id
  network_connectivity_config_id = databricks_mws_network_connectivity_config.this.network_connectivity_config_id
  location                       = "eastus2"
  resource_group_name            = "rg-network"
  virtual_network_name           = "vnet-hub"
  gateway_subnet_address_prefix  = "10.0.1.0/28"
  display_name                   = "png-eastus2"

  traffic_mode = "SPECIFIC_DESTINATIONS"
  destinations = ["db.example.internal", "myserver.database.windows.net"]
}
```

For a static serverless egress IP, use `ALL_TRAFFIC` with a NAT gateway:

```hcl
  traffic_mode       = "ALL_TRAFFIC"
  destinations       = []
  attach_nat_gateway = true
  nat_gateway_id     = azurerm_nat_gateway.this.id
```

See [examples/adb-private-network-gateway](../../examples/adb-private-network-gateway/) for a complete deployment.

## Limitations

From [Microsoft Learn](https://learn.microsoft.com/azure/databricks/security/network/serverless-network-security/private-network-gateway#limitations), during Public Preview:

* The gateway and its subnet must be in the same region as the NCC. Supported regions: australiaeast, brazilsouth, canadacentral, centralindia, centralus, eastasia, eastus, eastus2, francecentral, germanywestcentral, japaneast, koreacentral, northcentralus, northeurope, southcentralus, southeastasia, swedencentral, switzerlandnorth, uaenorth, uksouth, westcentralus, westeurope, westus, westus2, westus3. The module rejects other regions.
* The gateway subnet must be /28 or larger and used by nothing else.
* The VNet subscription must be in the same Microsoft Entra ID tenant as the workspaces.
* An NCC supports at most two gateways. A gateway supports at most two DNS resolvers and 100 destinations.
* Bandwidth tiers are 10, 30, 50 and 100 Gbps.
* To change the gateway subnet, delete the gateway and create a new one.
* `FAILED` is a terminal state: delete the gateway and create a new one after fixing the cause.

Observed API behaviour:

* `private_dns_resolvers` cannot contain the Azure-provided DNS address `168.63.129.16`. Leave the list empty to use Azure-provided DNS. The module rejects it at plan time.
* Delete returns immediately and infrastructure cleanup continues in the background. Until cleanup finishes, Azure rejects deleting the subnet (`InUseSubnetCannotBeDeleted`) and the API rejects deleting the NCC (`has one or more attached private network gateway(s)`). On destroy, the module waits `gateway_destroy_wait` (default `30m`) after deleting the gateway, before it deletes the subnet and NAT association. If the NCC is managed in the same configuration, Terraform deletes it after the wait. If destroy still fails with one of these errors, run `terraform destroy` again later.
* Observed during Public Preview (Nov 2026): the subnet stayed in use for about 23 minutes after the gateway was deleted, and the NCC could not be deleted for longer.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0, < 5.0 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >= 1.140.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0, < 5.0 |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | >= 1.140.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.9 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_subnet.gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_nat_gateway_association.gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_nat_gateway_association) | resource |
| [databricks_private_network_gateway.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/private_network_gateway) | resource |
| [time_sleep.wait_for_gateway_cleanup](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | Databricks account ID. | `string` | n/a | yes |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | Display name of the private network gateway. | `string` | n/a | yes |
| <a name="input_gateway_subnet_address_prefix"></a> [gateway\_subnet\_address\_prefix](#input\_gateway\_subnet\_address\_prefix) | IPv4 CIDR of the gateway subnet, for example 10.0.1.0/28. Must be /28 or larger, inside the VNet address space and unused. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region of the VNet and NCC. Must be a region where private network gateway is available. | `string` | n/a | yes |
| <a name="input_network_connectivity_config_id"></a> [network\_connectivity\_config\_id](#input\_network\_connectivity\_config\_id) | ID of the network connectivity configuration (NCC) that owns the gateway. The NCC must be in the same region as the gateway subnet. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group of the VNet that gets the gateway subnet. | `string` | n/a | yes |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | Name of the existing VNet that gets the gateway subnet. | `string` | n/a | yes |
| <a name="input_attach_nat_gateway"></a> [attach\_nat\_gateway](#input\_attach\_nat\_gateway) | Associate nat\_gateway\_id with the gateway subnet. Needed for internet-bound traffic in ALL\_TRAFFIC mode unless another egress path (for example a firewall route) exists. | `bool` | `false` | no |
| <a name="input_bandwidth_tier_gbps"></a> [bandwidth\_tier\_gbps](#input\_bandwidth\_tier\_gbps) | Provisioned gateway bandwidth tier in Gbps: 10, 30, 50 or 100. | `number` | `10` | no |
| <a name="input_destinations"></a> [destinations](#input\_destinations) | DNS names routed through the gateway in SPECIFIC\_DESTINATIONS mode (1-100). Suffix matching applies: mydb.contoso.com also matches sub.mydb.contoso.com. Must be empty for ALL\_TRAFFIC. | `list(string)` | `[]` | no |
| <a name="input_gateway_destroy_wait"></a> [gateway\_destroy\_wait](#input\_gateway\_destroy\_wait) | How long to wait on destroy after the gateway is deleted, before deleting the subnet and NAT association and releasing the NCC. Gateway cleanup continues after the delete call returns, and the subnet and NCC cannot be deleted until it finishes. Duration string, for example 30m. | `string` | `"30m"` | no |
| <a name="input_gateway_subnet_name"></a> [gateway\_subnet\_name](#input\_gateway\_subnet\_name) | Name of the dedicated gateway subnet created by this module. | `string` | `"private-network-gateway"` | no |
| <a name="input_nat_gateway_id"></a> [nat\_gateway\_id](#input\_nat\_gateway\_id) | Resource ID of the NAT gateway to associate with the gateway subnet. Required when attach\_nat\_gateway is true. | `string` | `null` | no |
| <a name="input_private_dns_resolvers"></a> [private\_dns\_resolvers](#input\_private\_dns\_resolvers) | Custom DNS resolver IPv4 addresses reachable from the gateway subnet (at most 2). Leave empty to use Azure-provided DNS, which is the recommended setting. | `list(string)` | `[]` | no |
| <a name="input_traffic_mode"></a> [traffic\_mode](#input\_traffic\_mode) | SPECIFIC\_DESTINATIONS routes only the listed DNS names through the gateway. ALL\_TRAFFIC routes all remaining serverless egress through the gateway. | `string` | `"SPECIFIC_DESTINATIONS"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_gateway_error_message"></a> [gateway\_error\_message](#output\_gateway\_error\_message) | Error message reported by the API when the gateway is FAILED. |
| <a name="output_gateway_id"></a> [gateway\_id](#output\_gateway\_id) | ID of the gateway (last segment of gateway\_name). |
| <a name="output_gateway_name"></a> [gateway\_name](#output\_gateway\_name) | Full resource name of the gateway: accounts/<account\_id>/network-connectivity-configs/<ncc\_id>/private-network-gateways/<gateway\_id>. |
| <a name="output_gateway_state"></a> [gateway\_state](#output\_gateway\_state) | Gateway state reported by the API: CREATING, ESTABLISHED or FAILED. FAILED is terminal: delete and recreate the gateway. |
| <a name="output_gateway_subnet_id"></a> [gateway\_subnet\_id](#output\_gateway\_subnet\_id) | Resource ID of the delegated gateway subnet. |
<!-- END_TF_DOCS -->
