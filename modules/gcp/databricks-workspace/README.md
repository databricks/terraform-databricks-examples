# GCP Databricks Workspace Composer

This module creates a complete Databricks workspace on Google Cloud Platform with full networking, connectivity, and authentication management.

## Usage

See the examples in `tests/` for common scenarios.

## Components

- **network**: VPC creation or integration (databricks_managed, create, or existing)
- **private_connectivity**: Private Service Connect (PSC) with optional frontend/backend
- **account**: Databricks MWS resources and workspace
- **dns**: Private DNS zones for restricted egress scenarios

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >= 1.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.4 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.8.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_account"></a> [account](#module\_account) | ../account | n/a |
| <a name="module_dns"></a> [dns](#module\_dns) | ../dns | n/a |
| <a name="module_network"></a> [network](#module\_network) | ../network | n/a |
| <a name="module_private_connectivity"></a> [private\_connectivity](#module\_private\_connectivity) | ../private-connectivity | n/a |

## Resources

| Name | Type |
|------|------|
| [null_resource.preconditions](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | n/a | `string` | n/a | yes |
| <a name="input_google_project"></a> [google\_project](#input\_google\_project) | n/a | `string` | n/a | yes |
| <a name="input_google_region"></a> [google\_region](#input\_google\_region) | n/a | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | === Identity =========================================================== | `string` | n/a | yes |
| <a name="input_existing_subnet_name"></a> [existing\_subnet\_name](#input\_existing\_subnet\_name) | n/a | `string` | `null` | no |
| <a name="input_existing_vpc_name"></a> [existing\_vpc\_name](#input\_existing\_vpc\_name) | When vpc\_source = "existing" | `string` | `null` | no |
| <a name="input_hive_metastore_ip"></a> [hive\_metastore\_ip](#input\_hive\_metastore\_ip) | n/a | `string` | `null` | no |
| <a name="input_hub_vpc_cidr"></a> [hub\_vpc\_cidr](#input\_hub\_vpc\_cidr) | n/a | `string` | `null` | no |
| <a name="input_hub_vpc_google_project"></a> [hub\_vpc\_google\_project](#input\_hub\_vpc\_google\_project) | === Required when restricted\_egress = true ============================= | `string` | `null` | no |
| <a name="input_is_spoke_vpc_shared"></a> [is\_spoke\_vpc\_shared](#input\_is\_spoke\_vpc\_shared) | n/a | `bool` | `false` | no |
| <a name="input_pod_cidr"></a> [pod\_cidr](#input\_pod\_cidr) | n/a | `string` | `null` | no |
| <a name="input_private_access_only"></a> [private\_access\_only](#input\_private\_access\_only) | n/a | `bool` | `false` | no |
| <a name="input_private_link_backend"></a> [private\_link\_backend](#input\_private\_link\_backend) | n/a | `bool` | `false` | no |
| <a name="input_private_link_frontend"></a> [private\_link\_frontend](#input\_private\_link\_frontend) | === Connectivity feature flags ========================================= | `bool` | `false` | no |
| <a name="input_psc_subnet_cidr"></a> [psc\_subnet\_cidr](#input\_psc\_subnet\_cidr) | n/a | `string` | `null` | no |
| <a name="input_restricted_egress"></a> [restricted\_egress](#input\_restricted\_egress) | n/a | `bool` | `false` | no |
| <a name="input_spoke_vpc_cidr"></a> [spoke\_vpc\_cidr](#input\_spoke\_vpc\_cidr) | When vpc\_source = "create" | `string` | `null` | no |
| <a name="input_spoke_vpc_google_project"></a> [spoke\_vpc\_google\_project](#input\_spoke\_vpc\_google\_project) | n/a | `string` | `null` | no |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | n/a | `string` | `null` | no |
| <a name="input_svc_cidr"></a> [svc\_cidr](#input\_svc\_cidr) | n/a | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |
| <a name="input_vpc_source"></a> [vpc\_source](#input\_vpc\_source) | One of: databricks\_managed, create, existing | `string` | `"databricks_managed"` | no |
| <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name) | n/a | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hub_vpc_id"></a> [hub\_vpc\_id](#output\_hub\_vpc\_id) | Hub VPC ID (null when not restricted\_egress) |
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | mws\_networks ID (null when databricks\_managed) |
| <a name="output_spoke_vpc_id"></a> [spoke\_vpc\_id](#output\_spoke\_vpc\_id) | Spoke VPC ID (null when databricks\_managed) |
| <a name="output_suffix"></a> [suffix](#output\_suffix) | Random suffix used in resource names |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | Spoke VPC ID (null when databricks\_managed) |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | Databricks workspace ID |
| <a name="output_workspace_url"></a> [workspace\_url](#output\_workspace\_url) | Databricks workspace URL |
<!-- END_TF_DOCS -->