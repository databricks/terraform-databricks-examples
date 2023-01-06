## adls_content module

This module will create a storage account into specified rg, and create a container. Ouputs will be storage account name and container name.
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.0.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >=2.2.3 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >=3.3.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=3.0.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >=3.3.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_storage_account.personaldropbox](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_container.example_container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [random_string.naming](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_rg"></a> [rg](#input\_rg) | n/a | `string` | n/a | yes |
| <a name="input_storage_account_location"></a> [storage\_account\_location](#input\_storage\_account\_location) | n/a | `string` | `"southeastasia"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_name"></a> [container\_name](#output\_container\_name) | n/a |
| <a name="output_storage_name"></a> [storage\_name](#output\_storage\_name) | n/a |
<!-- END_TF_DOCS -->