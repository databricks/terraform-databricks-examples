# Inbound "service-direct" Private Link for performance-intensive services

This module configures inbound (front-end) **"service-direct" Private Link** to
Databricks **performance-intensive services** — currently **Zerobus Ingest** and
**Lakebase Autoscaling** — on Azure.

It is distinct from classic workspace front-end Private Link (the
`databricks_ui_api` sub-resource): service-direct targets a Databricks-published
**per-region Private Link Service** with the target sub-resource `service_direct`,
is registered at the **account level**, and reuses the
`privatelink.azuredatabricks.net` DNS zone.

> **Note**
> This feature and the `databricks_endpoint` resource (provider `>=1.107.0`) are
> both in **Public Preview**. Validate with `terraform plan/apply` before
> production use.

## Module content

This module deploys:

* A resource group (`rg_name`) to hold the private endpoint and DNS resources.
* An **Azure private endpoint** to the Databricks per-region performance-intensive
  services Private Link Service, target sub-resource `service_direct`
  (`is_manual_connection = true`).
* The **`privatelink.azuredatabricks.net` private DNS zone** (optional — reuse an
  existing one), VNet links, and an **A record `<region>.service-direct`** pointing
  at the private endpoint's IP.
* A **`databricks_endpoint`** registration on the account side, which drives the
  private endpoint from `PENDING` to `APPROVED` (`use_case = SERVICE_DIRECT`).

The PE's `properties.resourceGuid` (required by `databricks_endpoint`) is read via
the `azapi` provider, because `azurerm` does not export it.

## Prerequisites

* A **Premium-tier** Databricks account.
* The **"Private connectivity for performance-intensive services"** Public Preview
  feature enabled on the account (self-enroll in the account console) — otherwise
  the registration surface does not appear.
* An existing subnet for the private endpoint (private-endpoint network policies
  disabled — the Azure default).
