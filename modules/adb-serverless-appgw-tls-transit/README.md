# Serverless → TLS service via Application Gateway v2 TCP/TLS transit

This module provides private connectivity from **Databricks Serverless compute**
to an external **TLS-over-TCP service behind Azure Private Link** — generic for
**Apache Kafka** (Confluent Cloud, self-hosted, Aiven, MSK-on-Azure-peer) and
any other TLS workload — using an **Azure Application Gateway v2 TCP/TLS proxy**
as a customer-tenant transit.

```
Databricks Serverless ──NCC PE rule──▶ App Gateway v2 (TCP/TLS listener, Private Link)
                                              │ passes TLS through (no termination)
                                              ▼
                                      backend = your TLS service (Kafka, etc.)
```

The TCP/TLS listener **passes TLS through end-to-end** — the App Gateway never
terminates TLS or sees plaintext, so client↔broker (m)TLS is preserved.

## Why a transit is required

Databricks Serverless reaches external services only via **NCC private endpoint
rules**, which target an Azure **resource ID** (not a Private Link alias).
SaaS Kafka (e.g. Confluent Cloud) publishes a cross-tenant PLS *alias*, and an
Azure Standard Load Balancer can't use private-endpoint IPs as backends — so a
customer-tenant L4 proxy is required in between. App Gateway v2's TCP/TLS proxy
(GA 2025-11-26) is the managed-PaaS implementation of that proxy.

## Why the NCC rule uses the REST API (not the Terraform resource)

