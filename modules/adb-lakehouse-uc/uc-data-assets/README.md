# Unity Catalog terraform blueprints

This module contains Terraform code used to provision assets required for Databricks Unity Catalog.

## Module content

This module can be used to deploy the following:

* The Lakehouse platform resources, including:
  * Azure role assignment for the storage account
  * Databricks external location
  * Databricks catalog
  * Databricks schema
  * Databricks grants required to admin the external location
  * Databricks grants required to admin the catalog

## How to use

1. Reference this module using one of the different [module source types](https://developer.hashicorp.com/terraform/language/modules/sources)
2. Add `terraform.tfvars` with the information about the required input variables.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name                                                                   | Version |
|------------------------------------------------------------------------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm)          | n/a     |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                                                                            | Type        |
|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [azurerm_role_assignment.ext_storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)                          | resource    |
| [databricks_catalog.bronze-catalog](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/catalog)                                | resource    |
| [databricks_external_location.landing-external-location](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/external_location) | resource    |
| [databricks_grants.catalog_bronze-grants](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants)                           | resource    |
| [databricks_grants.landing-external-location-grants](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants)                | resource    |
| [databricks_schema.bronze_source1-schema](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/schema)                           | resource    |
| [azurerm_storage_account.ext_storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account)                       | data source |

## Inputs

| Name                                                                                                                               | Description                                                                           | Type           | Default | Required |
|------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------|----------------|---------|:--------:|
| <a name="input_access_connector_id"></a> [access\_connector\_id](#input\_access\_connector\_id)                                    | the id of the access connector                                                        | `string`       | n/a     |   yes    |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name)                                               | the deployment environment                                                            | `string`       | n/a     |   yes    |
| <a name="input_landing_adls_path"></a> [landing\_adls\_path](#input\_landing\_adls\_path)                                          | The ADLS path of the landing zone                                                     | `string`       | n/a     |   yes    |
| <a name="input_landing_adls_rg"></a> [landing\_adls\_rg](#input\_landing\_adls\_rg)                                                | The resource group name of the landing zone                                           | `string`       | n/a     |   yes    |
| <a name="input_landing_external_location_name"></a> [landing\_external\_location\_name](#input\_landing\_external\_location\_name) | the name of the landing external location                                             | `string`       | n/a     |   yes    |
| <a name="input_metastore_admins"></a> [metastore\_admins](#input\_metastore\_admins)                                               | list of principals: service principals or groups that have metastore admin privileges | `list(string)` | n/a     |   yes    |
| <a name="input_metastore_id"></a> [metastore\_id](#input\_metastore\_id)                                                           | Id of the metastore                                                                   | `string`       | n/a     |   yes    |
| <a name="input_storage_credential_name"></a> [storage\_credential\_name](#input\_storage\_credential\_name)                        | the name of the storage credential                                                    | `string`       | n/a     |   yes    |

## Outputs

No outputs.
<!-- END_TF_DOCS -->