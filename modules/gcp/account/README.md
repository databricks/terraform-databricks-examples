# modules/gcp/account

All `databricks_mws_*` resources for the GCP composer: `mws_networks`, `mws_workspaces`, `mws_vpc_endpoint`, `mws_private_access_settings`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >= 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | 1.114.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [databricks_mws_networks.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_networks) | resource |
| [databricks_mws_private_access_settings.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_private_access_settings) | resource |
| [databricks_mws_vpc_endpoint.backend](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_vpc_endpoint) | resource |
| [databricks_mws_vpc_endpoint.frontend](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_vpc_endpoint) | resource |
| [databricks_mws_vpc_endpoint.transit](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_vpc_endpoint) | resource |
| [databricks_mws_workspaces.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_workspaces) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | n/a | `string` | n/a | yes |
| <a name="input_google_project"></a> [google\_project](#input\_google\_project) | n/a | `string` | n/a | yes |
| <a name="input_google_region"></a> [google\_region](#input\_google\_region) | n/a | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | n/a | `string` | n/a | yes |
| <a name="input_suffix"></a> [suffix](#input\_suffix) | n/a | `string` | n/a | yes |
| <a name="input_vpc_source"></a> [vpc\_source](#input\_vpc\_source) | n/a | `string` | n/a | yes |
| <a name="input_backend_psc_fr_id"></a> [backend\_psc\_fr\_id](#input\_backend\_psc\_fr\_id) | n/a | `string` | `null` | no |
| <a name="input_enable_backend"></a> [enable\_backend](#input\_enable\_backend) | n/a | `bool` | `false` | no |
| <a name="input_enable_frontend"></a> [enable\_frontend](#input\_enable\_frontend) | n/a | `bool` | `false` | no |
| <a name="input_frontend_psc_fr_id"></a> [frontend\_psc\_fr\_id](#input\_frontend\_psc\_fr\_id) | Forwarding-rule names from private-connectivity module (gate vpc\_endpoint creation) | `string` | `null` | no |
| <a name="input_hub_frontend_psc_fr_id"></a> [hub\_frontend\_psc\_fr\_id](#input\_hub\_frontend\_psc\_fr\_id) | n/a | `string` | `null` | no |
| <a name="input_hub_vpc_google_project"></a> [hub\_vpc\_google\_project](#input\_hub\_vpc\_google\_project) | n/a | `string` | `null` | no |
| <a name="input_nat_dependency"></a> [nat\_dependency](#input\_nat\_dependency) | Opaque value used as depends\_on for the workspace to ensure NAT readiness | `any` | `null` | no |
| <a name="input_private_access_only"></a> [private\_access\_only](#input\_private\_access\_only) | n/a | `bool` | `false` | no |
| <a name="input_spoke_subnet_name"></a> [spoke\_subnet\_name](#input\_spoke\_subnet\_name) | n/a | `string` | `null` | no |
| <a name="input_spoke_vpc_google_project"></a> [spoke\_vpc\_google\_project](#input\_spoke\_vpc\_google\_project) | n/a | `string` | `null` | no |
| <a name="input_spoke_vpc_name"></a> [spoke\_vpc\_name](#input\_spoke\_vpc\_name) | n/a | `string` | `null` | no |
| <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name) | n/a | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend_endpoint_id"></a> [backend\_endpoint\_id](#output\_backend\_endpoint\_id) | Backend mws\_vpc\_endpoint ID (null when no PSC) |
| <a name="output_frontend_endpoint_id"></a> [frontend\_endpoint\_id](#output\_frontend\_endpoint\_id) | Frontend mws\_vpc\_endpoint ID (null when no PSC) |
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | mws\_networks ID (null when databricks\_managed) |
| <a name="output_transit_endpoint_id"></a> [transit\_endpoint\_id](#output\_transit\_endpoint\_id) | Hub-side mws\_vpc\_endpoint ID (null when no hub) |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | Databricks workspace ID |
| <a name="output_workspace_url"></a> [workspace\_url](#output\_workspace\_url) | Databricks workspace URL |
<!-- END_TF_DOCS -->