Per [Microsoft Learn](https://learn.microsoft.com/en-us/azure/databricks/security/network/serverless-network-security/serverless-private-link#configure-private-link-to-azure-app-gateway-v2),
an Application Gateway target **requires `resource_id` + `group_id` + `domain_names`
together**, and **must be configured via the Network Connectivity Configurations
REST API** (the account-console UI doesn't support App Gateway). The Terraform
`databricks_mws_ncc_private_endpoint_rule` resource forbids `group_id` alongside
`domain_names`, so it cannot express this case. This module therefore creates the
rule via `az` + `curl` (a `null_resource`) — this is the **documented method**,
not a workaround. The `group_id` is the App Gateway **frontend IP configuration
name** that carries the Private Link configuration (`frontend-public` here).

## Module content

* Resource group, transit VNet, App Gateway subnet, and App Gateway Private Link subnet.
* Public IP (required by the Standard_v2 SKU).
* Application Gateway v2 (via `azapi`) with a **TCP listener**, a backend pool of
  your target addresses, TCP backend settings, and a Private Link configuration.
* Databricks NCC + workspace binding.
* The NCC **private endpoint rule** for the App Gateway, via the documented REST API.
* (Optional) auto-approval of the inbound private endpoint connection on the App Gateway.

## Prerequisites

* Premium-tier Databricks account; you must be an **account admin**.
* The **`az` CLI authenticated** as that account admin on the machine running
  terraform (used for the REST NCC rule + PE approval).
* Connectivity from the App Gateway VNet to your `backend_addresses` (in-VNet,
  VNet peering, or a private endpoint to the provider's PLS — your responsibility).
* For Kafka: the broker `advertised.listeners` must return FQDNs that are in
  `serverless_domain_names`, or the second-hop connection fails.

## Known limitations

* The REST-created NCC rule is **create-only** — `terraform destroy` does not
  remove it, and changing `serverless_domain_names` requires manual cleanup (use
  the PATCH/DELETE operations in the [NCC API](https://docs.databricks.com/api/azure/account/networkconnectivity)).
* Not exercised by `terraform validate` (the rule + approval are `local-exec`).

## How to use

> **Note**
> A deployment example using this module can be found in
> [examples/adb-serverless-appgw-tls-transit](../../examples/adb-serverless-appgw-tls-transit)

1. Reference this module using one of the different [module source types](https://developer.hashicorp.com/terraform/language/modules/sources)
2. Add a `variables.tf` with the same content as [variables.tf](variables.tf)
3. Add a `terraform.tfvars` file and provide values to each defined variable
4. Add an `outputs.tf` file
5. Run `terraform init`
6. Run `terraform apply`

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | 2.0.1 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.31.0 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >=1.81.1 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >=3.2.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >=0.9.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | 2.0.1 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=4.31.0 |
| <a name="provider_databricks.accounts"></a> [databricks.accounts](#provider\_databricks.accounts) | >=1.81.1 |
| <a name="provider_null"></a> [null](#provider\_null) | >=3.2.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >=0.9.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [azapi_resource.appgw](https://registry.terraform.io/providers/Azure/azapi/2.0.1/docs/resources/resource) | resource |
| [azurerm_public_ip.appgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.appgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.appgw_pls](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.transit](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [databricks_mws_ncc_binding.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_ncc_binding) | resource |
| [databricks_mws_network_connectivity_config.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_network_connectivity_config) | resource |
| [null_resource.approve_pe_on_appgw](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.ncc_pe_rule_appgw](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [time_sleep.wait_for_pe](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_azure_region"></a> [azure\_region](#input\_azure\_region) | Azure region short name (e.g. australiaeast). Must match your Databricks workspace/NCC region. | `string` | n/a | yes |
| <a name="input_azure_subscription_id"></a> [azure\_subscription\_id](#input\_azure\_subscription\_id) | Azure subscription ID to deploy the transit into. | `string` | n/a | yes |
| <a name="input_backend_addresses"></a> [backend\_addresses](#input\_backend\_addresses) | Backend target addresses reachable from the App Gateway VNet — the IPs (or FQDNs) of the TLS service (e.g. Kafka brokers, an internal load balancer, or a private endpoint to a provider PLS). You are responsible for connectivity from the App Gateway VNet to these addresses (in-VNet, VNet peering, or a private endpoint). | `list(string)` | n/a | yes |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | Databricks account ID (UUID). | `string` | n/a | yes |
| <a name="input_databricks_workspace_id"></a> [databricks\_workspace\_id](#input\_databricks\_workspace\_id) | Databricks workspace ID to bind the NCC to. | `string` | n/a | yes |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | Name of the resource group to create for the transit (VNet, App Gateway, public IP). | `string` | n/a | yes |
| <a name="input_serverless_domain_names"></a> [serverless\_domain\_names](#input\_serverless\_domain\_names) | FQDNs that Databricks Serverless clients will dial (e.g. Kafka bootstrap + per-broker/wildcard FQDNs). NCC injects DNS so these resolve to the Databricks-managed private endpoint. Max 10 per rule. | `list(string)` | n/a | yes |
| <a name="input_appgw_capacity"></a> [appgw\_capacity](#input\_appgw\_capacity) | Fixed instance capacity for the Application Gateway v2 (Standard\_v2). | `number` | `2` | no |
| <a name="input_appgw_frontend_private_ip"></a> [appgw\_frontend\_private\_ip](#input\_appgw\_frontend\_private\_ip) | Static private IP for the App Gateway private frontend (must be inside appgw\_subnet\_prefix). | `string` | `"10.230.1.100"` | no |
| <a name="input_appgw_name"></a> [appgw\_name](#input\_appgw\_name) | Name of the Application Gateway. | `string` | `"appgw-serverless-transit"` | no |
| <a name="input_appgw_pls_subnet_prefix"></a> [appgw\_pls\_subnet\_prefix](#input\_appgw\_pls\_subnet\_prefix) | Address prefix for the Application Gateway Private Link subnet (hosts the PL config IP configuration). | `string` | `"10.230.2.0/24"` | no |
| <a name="input_appgw_subnet_prefix"></a> [appgw\_subnet\_prefix](#input\_appgw\_subnet\_prefix) | Address prefix for the Application Gateway subnet. | `string` | `"10.230.1.0/24"` | no |
| <a name="input_auto_approve_private_endpoint"></a> [auto\_approve\_private\_endpoint](#input\_auto\_approve\_private\_endpoint) | Automatically approve the Databricks private endpoint connection on the App Gateway (via az CLI). Set false to approve manually in the Azure portal (NCC docs Step 4). | `bool` | `true` | no |
| <a name="input_backend_port"></a> [backend\_port](#input\_backend\_port) | Backend port to forward to. Defaults to listener\_port when null. | `number` | `null` | no |
| <a name="input_databricks_host"></a> [databricks\_host](#input\_databricks\_host) | Databricks account console host. The NCC resources require an account-level provider. | `string` | `"https://accounts.azuredatabricks.net"` | no |
| <a name="input_listener_port"></a> [listener\_port](#input\_listener\_port) | TCP port the TLS service listens on and that clients connect to (e.g. 9092/9094 for Kafka). | `number` | `9092` | no |
| <a name="input_ncc_name"></a> [ncc\_name](#input\_ncc\_name) | Name for the Network Connectivity Configuration. | `string` | `"ncc-appgw-transit"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to created resources. | `map(string)` | `{}` | no |
| <a name="input_vnet_address_space"></a> [vnet\_address\_space](#input\_vnet\_address\_space) | Address space for the transit VNet. | `list(string)` | <pre>[<br/>  "10.230.0.0/16"<br/>]</pre> | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_appgw_frontend_config_name"></a> [appgw\_frontend\_config\_name](#output\_appgw\_frontend\_config\_name) | Frontend IP configuration name that carries the Private Link config — this is the group\_id used by the NCC private endpoint rule. |
| <a name="output_appgw_id"></a> [appgw\_id](#output\_appgw\_id) | Resource ID of the Application Gateway. |
| <a name="output_appgw_name"></a> [appgw\_name](#output\_appgw\_name) | Name of the Application Gateway. |
| <a name="output_ncc_id"></a> [ncc\_id](#output\_ncc\_id) | Databricks Network Connectivity Configuration ID. |
| <a name="output_public_ip_address"></a> [public\_ip\_address](#output\_public\_ip\_address) | Public IP of the Application Gateway (required by the Standard\_v2 SKU). |
| <a name="output_serverless_domain_names"></a> [serverless\_domain\_names](#output\_serverless\_domain\_names) | FQDNs registered in the NCC rule. Serverless clients dial these; NCC injects DNS to the Databricks-managed private endpoint. |
| <a name="output_transit_vnet_id"></a> [transit\_vnet\_id](#output\_transit\_vnet\_id) | Resource ID of the transit VNet (peer your target service's network to this, or place a private endpoint here). |
<!-- END_TF_DOCS -->
