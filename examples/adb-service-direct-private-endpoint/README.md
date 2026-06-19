# Example — inbound "service-direct" Private Link (performance-intensive services)

Deploys the [`adb-service-direct-private-endpoint`](../../modules/adb-service-direct-private-endpoint)
module: an Azure private endpoint to the Databricks per-region Private Link
Service for performance-intensive services (Zerobus Ingest, Lakebase
Autoscaling), the `privatelink.azuredatabricks.net` DNS A record
(`<region>.service-direct`), and the account-side `databricks_endpoint`
registration that drives it from `PENDING` to `APPROVED`.

> **Note**
> This feature and the `databricks_endpoint` resource are both in **Public
> Preview**. Run `terraform plan` and inspect carefully before applying.

## Prerequisites

* A **Premium-tier** Databricks account with the **"Private connectivity for
  performance-intensive services"** Public Preview feature enabled in the
  account console.
* An existing VNet + a dedicated subnet for the private endpoint (PE network
  policies disabled — the Azure default).
* The per-region PLS resource ID from the
  [Microsoft Learn region table](https://learn.microsoft.com/en-us/azure/databricks/resources/ip-domain-region#service-direct-resource-ids).

## How to use

1. Copy `terraform.tfvars` and fill in your values.
2. `terraform init`
3. `terraform plan`
4. `terraform apply`
5. Confirm `endpoint_state` is `APPROVED` and `endpoint_use_case` is
   `SERVICE_DIRECT` in the outputs.

> **Authentication — account provider**
> The `databricks_endpoint` registration uses an **account-level** provider
> (`host` + `account_id`). All Azure Databricks accounts share the host
> `accounts.azuredatabricks.net`, so if you have more than one account profile
> in `~/.databrickscfg`, the CLI auth resolver cannot pick one and `apply`
> fails with `... match https://accounts.azuredatabricks.net ... Use --profile`.
> Disambiguate by exporting `DATABRICKS_CONFIG_PROFILE=<your-account-profile>`
> (or add `profile = "<name>"` to the `databricks.accounts` provider block).

> **Approval is asynchronous**
> After `apply`, `endpoint_state` is typically `PENDING` — Databricks approves
> the cross-tenant connection out-of-band, usually within a few minutes. This
> is expected, not a failure. Run `terraform refresh` (or re-`plan`) after a
> few minutes to see `APPROVED`; the Azure private endpoint connection flips
> from `Pending` to `Approved` at the same time.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | 2.0.1 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.31.0 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >=1.107.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >=0.9.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_adb-service-direct-private-endpoint"></a> [adb-service-direct-private-endpoint](#module\_adb-service-direct-private-endpoint) | ../../modules/adb-service-direct-private-endpoint | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_azure_region"></a> [azure\_region](#input\_azure\_region) | Azure region short name (e.g. australiaeast). Must match your workspace region. | `string` | n/a | yes |
| <a name="input_azure_subscription_id"></a> [azure\_subscription\_id](#input\_azure\_subscription\_id) | Azure subscription ID to deploy into. | `string` | n/a | yes |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | Databricks account ID (UUID). | `string` | n/a | yes |
| <a name="input_databricks_pls_resource_id"></a> [databricks\_pls\_resource\_id](#input\_databricks\_pls\_resource\_id) | Databricks per-region PLS resource ID for performance-intensive services (from the MS Learn region table). | `string` | n/a | yes |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | Resource ID of an existing subnet to host the private endpoint (PE network policies disabled). | `string` | n/a | yes |
| <a name="input_create_private_dns_zone"></a> [create\_private\_dns\_zone](#input\_create\_private\_dns\_zone) | Create privatelink.azuredatabricks.net here, or reuse an existing zone. | `bool` | `true` | no |
| <a name="input_databricks_host"></a> [databricks\_host](#input\_databricks\_host) | Databricks account console host. | `string` | `"https://accounts.azuredatabricks.net"` | no |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | Name of the resource group to create for the private endpoint and DNS zone. | `string` | `"rg-service-direct-pe"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to created resources. | `map(string)` | `{}` | no |
| <a name="input_vnet_ids_to_link"></a> [vnet\_ids\_to\_link](#input\_vnet\_ids\_to\_link) | VNet IDs to link to the DNS zone (used only when create\_private\_dns\_zone = true). | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_dns_fqdn"></a> [dns\_fqdn](#output\_dns\_fqdn) | Resolvable FQDN for service-direct (<region>.service-direct.privatelink.azuredatabricks.net). |
| <a name="output_endpoint_state"></a> [endpoint\_state](#output\_endpoint\_state) | Account-side endpoint state. Must be APPROVED to be usable. |
| <a name="output_endpoint_use_case"></a> [endpoint\_use\_case](#output\_endpoint\_use\_case) | Endpoint use\_case — expected SERVICE\_DIRECT. |
| <a name="output_private_endpoint_name"></a> [private\_endpoint\_name](#output\_private\_endpoint\_name) | Name of the Azure private endpoint. |
| <a name="output_private_ip_address"></a> [private\_ip\_address](#output\_private\_ip\_address) | Private IP assigned to the private endpoint. |
<!-- END_TF_DOCS -->
