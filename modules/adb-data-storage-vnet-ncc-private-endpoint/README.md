# Secure Storage Connectivity to both Classic and Serverless compute using private endpoint

This module will create Azure Databricks workspace with vnet injection , enable ncc and establish secure connection between azure data storage and workspace vnet + serverless compute subnets using private endpoints. 

## Module content

This module can be used to deploy the following:

![alt text](architecture.drawio.svg)

* Resource group 1 with name as defined in the variable rg_name
* Resource group 1 includes virtual network, subnets (private & public), network security group for subnets, databricks access connector and databricks workspace ( also binds it to a metastore).
* Resource group 2 with name as defind in the variable data_storage_account_rg
* Resource group 2 includes data storage account includes a container with networks rules to allow conncection only from workspace virtual network public subnets and serverless NCC subnets and associated user identity + databricks access connector.
* Also creates storage credentials , external location and catalog using the storage container in the metastore.
* Finally 
    1. deploys network connectivity configuration (NCC) for workspace and private endpoints rules to secure connectivity with data storage account and dbfs root storage account(for serverless).
    2. Adds private link within workspace virtual network and deploys private endpoints to data storage account and dbfs root storage account along with associated dns zones.
* Tags, including `Owner`, which is taken from `az account show --query user`


## How to use

> **Note**
> You can customize this module by adding, deleting or updating the Azure resources to adapt the module to your requirements.
> A deployment example using this module can be found in [examples/adb-data-storage-vnet-ncc-private-endpoint](../../examples/adb-data-storage-vnet-ncc-private-endpoint)