* The per-region PLS resource ID from the
  [Microsoft Learn region table](https://learn.microsoft.com/en-us/azure/databricks/resources/ip-domain-region#service-direct-resource-ids).

## Important to know

* **Account-level + regional blast radius.** Registering this endpoint affects
  **all Premium workspaces in the region** — it is not workspace-scoped. Limits:
  5 per region, 100 per account.
* **PLS + sub-resource shape (Preview).** Uses `private_connection_resource_id` +
  `subresource_names = ["service_direct"]` per Microsoft Learn. If a future change
  treats the target as a pure Private Link Service, switch to
  `private_connection_resource_alias` and drop `subresource_names`.

## How to use

> **Note**
> You can customize this module by adding, deleting or updating the resources to
> adapt it to your requirements.
> A deployment example using this module can be found in
> [examples/adb-service-direct-private-endpoint](../../examples/adb-service-direct-private-endpoint)

1. Reference this module using one of the different [module source types](https://developer.hashicorp.com/terraform/language/modules/sources)
2. Add a `variables.tf` with the same content as [variables.tf](variables.tf)
3. Add a `terraform.tfvars` file and provide values to each defined variable
4. Add an `outputs.tf` file
5. (Optional) Configure your [remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm)
6. Run `terraform init` to initialize terraform and get the providers ready
7. Run `terraform apply` to create the resources

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | 2.0.1 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.31.0 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >=1.107.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >=0.9.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | 2.0.1 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=4.31.0 |
| <a name="provider_databricks.accounts"></a> [databricks.accounts](#provider\_databricks.accounts) | >=1.107.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >=0.9.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_private_dns_a_record.service_direct](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) | resource |
| [azurerm_private_dns_zone.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [databricks_endpoint.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/endpoint) | resource |
| [time_sleep.wait_for_pe](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [azapi_resource.pe](https://registry.terraform.io/providers/Azure/azapi/2.0.1/docs/data-sources/resource) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_azure_region"></a> [azure\_region](#input\_azure\_region) | Azure region short name (e.g. australiaeast, westus2). Used for the resource group/PE location, the <region>.service-direct DNS A record, and the databricks\_endpoint region. Must match your workspace region. | `string` | n/a | yes |
| <a name="input_azure_subscription_id"></a> [azure\_subscription\_id](#input\_azure\_subscription\_id) | Azure subscription ID to deploy the private endpoint and DNS into. | `string` | n/a | yes |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | Databricks account ID (UUID). | `string` | n/a | yes |
| <a name="input_databricks_pls_resource_id"></a> [databricks\_pls\_resource\_id](#input\_databricks\_pls\_resource\_id) | Databricks-published Private Link Service resource ID for performance-intensive services in your region. These are per-region and managed by Databricks — pull the current value from the Microsoft Learn region table (Service-direct resource IDs): https://learn.microsoft.com/en-us/azure/databricks/resources/ip-domain-region#service-direct-resource-ids | `string` | n/a | yes |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | Resource ID of an existing subnet to host the private endpoint. Private endpoint network policies must be disabled (the Azure default); use a subnet separate from the workspace's own subnets if you reuse the workspace VNet. | `string` | n/a | yes |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | Name of the resource group to create for the private endpoint (and the private DNS zone, when this module creates it). | `string` | n/a | yes |
| <a name="input_create_private_dns_zone"></a> [create\_private\_dns\_zone](#input\_create\_private\_dns\_zone) | Whether to create the privatelink.azuredatabricks.net private DNS zone. Set false to reuse an existing zone (common when the workspace already uses inbound Private Link); the A record is added to the existing zone. | `bool` | `true` | no |
| <a name="input_databricks_host"></a> [databricks\_host](#input\_databricks\_host) | Databricks account console host. databricks\_endpoint requires an account-level provider. | `string` | `"https://accounts.azuredatabricks.net"` | no |
| <a name="input_dns_a_record_ttl"></a> [dns\_a\_record\_ttl](#input\_dns\_a\_record\_ttl) | TTL (seconds) for the <region>.service-direct A record. | `number` | `3600` | no |
| <a name="input_endpoint_display_name"></a> [endpoint\_display\_name](#input\_endpoint\_display\_name) | Display name for the databricks\_endpoint registration. Must be RFC-1034 compliant (letters, numbers, hyphens; starts with a letter; <= 63 chars). | `string` | `"service-direct-pe"` | no |
| <a name="input_private_dns_zone_name"></a> [private\_dns\_zone\_name](#input\_private\_dns\_zone\_name) | Name of the private DNS zone. service-direct shares the workspace front-end Private Link zone. | `string` | `"privatelink.azuredatabricks.net"` | no |
| <a name="input_private_endpoint_name"></a> [private\_endpoint\_name](#input\_private\_endpoint\_name) | Name of the Azure private endpoint. | `string` | `"pe-service-direct"` | no |
| <a name="input_request_message"></a> [request\_message](#input\_request\_message) | Request message attached to the manual private-endpoint connection. | `string` | `"Databricks service-direct private endpoint (performance-intensive services)"` | no |
| <a name="input_subresource_name"></a> [subresource\_name](#input\_subresource\_name) | Target sub-resource (group ID) for the private endpoint connection. Per Microsoft Learn this is service\_direct (underscore). Exposed only so it can be overridden if Databricks changes the published group ID during Public Preview. | `string` | `"service_direct"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all created resources. | `map(string)` | `{}` | no |
| <a name="input_vnet_ids_to_link"></a> [vnet\_ids\_to\_link](#input\_vnet\_ids\_to\_link) | VNet IDs to link to the private DNS zone (only used when create\_private\_dns\_zone = true). When reusing an existing zone, manage links separately. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_dns_fqdn"></a> [dns\_fqdn](#output\_dns\_fqdn) | Resolvable FQDN clients use for service-direct (<region>.service-direct.privatelink.azuredatabricks.net). |
| <a name="output_endpoint_id"></a> [endpoint\_id](#output\_endpoint\_id) | Databricks endpoint\_id of the registration. |
| <a name="output_endpoint_state"></a> [endpoint\_state](#output\_endpoint\_state) | State of the registered endpoint. Must be APPROVED to be usable. |
| <a name="output_endpoint_use_case"></a> [endpoint\_use\_case](#output\_endpoint\_use\_case) | use\_case of the registered endpoint — expected SERVICE\_DIRECT. |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | Resource ID of the Azure private endpoint. |
| <a name="output_private_endpoint_name"></a> [private\_endpoint\_name](#output\_private\_endpoint\_name) | Name of the Azure private endpoint. |
| <a name="output_private_endpoint_resource_guid"></a> [private\_endpoint\_resource\_guid](#output\_private\_endpoint\_resource\_guid) | properties.resourceGuid of the private endpoint (read via azapi; consumed by the account-side registration). |
| <a name="output_private_ip_address"></a> [private\_ip\_address](#output\_private\_ip\_address) | Private IP assigned to the private endpoint. |
<!-- END_TF_DOCS -->
