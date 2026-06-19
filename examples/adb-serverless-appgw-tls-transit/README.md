# Example — Serverless → TLS service via App Gateway v2 TCP/TLS transit

Deploys the [`adb-serverless-appgw-tls-transit`](../../modules/adb-serverless-appgw-tls-transit)
module: a customer-tenant Application Gateway v2 TCP/TLS proxy that lets
Databricks Serverless reach an external TLS service (Kafka or any TLS-over-TCP
workload) over Azure Private Link, wired to an NCC private endpoint rule.

## Prerequisites

* Premium-tier Databricks account; you must be an **account admin**.
* The **`az` CLI authenticated** as that account admin (used for the documented
  REST NCC rule + private endpoint approval — see the module README).
* A target TLS service reachable from the transit VNet (set `backend_addresses`),
  and the FQDNs serverless clients dial (set `serverless_domain_names`).

## How to use

1. Copy `terraform.tfvars` and fill in your values.
2. `terraform init`
3. `terraform apply`
4. The module auto-approves the App Gateway private endpoint connection. Confirm
   the NCC rule reaches `ESTABLISHED` in the account console, then restart
   serverless compute and test connectivity to your service.

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

No providers.

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_adb-serverless-appgw-tls-transit"></a> [adb-serverless-appgw-tls-transit](#module\_adb-serverless-appgw-tls-transit) | ../../modules/adb-serverless-appgw-tls-transit | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_azure_region"></a> [azure\_region](#input\_azure\_region) | Azure region short name (e.g. australiaeast). Must match your workspace/NCC region. | `string` | n/a | yes |
| <a name="input_azure_subscription_id"></a> [azure\_subscription\_id](#input\_azure\_subscription\_id) | Azure subscription ID to deploy into. | `string` | n/a | yes |
| <a name="input_backend_addresses"></a> [backend\_addresses](#input\_backend\_addresses) | IPs (or FQDNs) of the target TLS service, reachable from the transit VNet. | `list(string)` | n/a | yes |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | Databricks account ID (UUID). | `string` | n/a | yes |
| <a name="input_databricks_workspace_id"></a> [databricks\_workspace\_id](#input\_databricks\_workspace\_id) | Databricks workspace ID to bind the NCC to. | `string` | n/a | yes |
| <a name="input_serverless_domain_names"></a> [serverless\_domain\_names](#input\_serverless\_domain\_names) | FQDNs serverless clients dial (e.g. Kafka bootstrap + wildcard). Max 10. | `list(string)` | n/a | yes |
| <a name="input_databricks_host"></a> [databricks\_host](#input\_databricks\_host) | Databricks account console host. | `string` | `"https://accounts.azuredatabricks.net"` | no |
| <a name="input_listener_port"></a> [listener\_port](#input\_listener\_port) | TCP/TLS port (e.g. 9092/9094 for Kafka). | `number` | `9092` | no |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | Name of the resource group to create for the transit. | `string` | `"rg-appgw-tls-transit"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to created resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_appgw_frontend_config_name"></a> [appgw\_frontend\_config\_name](#output\_appgw\_frontend\_config\_name) | Frontend config name = the NCC rule group\_id. |
| <a name="output_appgw_id"></a> [appgw\_id](#output\_appgw\_id) | Resource ID of the Application Gateway. |
| <a name="output_ncc_id"></a> [ncc\_id](#output\_ncc\_id) | Databricks NCC ID. |
| <a name="output_serverless_domain_names"></a> [serverless\_domain\_names](#output\_serverless\_domain\_names) | FQDNs serverless clients dial (registered in the NCC rule). |
| <a name="output_transit_vnet_id"></a> [transit\_vnet\_id](#output\_transit\_vnet\_id) | Transit VNet ID — peer your target service network here or place a private endpoint. |
<!-- END_TF_DOCS -->
