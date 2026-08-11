# Secure Storage Connectivity to both Classic and Serverless compute using service endpoints

This module deploys an Azure Databricks workspace with VNet injection and connects it to an Azure Storage account (used for Unity Catalog external storage and DBFS) using **service endpoints**, allowing access from both classic (VNet-injected) compute and serverless compute while keeping the storage account off the public internet.

It is the public-endpoint (service-endpoint) variant of the sibling [`adb-data-storage-vnet-ncc-private-endpoint`](../adb-data-storage-vnet-ncc-private-endpoint) module: rather than routing storage traffic through Azure private endpoints and private DNS, it restricts the storage account's network rules so that only the workspace's host subnet and the serverless NCC storage subnets are permitted.

## Module content

This module can be used to deploy the following:

* A resource group containing a virtual network with host and container subnets, network security groups, a Databricks access connector and a VNet-injected Databricks workspace (assigned to a metastore).
* A network connectivity configuration (NCC) bound to the workspace, from which the serverless storage subnets are read and added to the storage account's network rules.
* A second resource group containing the data storage account and container, a user-assigned identity and a Databricks access connector.
* **Storage account network rules** (`azurerm_storage_account_network_rules`) that allow connections only from the workspace's host subnet and the serverless NCC storage subnets.
* Databricks storage credential, external location and catalog backed by the storage container, plus grants.

## How to use

> **Note**
> You can customize this module by adding, deleting or updating the Azure resources to adapt it to your requirements.

1. Reference this module using one of the different [module source types](https://developer.hashicorp.com/terraform/language/modules/sources).
2. Configure the `azurerm` and account-level/workspace-level `databricks` providers (see [providers.tf](providers.tf)).
3. Provide values for the variables defined in [variables.tf](variables.tf) via a `terraform.tfvars` file.
4. Run `terraform init`.
5. Run `terraform apply`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.31.0 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >=1.81.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=4.31.0 |
| <a name="provider_databricks.accounts"></a> [databricks.accounts](#provider\_databricks.accounts) | >=1.81.1 |
| <a name="provider_databricks.workspace"></a> [databricks.workspace](#provider\_databricks.workspace) | >=1.81.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_databricks_access_connector.ac](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/databricks_access_connector) | resource |
| [azurerm_databricks_access_connector.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/databricks_access_connector) | resource |
| [azurerm_databricks_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/databricks_workspace) | resource |
| [azurerm_network_security_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_resource_group.storage_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_account_network_rules.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account_network_rules) | resource |
| [azurerm_storage_container.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_subnet.private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_network_security_group_association.public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_user_assigned_identity.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [databricks_catalog.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/catalog) | resource |
| [databricks_external_location.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/external_location) | resource |
| [databricks_grants.admins_browse_access](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants) | resource |
| [databricks_grants.grant_catalog_access](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants) | resource |
| [databricks_metastore_assignment.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/metastore_assignment) | resource |
| [databricks_mws_ncc_binding.ncc_binding](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_ncc_binding) | resource |
| [databricks_mws_network_connectivity_config.ncc](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_network_connectivity_config) | resource |
| [databricks_storage_credential.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/storage_credential) | resource |
| [databricks_metastore.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/metastore) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_region"></a> [azure\_region](#input\_azure\_region) | Variable for the Azure region where resources will be deployed | `string` | `""` | no |
| <a name="input_azure_subscription_id"></a> [azure\_subscription\_id](#input\_azure\_subscription\_id) | Variable for the Azure subscription ID used for authentication | `string` | `""` | no |
| <a name="input_catalog_privileges"></a> [catalog\_privileges](#input\_catalog\_privileges) | List of Privileges to catalog (grant to principal\_name) | `list(string)` | <pre>[<br/>  "BROWSE"<br/>]</pre> | no |
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block) | VPC CIDR block range | `string` | `"10.20.0.0/23"` | no |
| <a name="input_data_storage_account"></a> [data\_storage\_account](#input\_data\_storage\_account) | ADLS Storage account Name | `string` | `""` | no |
| <a name="input_data_storage_account_rg"></a> [data\_storage\_account\_rg](#input\_data\_storage\_account\_rg) | ADLS Storage account resource group | `string` | `""` | no |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | Your Databricks Account ID | `string` | `""` | no |
| <a name="input_databricks_calalog"></a> [databricks\_calalog](#input\_databricks\_calalog) | Name of catalog in metastore | `string` | `""` | no |
| <a name="input_databricks_host"></a> [databricks\_host](#input\_databricks\_host) | Databricks Account URL | `string` | `""` | no |
| <a name="input_databricks_metastore"></a> [databricks\_metastore](#input\_databricks\_metastore) | Databricks UC Metastore | `string` | `""` | no |
| <a name="input_dbfs_storage_account"></a> [dbfs\_storage\_account](#input\_dbfs\_storage\_account) | Variable for the name of the storage account for DBFS | `string` | `""` | no |
| <a name="input_default_storage_firewall_enabled"></a> [default\_storage\_firewall\_enabled](#input\_default\_storage\_firewall\_enabled) | Disallow public access to default storage account | `bool` | `false` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Variable for the prefix used in naming resources | `string` | `""` | no |
| <a name="input_network_security_group_rules_required"></a> [network\_security\_group\_rules\_required](#input\_network\_security\_group\_rules\_required) | Variable to control whether network security group rules are required | `string` | `"AllRules"` | no |
| <a name="input_principal_name"></a> [principal\_name](#input\_principal\_name) | Name of principal to grant access to catalog | `string` | `""` | no |
| <a name="input_private_subnets_cidr"></a> [private\_subnets\_cidr](#input\_private\_subnets\_cidr) | Variable for the CIDR block of the private subnet for cluster containers | `string` | `"10.20.0.0/25"` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Allow public access to frontend workspace web UI | `bool` | `true` | no |
| <a name="input_public_subnets_cidr"></a> [public\_subnets\_cidr](#input\_public\_subnets\_cidr) | Variable for the CIDR block of the public subnet for cluster hosts | `string` | `"10.20.0.128/25"` | no |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | Variable for the name of the resource group to create | `string` | `""` | no |
| <a name="input_storage_account_allowed_ips"></a> [storage\_account\_allowed\_ips](#input\_storage\_account\_allowed\_ips) | Variable for the list of allowed IP addresses for the storage account | `list(string)` | `[]` | no |
| <a name="input_subnet_service_endpoints"></a> [subnet\_service\_endpoints](#input\_subnet\_service\_endpoints) | Variable for service endpoints to enable on subnets | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Variable for tags to apply to resources for organization and billing | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_databricks_host"></a> [databricks\_host](#output\_databricks\_host) | Output the URL of the Databricks workspace |
<!-- END_TF_DOCS -->
