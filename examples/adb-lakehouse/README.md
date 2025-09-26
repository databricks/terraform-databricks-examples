# Lakehouse terraform blueprints

This example contains Terraform code used to provision a Lakehouse platform using the [adb-lakehouse module](../../modules/adb-lakehouse).
It also contains Terraform code to create the following: 
* Unity Catalog metastore 
* Unity Catalog resources: Catalog, Schema, table, storage credential and external location
* New principals in the Databricks account and assign them to the Databricks workspace.

## Deployed resources

This example can be used to deploy the following:

![Azure Lakehouse platform](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/modules/adb-lakehouse/images/azure_lakehouse_platform_diagram.png?raw=true)

* A new resource group
* Networking resources including:
  * Azure vnet
  * The required subnets for the Azure Databricks workspace.
  * Azure route table (if needed)
  * Network Security Group (NSG)
* The Lakehouse platform resources, including:
  * Azure Databricks workspace
  * Azure Data Factory
  * Azure Key Vault
  * Azure Storage account
* Unity Catalog resources:
  * Unity Catalog metastore
  * Assignment of the UC metastore to the Azure Databricks workspace
  * Creation of principals (groups and service principals) in Azure Databricks account
  * Assignment of principals to the Azure Databricks workspace
  * Creation of Unity Catalog resources (catalogs, schemas, external locations, grants)

## How to use

1. Update `terraform.tfvars` file and provide values to each defined variable
2. (Optional) Configure your [remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm)
3. Run `terraform init` to initialize terraform and get provider ready.
4. Run `terraform apply` to create the resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.0.0 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >=1.52.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.23.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_adb-lakehouse"></a> [adb-lakehouse](#module\_adb-lakehouse) | ../../modules/adb-lakehouse | n/a |
| <a name="module_adb-lakehouse-data-assets"></a> [adb-lakehouse-data-assets](#module\_adb-lakehouse-data-assets) | ../../modules/adb-lakehouse-uc/uc-data-assets | n/a |
| <a name="module_adb-lakehouse-uc-account-principals"></a> [adb-lakehouse-uc-account-principals](#module\_adb-lakehouse-uc-account-principals) | ../../modules/adb-lakehouse-uc/account-principals | n/a |
| <a name="module_adb-lakehouse-uc-idf-assignment"></a> [adb-lakehouse-uc-idf-assignment](#module\_adb-lakehouse-uc-idf-assignment) | ../../modules/uc-idf-assignment | n/a |
| <a name="module_adb-lakehouse-uc-metastore"></a> [adb-lakehouse-uc-metastore](#module\_adb-lakehouse-uc-metastore) | ../../modules/adb-uc-metastore | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_connector_name"></a> [access\_connector\_name](#input\_access\_connector\_name) | the name of the access connector | `string` | n/a | yes |
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | Databricks Account ID | `string` | n/a | yes |
| <a name="input_databricks_workspace_name"></a> [databricks\_workspace\_name](#input\_databricks\_workspace\_name) | Name of Databricks workspace | `string` | n/a | yes |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | (Required) The name of the project environment associated with the infrastructure to be managed by Terraform | `string` | n/a | yes |
| <a name="input_landing_adls_path"></a> [landing\_adls\_path](#input\_landing\_adls\_path) | The ADLS path of the landing zone | `string` | n/a | yes |
| <a name="input_landing_adls_rg"></a> [landing\_adls\_rg](#input\_landing\_adls\_rg) | The resource group name of the landing zone | `string` | n/a | yes |
| <a name="input_landing_external_location_name"></a> [landing\_external\_location\_name](#input\_landing\_external\_location\_name) | the name of the landing external location | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | (Required) The location for the resources in this module | `string` | n/a | yes |
| <a name="input_metastore_admins"></a> [metastore\_admins](#input\_metastore\_admins) | list of principals: service principals or groups that have metastore admin privileges | `list(string)` | n/a | yes |
| <a name="input_metastore_name"></a> [metastore\_name](#input\_metastore\_name) | the name of the metastore | `string` | n/a | yes |
| <a name="input_metastore_storage_name"></a> [metastore\_storage\_name](#input\_metastore\_storage\_name) | the account storage where we create the metastore | `string` | n/a | yes |
| <a name="input_private_subnet_address_prefixes"></a> [private\_subnet\_address\_prefixes](#input\_private\_subnet\_address\_prefixes) | Address space for private Databricks subnet | `list(string)` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | (Required) The name of the project associated with the infrastructure to be managed by Terraform | `string` | n/a | yes |
| <a name="input_public_subnet_address_prefixes"></a> [public\_subnet\_address\_prefixes](#input\_public\_subnet\_address\_prefixes) | Address space for public Databricks subnet | `list(string)` | n/a | yes |
| <a name="input_shared_resource_group_name"></a> [shared\_resource\_group\_name](#input\_shared\_resource\_group\_name) | Name of the shared resource group | `string` | n/a | yes |
| <a name="input_spoke_vnet_address_space"></a> [spoke\_vnet\_address\_space](#input\_spoke\_vnet\_address\_space) | (Required) The address space for the spoke Virtual Network | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Azure Subscription ID to deploy the workspace into | `string` | n/a | yes |
| <a name="input_account_groups"></a> [account\_groups](#input\_account\_groups) | list of databricks account groups we want to assign to the workspace | <pre>map(object({<br/>    group_name  = string<br/>    permissions = list(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | Set to true to create a new Azure Resource Group. Set to false to use an existing Resource Group specified in existing\_resource\_group\_name | `bool` | `true` | no |
| <a name="input_data_factory_name"></a> [data\_factory\_name](#input\_data\_factory\_name) | The name of the Azure Data Factory to deploy. Won't be created if not specified | `string` | `""` | no |
| <a name="input_existing_resource_group_name"></a> [existing\_resource\_group\_name](#input\_existing\_resource\_group\_name) | Specify the name of an existing Resource Group only if you do not want Terraform to create a new one | `string` | `""` | no |
| <a name="input_key_vault_name"></a> [key\_vault\_name](#input\_key\_vault\_name) | (Required) The name of the Azure Data Factory to deploy | `string` | `""` | no |
| <a name="input_managed_resource_group_name"></a> [managed\_resource\_group\_name](#input\_managed\_resource\_group\_name) | (Optional) The name of the resource group where Azure should place the managed Databricks resources | `string` | `""` | no |
| <a name="input_service_principals"></a> [service\_principals](#input\_service\_principals) | list of service principals we want to create at Databricks account | <pre>map(object({<br/>    sp_id        = string<br/>    display_name = optional(string)<br/>    permissions  = list(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_storage_account_names"></a> [storage\_account\_names](#input\_storage\_account\_names) | Names of the different storage accounts | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Required) Map of tags to attach to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azure_resource_group_id"></a> [azure\_resource\_group\_id](#output\_azure\_resource\_group\_id) | ID of the created Azure resource group |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | The Databricks workspace ID |
| <a name="output_workspace_url"></a> [workspace\_url](#output\_workspace\_url) | The Databricks workspace URL |
<!-- END_TF_DOCS -->