1. Reference this module using one of the different [module source types](https://developer.hashicorp.com/terraform/language/modules/sources)
2. Add a `variables.tf` with the same content in [variables.tf](variables.tf)
3. Add a `terraform.tfvars` file and provide values to each defined variable
4. Add a `output.tf` file.
5. (Optional) Configure your [remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm)
6. Run `terraform init` to initialize terraform and get provider ready.
7. Run `terraform apply` to create the resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name                                                                         |  Version |
|------------------------------------------------------------------------------|----------|
| <a name="requirement_azurerm"></a> [azurerm](https://registry.terraform.io/providers/hashicorp/azurerm/4.31.0/docs)          | >=4.31.0 |
| <a name="requirement_databricks"></a> [databricks](https://registry.terraform.io/providers/databricks/databricks/1.81.1/docs) | >=1.81.1 |
| <a name="requirement_azapi"></a> [azapi](https://registry.terraform.io/providers/Azure/azapi/latest/docs) | 2.0.1 |

## Providers

| Name                                                                 |  Version  |
|----------------------------------------------------------------------|-----------|
| <a name="provider_azurerm"></a> [azurerm](https://registry.terraform.io/providers/hashicorp/azurerm/1.81.1/docs)        | >=4.31.0  |
| <a name="provider_databricks"></a> [databricks](https://registry.terraform.io/providers/databricks/databricks/1.81.1/docs) | >=1.81.1  |
| <a name="provider_azapi"></a> [azapi](https://registry.terraform.io/providers/Azure/azapi/latest/docs) | 2.0.1 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                                   | Type        |
|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.31.0/docs/resources/resource_group)                                                          | resource    |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.31.0/docs/resources/virtual_network)                                                        | resource    |
| [azurerm_network_security_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.31.0/docs/resources/network_security_group)                                          | resource    |
| [azurerm_subnet.public](https://registry.terraform.io/providers/hashicorp/azurerm/4.31.0/docs/resources/subnet)                                                                        | resource    |
| [azurerm_subnet.private](https://registry.terraform.io/providers/hashicorp/azurerm/4.31.0/docs/resources/subnet)                                                                       | resource    |
| [azurerm_databricks_access_connector.ac](https://registry.terraform.io/providers/hashicorp/azurerm/4.31.0/docs/resources/databricks_access_connector) | resource    |
| [azurerm_databricks_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.31.0/docs/resources/databricks_workspace)                                              | resource    |
| [databricks_metastore.this](https://registry.terraform.io/providers/databricks/databricks/1.81.1/docs/data-sources/metastore)                                              | data source    |
| [databricks_metastore_assignment.this](https://registry.terraform.io/providers/databricks/databricks/1.81.1/docs/resources/metastore_assignment)                                                                     | resource    |
| [databricks_mws_network_connectivity_config.ncc](https://registry.terraform.io/providers/databricks/databricks/1.81.1/docs/resources/mws_network_connectivity_config)                                                                     | resource    |
| [databricks_mws_ncc_binding.ncc_binding](https://registry.terraform.io/providers/databricks/databricks/1.81.1/docs/resources/mws_ncc_binding)                                                                     | resource    |
| [azurerm_resource_group.storage_rg](https://registry.terraform.io/providers/hashicorp/azurerm/4.31.0/docs/resources/resource_group)                                                                     | resource    |
| [azurerm_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.31.0/docs/resources/storage_account)                                                                     | resource    |
| [azurerm_storage_account_network_rules.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.31.0/docs/resources/storage_account_network_rules)                                                                     | resource    |
| [azurerm_storage_container.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.31.0/docs/resources/storage_container)                                                                     | resource    |
| [azurerm_user_assigned_identity.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.31.0/docs/resources/user_assigned_identity)                                                                     | resource    |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/4.31.0/docs/resources/role_assignment)                                                                     | resource    |
| [databricks_mws_ncc_private_endpoint_rule.storage_dfs](https://registry.terraform.io/providers/databricks/databricks/1.81.1/docs/resources/mws_ncc_private_endpoint_rule)                                                                     | resource    |
| [databricks_mws_ncc_private_endpoint_rule.storage_blob](https://registry.terraform.io/providers/databricks/databricks/1.81.1/docs/resources/mws_ncc_private_endpoint_rule)                                                                     | resource    |
| [azapi_resource_list.list_storage_private_endpoint_connection](https://registry.terraform.io/providers/Azure/azapi/2.0.1/docs/data-sources/resource_list)                                                                     | data source    |
| [azapi_update_resource.approve_storage_private_endpoint_connection_dfs](https://registry.terraform.io/providers/Azure/azapi/2.0.1/docs/resources/update_resource)                                                                     | resource    |
| [azapi_update_resource.approve_storage_private_endpoint_connection_blob](https://registry.terraform.io/providers/Azure/azapi/2.0.1/docs/resources/update_resource)                                                                     | resource    |
| [azurerm_subnet.plsubnet](https://registry.terraform.io/providers/hashicorp/azurerm/4.31.0/docs/resources/subnet)                                                                       | resource    |
| [azurerm_private_dns_zone.dfs](https://registry.terraform.io/providers/hashicorp/azurerm/4.31.0/docs/resources/private_dns_zone)                                                                       | resource    |
| [azurerm_private_dns_zone.blob](https://registry.terraform.io/providers/hashicorp/azurerm/4.31.0/docs/resources/private_dns_zone)                                                                       | resource    |
| [azurerm_private_dns_zone_virtual_network_link.dfsdnszonevnetlink](https://registry.terraform.io/providers/hashicorp/azurerm/4.31.0/docs/resources/private_dns_zone_virtual_network_link)                                                                       | resource    |
| [azurerm_private_dns_zone_virtual_network_link.blobdnszonevnetlink](https://registry.terraform.io/providers/hashicorp/azurerm/4.31.0/docs/resources/private_dns_zone_virtual_network_link)                                                                       | resource    |
| [azurerm_private_endpoint.data_dfs](https://registry.terraform.io/providers/hashicorp/azurerm/4.31.0/docs/resources/private_endpoint)                                                                       | resource    |
| [azurerm_private_endpoint.data_blob](https://registry.terraform.io/providers/hashicorp/azurerm/4.31.0/docs/resources/private_endpoint)                                                                       | resource    |
| [azurerm_storage_account.dbfs_storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/4.31.0/docs/data-sources/storage_account)                                                                       | data source    |
| [databricks_mws_ncc_private_endpoint_rule.dbfs_dfs](https://registry.terraform.io/providers/databricks/databricks/1.81.1/docs/resources/mws_ncc_private_endpoint_rule)                                                                     | resource    |                                                                    | resource    |
| [databricks_mws_ncc_private_endpoint_rule.dbfs_blob](https://registry.terraform.io/providers/databricks/databricks/1.81.1/docs/resources/mws_ncc_private_endpoint_rule)                                                                     | resource    |                                                                    | resource    |
| [azapi_resource_list.list_storage_private_endpoint_connection_dbfs](https://registry.terraform.io/providers/Azure/azapi/2.0.1/docs/data-sources/resource_list)                                                                     | data source    |
| [azapi_update_resource.approve_storage_private_endpoint_connection_dbfs_dfs](https://registry.terraform.io/providers/Azure/azapi/2.0.1/docs/resources/update_resource)                                                                     | resource    |
| [azapi_update_resource.approve_storage_private_endpoint_connection_dbfs_blob](https://registry.terraform.io/providers/Azure/azapi/2.0.1/docs/resources/update_resource)                                                                     | resource    |
| [azurerm_private_endpoint.dbfs_dfs](https://registry.terraform.io/providers/hashicorp/azurerm/4.31.0/docs/resources/private_endpoint)                                                                       | resource    |
| [azurerm_private_endpoint.dbfs_blob](https://registry.terraform.io/providers/hashicorp/azurerm/4.31.0/docs/resources/private_endpoint)                                                                       | resource    |
| [databricks_storage_credential.this](https://registry.terraform.io/providers/databricks/databricks/1.81.1/docs/resources/storage_credential)                                                                     | resource    |
| [databricks_external_location.this](https://registry.terraform.io/providers/databricks/databricks/1.81.1/docs/resources/external_location)                                                                    | resource    |
| [databricks_grants.admins_browse_access](https://registry.terraform.io/providers/databricks/databricks/1.81.1/docs/resources/grants)                                                                     | resource    |
| [databricks_catalog.this](https://registry.terraform.io/providers/databricks/databricks/1.81.1/docs/resources/catalog)                                                                     | resource    |
| [databricks_grants.grant_catalog_access](https://registry.terraform.io/providers/databricks/databricks/1.81.1/docs/resources/grants)                                                                     | resource    |

## Inputs
| Name | Description | Type | Default | Required |
| :-- | :-- | :-- | :-- | :-- |
| [azure_region](https://#input_azure_region) | Azure region where resources will be deployed | `string` | `""` | yes |
| [rg_name](https://#input_rg_name) | Name of the resource group to create | `string` | `""` | yes |
| [name_prefix](https://#input_name_prefix) | Prefix used in naming resources | `string` | `""` | yes |
| [dbfs_storage_account](https://#input_dbfs_storage_account) | Name of the storage account for DBFS | `string` | `""` | yes |
| [azure_subscription_id](https://#input_azure_subscription_id) | Azure subscription ID used for authentication | `string` | `""` | yes |
| [cidr_block](https://#input_cidr_block) | VPC CIDR block range | `string` | `"10.20.0.0/23"` | no |
| [private_subnets_cidr](https://#input_private_subnets_cidr) | CIDR block of the private subnet for cluster containers | `string` | `"10.20.0.0/25"` | no |
| [public_subnets_cidr](https://#input_public_subnets_cidr) | CIDR block of the public subnet for cluster host | `string` | `"10.20.0.128/25"` | no |
| [pl_subnets_cidr](https://#input_pl_subnets_cidr) | CIDR block of the Private Link subnets | `string` | `"10.20.1.0/27"` | no |
| [subnet_service_endpoints](https://#input_subnet_service_endpoints) | Service endpoints to enable on subnets | `list(string)` | `[]` | no |
| [network_security_group_rules_required](https://#input_network_security_group_rules_required) | Control whether network security group rules are required | `string` | `"AllRules"` | no |
| [default_storage_firewall_enabled](https://#input_default_storage_firewall_enabled) | Disallow public access to default storage account | `bool` | `true` | no |
| [public_network_access_enabled](https://#input_public_network_access_enabled) | Allow public access to frontend workspace web UI | `bool` | `true` | no |
| [databricks_host](https://#input_databricks_host) | Databricks Account URL | `string` | `""` | yes |
| [databricks_account_id](https://#input_databricks_account_id) | Your Databricks Account ID | `string` | `""` | yes |
| [databricks_metastore](https://#input_databricks_metastore) | Databricks UC Metastore | `string` | `""` | yes |
| [data_storage_account_rg](https://#input_data_storage_account_rg) | ADLS Storage account resource group | `string` | `""` | yes |
| [data_storage_account](https://#input_data_storage_account) | ADLS Storage account Name | `string` | `""` | yes |
| [storage_account_allowed_ips](https://#input_storage_account_allowed_ips) | List of allowed IP addresses for the storage account | `list(string)` | `[]` | no |
| [databricks_calalog](https://#input_databricks_calalog) | Name of catalog in metastore | `string` | `""` | yes |
| [principal_name](https://#input_principal_name) | Name of principal to grant access to catalog | `string` | `""` | yes |
| [catalog_privileges](https://#input_catalog_privileges) | List of Privileges to catalog (grant to principal_name) | `list(string)` | `["BROWSE"]` | no |
| [tags](https://#input_tags) | Tags to apply to resources for organization and billing | `any` | `""` | no |
## Outputs

| Name                                                                                                                                                           | Description                                                                     |
|:---------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| <a name="databricks_host"></a> [databricks_host](#output/_databricks_host)                                                                                  | The Databricks workspace URL                                                    |
<!-- END_TF_DOCS -->
