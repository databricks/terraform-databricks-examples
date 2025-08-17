# Secure Storage Connectivity to both Classic and Serverless compute using service endpoint

This example is using the [adb-data-storage-vnet-ncc-public-endpoint](../../modules/adb-data-storage-vnet-ncc-public-endpoint) module.

Include:
1. Resource group 1 with name as defined in the variable rg_name
2. Resource group 1 includes virtual network, subnets (private & public), network security group for subnets, databricks access connector and databricks workspace ( also binds it to a metastore).
3. Also deploys network connectivity configuration (NCC) for workspace
4. Resource group 2 with name as defind in the variable data_storage_account_rg
5. Resource group 2 includes data storage account includes a container with networks rules to allow conncection only from workspace virtual network public subnets and serverless NCC subnets and associated user identity + databricks access connector.
6. Also creates storage credentials , external location and catalog using the storage container in the metastore.
7. Tags, including `Owner`, which is taken from `az account show --query user`

Overall Architecture:
![alt text](../../modules/adb-data-storage-vnet-ncc-public-endpoint/architecture.drawio.svg)

## How to use

1. Update `terraform.tfvars` file and provide values to each defined variable
2. (Optional) Configure your [remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm)
3. Run `terraform init` to initialize terraform and get provider ready.
4. Run `terraform apply` to create the resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.31.0 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >=1.81.1 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_adb-data-storage-vnet-ncc-public-endpoint"></a> [adb-data-storage-vnet-ncc-public-endpoint](#module\_adb-data-storage-vnet-ncc-public-endpoint) | ../../modules/adb-data-storage-vnet-ncc-public-endpoint | n/a |

## Resources

No resources.

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
| <a name="input_databricks_catalog"></a> [databricks\_catalog](#input\_databricks\_catalog) | Name of catalog in metastore | `string` | `""` | no |
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
| <a name="input_tags"></a> [tags](#input\_tags) | Variable for tags to apply to resources for organization and billing | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_workspace_url"></a> [workspace\_url](#output\_workspace\_url) | The Databricks workspace URL |
<!-- END_TF_DOCS -->
