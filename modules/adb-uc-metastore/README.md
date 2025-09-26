# Creation of Unity Catalog metastore on Azure

This module contains Terraform code used to create a Unity Catalog metastore on Azure.

## Module content

This module can be used to perform following tasks:

* Create a resource group for Unity Catalog resources.
* Create a Azure storage account for Unity Catalog metastore together with storage container.
* Create a Databricks access connector.
* Assign necessary permissions.
* Create a Unity Catalog metastore with the created storage account as storage root.

## How to use

> **Note**  
> A deployment example using this module can be found in [examples/adb-lakehouse](../../examples/adb-lakehouse)

1. Reference this module using one of the different [module source types](https://developer.hashicorp.com/terraform/language/modules/sources)
2. Add a `variables.tf` with the same content in [variables.tf](variables.tf)
3. Add a `terraform.tfvars` file and provide values to each defined variable
4. Add a `output.tf` file.
5. (Optional) Configure your [remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm)
6. Run `terraform init` to initialize terraform and get provider ready.
7. Run `terraform apply` to create the resources.

                                                                                                       |
<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_databricks_access_connector.access_connector](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/databricks_access_connector) | resource |
| [azurerm_resource_group.shared_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.unity_catalog](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_account.unity_catalog](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_container.unity_catalog](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [databricks_metastore.databricks-metastore](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/metastore) | resource |
| [databricks_metastore_data_access.access-connector-data-access](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/metastore_data_access) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_connector_name"></a> [access\_connector\_name](#input\_access\_connector\_name) | Name of the access connector for Unity Catalog metastore | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | (Required) The location for the resources in this module | `string` | n/a | yes |
| <a name="input_metastore_name"></a> [metastore\_name](#input\_metastore\_name) | the name of the metastore | `string` | n/a | yes |
| <a name="input_metastore_storage_name"></a> [metastore\_storage\_name](#input\_metastore\_storage\_name) | Name of the storage account for Unity Catalog metastore | `string` | n/a | yes |
| <a name="input_shared_resource_group_name"></a> [shared\_resource\_group\_name](#input\_shared\_resource\_group\_name) | Name of the shared resource group | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Required) Map of tags to attach to resources | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_connector_id"></a> [access\_connector\_id](#output\_access\_connector\_id) | the id of the access connector |
| <a name="output_access_connector_principal_id"></a> [access\_connector\_principal\_id](#output\_access\_connector\_principal\_id) | The Principal ID of the System Assigned Managed Service Identity that is configured on this Access Connector |
| <a name="output_metastore_id"></a> [metastore\_id](#output\_metastore\_id) | n/a |
<!-- END_TF_DOCS -->
