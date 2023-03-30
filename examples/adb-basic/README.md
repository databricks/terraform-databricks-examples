# VNet-injected Azure Databricks workspace and workspace objects

This example deploys a [vnet-injected Azure Databricks](https://learn.microsoft.com/en-us/azure/databricks/administration-guide/cloud-configurations/azure/vnet-inject) workspace with a single cluster. You can use it to learn how to start using this repo's examples and deploy resources into your Azure Environment.

Step 1: Configure authentication to providers
---------------------------------------------
Navigate to `providers.tf` and configure authentication to `azurerm` and `Databricks` providers. Read following docs for extensive information on how to configure authentication to providers:

[azurerm provider authentication methods](https://learn.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure?tabs=bash)

[databricks provider authentication methods](https://registry.terraform.io/providers/databricks/databricks/latest/docs#authentication) and [MSFT doc](https://learn.microsoft.com/en-us/azure/databricks/dev-tools/terraform/#requirements)

In this demo we can use the simplest AZ CLI method to authenticate to both `azurerm` and `databricks` providers via `az login`. For production deployment, we recommend using service principal authentication method.

Step 2: Configure input values to your terraform template
--------------------------------------------------------
Navigate to `variables.tf` and configure input values to your terraform template. Read following docs for extensive information on how to configure input values to your terraform template:

[hashicorp tutorial on input variables](https://developer.hashicorp.com/terraform/language/values/variables)

Step 3: Deploy to your Azure environment
---------------------------------------

The identity that you use in `az login` to deploy this template should have contributor role in your azure subscription, or the minimum required permissions to deploy resources in this template.

Do following steps:

Run `terraform init` to initialize terraform and download required providers.

Run `terraform plan` to see what resources will be deployed.

Run `terraform apply` to deploy resources to your Azure environment. Since we used `az login` method to authenticate to providers, you will be prompted to login to Azure via browser. Enter `yes` when prompted to deploy resources.

Step 4: Verify deployment
-------------------------
Navigate to Azure Portal and verify that all resources were deployed successfully. You should now have a vnet-injected workspace with one cluster deployed.
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name                                                                         | Version  |
| ---------------------------------------------------------------------------- | -------- |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm)          | >=3.0.0  |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >=1.13.0 |

## Providers

| Name                                                                   | Version |
| ---------------------------------------------------------------------- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm)          | 3.49.0  |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | 1.13.0  |
| <a name="provider_random"></a> [random](#provider\_random)             | 3.4.3   |

## Modules

| Name                                                                                                                           | Source                        | Version |
| ------------------------------------------------------------------------------------------------------------------------------ | ----------------------------- | ------- |
| <a name="module_auto_scaling_cluster_example"></a> [auto\_scaling\_cluster\_example](#module\_auto\_scaling\_cluster\_example) | ./modules/autoscaling_cluster | n/a     |

## Resources

| Name                                                                                                                                                                                   | Type        |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [azurerm_databricks_workspace.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/databricks_workspace)                                           | resource    |
| [azurerm_network_security_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group)                                          | resource    |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group)                                                          | resource    |
| [azurerm_subnet.private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)                                                                       | resource    |
| [azurerm_subnet.public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)                                                                        | resource    |
| [azurerm_subnet_network_security_group_association.private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource    |
| [azurerm_subnet_network_security_group_association.public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association)  | resource    |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network)                                                        | resource    |
| [random_string.naming](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string)                                                                          | resource    |
| [databricks_spark_version.latest_lts](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/spark_version)                                            | data source |

## Inputs

| Name                                                                                                                               | Description | Type     | Default             | Required |
| ---------------------------------------------------------------------------------------------------------------------------------- | ----------- | -------- | ------------------- | :------: |
| <a name="input_cidr"></a> [cidr](#input\_cidr)                                                                                     | n/a         | `string` | `"10.179.0.0/20"`   |    no    |
| <a name="input_dbfs_prefix"></a> [dbfs\_prefix](#input\_dbfs\_prefix)                                                              | n/a         | `string` | `"dbfs"`            |    no    |
| <a name="input_global_auto_termination_minute"></a> [global\_auto\_termination\_minute](#input\_global\_auto\_termination\_minute) | n/a         | `number` | `30`                |    no    |
| <a name="input_no_public_ip"></a> [no\_public\_ip](#input\_no\_public\_ip)                                                         | n/a         | `bool`   | `true`              |    no    |
| <a name="input_node_type"></a> [node\_type](#input\_node\_type)                                                                    | n/a         | `string` | `"Standard_DS3_v2"` |    no    |
| <a name="input_rglocation"></a> [rglocation](#input\_rglocation)                                                                   | n/a         | `string` | `"southeastasia"`   |    no    |
| <a name="input_workspace_prefix"></a> [workspace\_prefix](#input\_workspace\_prefix)                                               | n/a         | `string` | `"adb"`             |    no    |

## Outputs

| Name                                                                                                                                                           | Description |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| <a name="output_databricks_azure_workspace_resource_id"></a> [databricks\_azure\_workspace\_resource\_id](#output\_databricks\_azure\_workspace\_resource\_id) | n/a         |
| <a name="output_module_cluster_id"></a> [module\_cluster\_id](#output\_module\_cluster\_id)                                                                    | n/a         |
| <a name="output_workspace_url"></a> [workspace\_url](#output\_workspace\_url)                                                                                  | n/a         |
<!-- END_TF_DOCS -->