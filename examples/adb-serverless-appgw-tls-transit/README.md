# Serverless compute to a TLS service through Application Gateway v2

This example deploys the [`adb-serverless-appgw-tls-transit`](../../modules/adb-serverless-appgw-tls-transit) module. It connects Databricks Serverless compute to a customer-managed TLS-over-TCP service (for example, Confluent Cloud Kafka) through an Azure Application Gateway v2 TCP proxy and the Databricks Network Connectivity Configuration (NCC) service.

```text
Databricks Serverless -> NCC private endpoint -> Application Gateway v2
                                                    -> TLS backend
```

The Application Gateway passes encrypted TCP/TLS traffic through; it does not terminate TLS. The target service must be reachable from the transit VNet using a private endpoint, VNet peering, or another private route. This example accepts backend IPv4 addresses or FQDNs and does not provision the target service.

## Prerequisites

* A Premium Azure Databricks account and account-admin permissions.
* An Azure subscription and permissions to create a VNet, subnets, NSG, public IP, and Application Gateway.
* Azure CLI authenticated as a Databricks account admin. The module uses the documented Network Connectivity Configurations REST API because Application Gateway rules require `resource_id`, `group_id`, and `domain_names` together.
* A TLS-over-TCP backend reachable from the transit VNet and the FQDNs that Serverless clients dial. For Kafka, include the bootstrap FQDN and the broker names returned in metadata.

## How to use

1. Update `terraform.tfvars` with your Azure, Databricks, backend, and DNS values.
2. Run `terraform init`.
3. Run `terraform plan` and `terraform apply`.
4. Approve the pending private endpoint connection on the Application Gateway, unless `auto_approve_private_endpoint` is enabled and the Azure CLI identity can approve it.
5. Wait until the NCC private endpoint rule is `ESTABLISHED`, restart Serverless compute, and test the TLS service.

The Standard_v2 SKU currently requires a public IP resource for gateway management. The example creates that resource but does not bind a listener to the public frontend. Databricks traffic uses the private frontend exposed through Application Gateway Private Link. If your subscription has Azure network isolation enabled and no public IP is required, adjust the Application Gateway definition accordingly.

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
| <a name="input_azure_region"></a> [azure\_region](#input\_azure\_region) | Azure region short name. Must match the workspace and NCC region. | `string` | n/a | yes |
| <a name="input_azure_subscription_id"></a> [azure\_subscription\_id](#input\_azure\_subscription\_id) | Azure subscription ID to deploy into. | `string` | n/a | yes |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | Databricks account ID (UUID). | `string` | n/a | yes |
| <a name="input_databricks_workspace_id"></a> [databricks\_workspace\_id](#input\_databricks\_workspace\_id) | Databricks workspace ID to bind to the NCC. | `string` | n/a | yes |
| <a name="input_serverless_domain_names"></a> [serverless\_domain\_names](#input\_serverless\_domain\_names) | FQDNs that serverless clients dial. The NCC rule supports at most 10 names. | `list(string)` | n/a | yes |
| <a name="input_appgw_capacity"></a> [appgw\_capacity](#input\_appgw\_capacity) | Fixed Standard\_v2 Application Gateway instance capacity. | `number` | `2` | no |
| <a name="input_appgw_name"></a> [appgw\_name](#input\_appgw\_name) | Application Gateway name. | `string` | `"appgw-serverless-transit"` | no |
| <a name="input_auto_approve_private_endpoint"></a> [auto\_approve\_private\_endpoint](#input\_auto\_approve\_private\_endpoint) | Attempt to approve the Databricks-created private endpoint with Azure CLI. | `bool` | `false` | no |
| <a name="input_backend_addresses"></a> [backend\_addresses](#input\_backend\_addresses) | IPv4 addresses of TLS backends reachable from the transit VNet. | `list(string)` | `[]` | no |
| <a name="input_backend_fqdns"></a> [backend\_fqdns](#input\_backend\_fqdns) | FQDNs of TLS backends reachable from the transit VNet. | `list(string)` | `[]` | no |
| <a name="input_backend_port"></a> [backend\_port](#input\_backend\_port) | TCP/TLS port used by the backend. Defaults to listener\_port. | `number` | `null` | no |
| <a name="input_databricks_host"></a> [databricks\_host](#input\_databricks\_host) | Databricks account console host. | `string` | `"https://accounts.azuredatabricks.net"` | no |
| <a name="input_listener_port"></a> [listener\_port](#input\_listener\_port) | TCP/TLS port exposed by the Application Gateway. | `number` | `9092` | no |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | Resource group to create for the transit resources. | `string` | `"rg-appgw-tls-transit"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to created resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_appgw_frontend_config_name"></a> [appgw\_frontend\_config\_name](#output\_appgw\_frontend\_config\_name) | Frontend configuration name used as the NCC rule group\_id. |
| <a name="output_appgw_id"></a> [appgw\_id](#output\_appgw\_id) | Resource ID of the Application Gateway. |
| <a name="output_ncc_id"></a> [ncc\_id](#output\_ncc\_id) | Databricks NCC ID. |
| <a name="output_serverless_domain_names"></a> [serverless\_domain\_names](#output\_serverless\_domain\_names) | FQDNs registered in the NCC private endpoint rule. |
| <a name="output_transit_vnet_id"></a> [transit\_vnet\_id](#output\_transit\_vnet\_id) | Transit VNet ID. Peer the target service network here or place a private endpoint in it. |
<!-- END_TF_DOCS -->
