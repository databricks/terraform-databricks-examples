# Lakehouse terraform blueprints

This module contains Terraform code used to provision a Lakehouse platform.

## Module content

This module can be used to deploy the following:

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

## How to use

> **Note**  
> You can customize this module by adding, deleting or updating the Azure resources to adapt the module to your requirements.
> A deployment example using this module can be found in [examples/adb-lakehouse](../../examples/adb-lakehouse)

1. Reference this module using one of the different [module source types](https://developer.hashicorp.com/terraform/language/modules/sources)
2. Add a `variables.tf` with the same content in [variables.tf](variables.tf)
3. Add a `terraform.tfvars` file and provide values to each defined variable
4. Add a `output.tf` file.
5. (Optional) Configure your [remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm)
6. Run `terraform init` to initialize terraform and get provider ready.
7. Run `terraform apply` to create the resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name                                                                | Version |
|---------------------------------------------------------------------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.0.0 |

## Providers

| Name                                                          | Version |
|---------------------------------------------------------------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=4.0.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                                   | Type        |
|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [azurerm_data_factory.adf](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_factory)                                                               | resource    |
| [azurerm_databricks_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/databricks_workspace)                                              | resource    |
| [azurerm_key_vault.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault)                                                                 | resource    |
| [azurerm_network_security_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group)                                          | resource    |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group)                                                          | resource    |
| [azurerm_route_table.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table)                                                                | resource    |
| [azurerm_storage_account.dls](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account)                                                         | resource    |
| [azurerm_subnet.private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)                                                                       | resource    |
| [azurerm_subnet.public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)                                                                        | resource    |
| [azurerm_subnet_network_security_group_association.private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource    |
| [azurerm_subnet_network_security_group_association.public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association)  | resource    |
| [azurerm_subnet_route_table_association.private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association)                       | resource    |
| [azurerm_subnet_route_table_association.public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association)                        | resource    |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network)                                                        | resource    |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config)                                                      | data source |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group)                                                       | data source |

## Inputs

| Name                                                                                                                                  | Description                                                                                                  | Type           | Default | Required |
|---------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------|----------------|---------|:--------:|
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group)                                 | (Optional) Creates resource group if set to true (default)                                                   | `bool`         | `true`  |    no    |
| <a name="input_data_factory_name"></a> [data\_factory\_name](#input\_data\_factory\_name)                                             | The name of the Azure Data Factory to deploy. Won't be created if not specified                              | `string`       | `""`    |    no    |
| <a name="input_databricks_workspace_name"></a> [databricks\_workspace\_name](#input\_databricks\_workspace\_name)                     | Name of Databricks workspace                                                                                 | `string`       | n/a     |   yes    |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name)                                                  | (Required) The name of the project environment associated with the infrastructure to be managed by Terraform | `string`       | n/a     |   yes    |
| <a name="input_key_vault_name"></a> [key\_vault\_name](#input\_key\_vault\_name)                                                      | The name of the Azure Key Vault to deploy. Won't be created if not specified                                 | `string`       | `""`    |    no    |
| <a name="input_location"></a> [location](#input\_location)                                                                            | (Optional if `create_resource_group` is set to `false`) The location for the resources in this module                                                     | `string`       | n/a     |   yes    |
| <a name="input_managed_resource_group_name"></a> [managed\_resource\_group\_name](#input\_managed\_resource\_group\_name)             | (Optional) The name of the resource group where Azure should place the managed Databricks resources          | `string`       | `""`    |    no    |
| <a name="input_private_subnet_address_prefixes"></a> [private\_subnet\_address\_prefixes](#input\_private\_subnet\_address\_prefixes) | Address space for private Databricks subnet                                                                  | `list(string)` | n/a     |   yes    |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name)                                                              | (Required) The name of the project associated with the infrastructure to be managed by Terraform             | `string`       | n/a     |   yes    |
| <a name="input_public_subnet_address_prefixes"></a> [public\_subnet\_address\_prefixes](#input\_public\_subnet\_address\_prefixes)    | Address space for public Databricks subnet                                                                   | `list(string)` | n/a     |   yes    |
| <a name="input_spoke_resource_group_name"></a> [spoke\_resource\_group\_name](#input\_spoke\_resource\_group\_name)                   | (Required) The name of the Resource Group to create                                                          | `string`       | n/a     |   yes    |
| <a name="input_spoke_vnet_address_space"></a> [spoke\_vnet\_address\_space](#input\_spoke\_vnet\_address\_space)                      | (Required) The address space for the spoke Virtual Network                                                   | `string`       | n/a     |   yes    |
| <a name="input_create_nat_gateway"></a> [create\_nat\_gateway](#input\_create\_nat\_gateway)                      | If we should create NAT gateway and associate it with subnets.                                                   | `bool`       | `true`     |   no    |
| <a name="input_service_endpoints"></a> [service\_endpoints](#input\_service\_endpoints)                      | Service endpoints to associate with subnets.                                                   | `list(string)`       | see the code     |   no    |
| <a name="input_storage_account_names"></a> [storage\_account\_names](#input\_storage\_account\_names)                                 | Names of additional storage accounts to create                                                               | `list(string)` | `[]`    |    no    |
| <a name="input_tags"></a> [tags](#input\_tags)                                                                                        | (Required) Map of tags to attach to resources                                                                | `map(string)`  | n/a     |   yes    |

## Outputs

| Name                                                                                                            | Description                                            |
|-----------------------------------------------------------------------------------------------------------------|--------------------------------------------------------|
| <a name="output_azure_resource_group_id"></a> [azure\_resource\_group\_id](#output\_azure\_resource\_group\_id) | ID of the created or existing Azure resource group                 |
| <a name="output_azure_resource_group_location"></a> [azure\_resource\_group\_location](#output\_azure\_resource\_group\_location) | Location of the created or existing Azure resource group                 |
| <a name="output_nsg_id"></a> [nsg\_id](#output\_nsg\_id)                                                        | **Depricated** ID of the new NSG                       |
| <a name="output_rg_id"></a> [rg\_id](#output\_rg\_id)                                                           | **Depricated** ID of the resource group                |
| <a name="output_rg_name"></a> [rg\_name](#output\_rg\_name)                                                     | **Depricated** Name of the resource group              |
| <a name="output_route_table_id"></a> [route\_table\_id](#output\_route\_table\_id)                              | **Depricated** ID of the new route table               |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id)                                                     | **Depricated** ID of the new Vnet                      |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id)                                      | ID of the Databricks workspace                         |
| <a name="output_workspace_name"></a> [workspace\_name](#output\_workspace\_name)                                | **Depricated** Name of the Databricks workspace        |
| <a name="output_workspace_resource_id"></a> [workspace\_resource\_id](#output\_workspace\_resource\_id)         | **Depricated** ID of the Databricks workspace resource |
| <a name="output_workspace_url"></a> [workspace\_url](#output\_workspace\_url)                                   | URL of the Databricks workspace                        |
<!-- END_TF_DOCS -->
