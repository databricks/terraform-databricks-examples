# Serverless compute to a TLS service through Application Gateway v2

This module provides private connectivity from **Databricks Serverless compute** to a customer-managed **TLS-over-TCP service** (for example, Confluent Cloud Kafka) through an Azure Application Gateway v2 TCP proxy and a Databricks Network Connectivity Configuration (NCC).

```text
Databricks Serverless -- NCC private endpoint --> App Gateway v2 -- TLS/TCP --> backend service
```

The listener passes encrypted TCP/TLS traffic through end-to-end. Application Gateway does not terminate TLS, so the backend service remains responsible for TLS or mTLS. The module creates the transit VNet, Application Gateway, its native Private Link configuration, and the NCC. It does not create or configure the backend service or its route into the transit VNet.

## Why the NCC rule uses the REST API

The Application Gateway v2 NCC rule requires `resource_id`, `group_id`, and `domain_names` in one request. The Databricks Terraform provider resource does not currently expose this combination, so the module reconciles the rule through the documented Network Connectivity Configurations API. The local machine must have Azure CLI authenticated as a Databricks account admin.

The reconciliation is idempotent: an existing rule matching the Application Gateway resource and frontend group is patched when domain names change instead of creating a duplicate rule. Destroying the module removes that rule.

## Application Gateway public IP

Standard_v2 currently requires a public IP resource for GatewayManager communication. The module creates the required public IP but does not attach a listener to that frontend. The TCP listener and Private Link association use a separate private frontend, and an NSG denies Internet ingress to the Application Gateway subnet while allowing the documented GatewayManager and AzureLoadBalancer service tags.

If Azure network isolation is enabled for the subscription and removes this SKU requirement, review `appgw.tf` before removing the public frontend.

## Prerequisites

* Premium-tier Azure Databricks account and account-admin permissions.
* Azure permissions to create the resource group, VNet, subnets, NSG, public IP, and Application Gateway.
* Azure CLI authenticated as the Databricks account admin running Terraform.
* A TLS-over-TCP backend reachable from the transit VNet through private routing, VNet peering, or a private endpoint.
* All FQDNs that Serverless clients may dial. Kafka deployments should include the bootstrap name and names returned by broker metadata.

## Deployment sequence

1. Apply the module.
2. Approve the pending Application Gateway private endpoint in Azure, unless `auto_approve_private_endpoint` is enabled.
3. Wait for the NCC private endpoint rule to become `ESTABLISHED`.
4. Restart Serverless compute and test the backend connection.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | 2.0.1 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.31.0 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >=1.81.1 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >=3.2.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >=0.9.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | 2.0.1 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 5.1.0 |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | 1.127.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.3.1 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.14.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [azapi_resource.appgw](https://registry.terraform.io/providers/Azure/azapi/2.0.1/docs/resources/resource) | resource |
| [azurerm_network_security_group.appgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_public_ip.appgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.appgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.appgw_pls](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.appgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [databricks_mws_ncc_binding.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_ncc_binding) | resource |
| [databricks_mws_network_connectivity_config.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_network_connectivity_config) | resource |
| [null_resource.approve_private_endpoint](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.ncc_private_endpoint_rule](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [time_sleep.wait_for_private_endpoint](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_azure_region"></a> [azure\_region](#input\_azure\_region) | Azure region short name. Must match the workspace and NCC region. | `string` | n/a | yes |
| <a name="input_azure_subscription_id"></a> [azure\_subscription\_id](#input\_azure\_subscription\_id) | Azure subscription ID to deploy into. | `string` | n/a | yes |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | Databricks account ID (UUID). | `string` | n/a | yes |
| <a name="input_databricks_workspace_id"></a> [databricks\_workspace\_id](#input\_databricks\_workspace\_id) | Databricks workspace ID to bind to the NCC. | `string` | n/a | yes |
| <a name="input_serverless_domain_names"></a> [serverless\_domain\_names](#input\_serverless\_domain\_names) | FQDNs that serverless clients dial. The NCC rule supports at most 10 names. | `list(string)` | n/a | yes |
| <a name="input_appgw_capacity"></a> [appgw\_capacity](#input\_appgw\_capacity) | Fixed Standard\_v2 Application Gateway instance capacity. | `number` | `2` | no |
| <a name="input_appgw_name"></a> [appgw\_name](#input\_appgw\_name) | Application Gateway name. | `string` | `"appgw-serverless-transit"` | no |
| <a name="input_appgw_pls_subnet_prefix"></a> [appgw\_pls\_subnet\_prefix](#input\_appgw\_pls\_subnet\_prefix) | Address prefix for the dedicated Application Gateway Private Link subnet. | `string` | `"10.230.2.0/24"` | no |
| <a name="input_appgw_subnet_prefix"></a> [appgw\_subnet\_prefix](#input\_appgw\_subnet\_prefix) | Address prefix for the Application Gateway subnet. The subnet must provide at least ten usable host addresses. | `string` | `"10.230.1.0/24"` | no |
| <a name="input_auto_approve_private_endpoint"></a> [auto\_approve\_private\_endpoint](#input\_auto\_approve\_private\_endpoint) | Attempt to approve the Databricks-created private endpoint with Azure CLI. | `bool` | `false` | no |
| <a name="input_backend_addresses"></a> [backend\_addresses](#input\_backend\_addresses) | IPv4 addresses of TLS backends reachable from the transit VNet. | `list(string)` | `[]` | no |
| <a name="input_backend_fqdns"></a> [backend\_fqdns](#input\_backend\_fqdns) | FQDNs of TLS backends reachable from the transit VNet. | `list(string)` | `[]` | no |
| <a name="input_backend_port"></a> [backend\_port](#input\_backend\_port) | TCP/TLS port used by the backend. Defaults to listener\_port. | `number` | `null` | no |
| <a name="input_databricks_host"></a> [databricks\_host](#input\_databricks\_host) | Databricks account console host. | `string` | `"https://accounts.azuredatabricks.net"` | no |
| <a name="input_listener_port"></a> [listener\_port](#input\_listener\_port) | TCP/TLS port exposed by the Application Gateway. | `number` | `9092` | no |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | Resource group to create for the transit resources. | `string` | `"rg-appgw-tls-transit"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to created resources. | `map(string)` | `{}` | no |
| <a name="input_vnet_address_space"></a> [vnet\_address\_space](#input\_vnet\_address\_space) | Address space for the transit VNet. | `list(string)` | <pre>[<br/>  "10.230.0.0/16"<br/>]</pre> | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_appgw_frontend_config_name"></a> [appgw\_frontend\_config\_name](#output\_appgw\_frontend\_config\_name) | Private frontend configuration name used as the NCC rule group\_id. |
| <a name="output_appgw_frontend_private_ip"></a> [appgw\_frontend\_private\_ip](#output\_appgw\_frontend\_private\_ip) | Private IP of the Application Gateway listener frontend. |
| <a name="output_appgw_id"></a> [appgw\_id](#output\_appgw\_id) | Resource ID of the Application Gateway. |
| <a name="output_appgw_name"></a> [appgw\_name](#output\_appgw\_name) | Application Gateway name. |
| <a name="output_ncc_id"></a> [ncc\_id](#output\_ncc\_id) | Databricks NCC ID. |
| <a name="output_serverless_domain_names"></a> [serverless\_domain\_names](#output\_serverless\_domain\_names) | FQDNs registered in the NCC private endpoint rule. |
| <a name="output_transit_vnet_id"></a> [transit\_vnet\_id](#output\_transit\_vnet\_id) | Transit VNet ID. |
<!-- END_TF_DOCS -->
