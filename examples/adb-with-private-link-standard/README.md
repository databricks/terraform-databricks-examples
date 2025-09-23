# Provisioning Databricks on Azure with Private Link - Standard deployment

This example contains Terraform code used to deploy an Azure Databricks workspace with Azure Private Link, using the [standard deployment](https://learn.microsoft.com/en-us/azure/databricks/administration-guide/cloud-configurations/azure/private-link-standard) approach.

It is using the [adb-with-private-link-standard](../../modules/adb-with-private-link-standard) module.

## Deployed resources

This example can be used to deploy the following:

![Azure Databricks with Private Link - Standard](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/modules/adb-with-private-link-standard/images/azure-private-link-standard.png?raw=true)

* Two seperate VNets are used:
  * A transit VNet 
  * A customer Data Plane VNet
* A private endpoint is used for back-end connectivity and deployed in the customer Data Plane VNet.
* A private endpoint is used for front-end connectivity and deployed in the transit VNet.
* A private endpoint is used for web authentication and deployed in the transit VNet.
* A dedicated Databricks workspace, called Web Auth workspace, is used for web authentication traffic. This workspace is configured with the sub resource **browser_authentication** and deployed using subnets in the transit VNet.

## How to use

1. Update `terraform.tfvars` file and provide values to each defined variable
2. (Optional) Configure your [remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm)
3. Run `terraform init` to initialize terraform and get provider ready.
4. Run `terraform apply` to create the resources.

## How to test

Public access to the workspace deployed here is not allowed by default. If you can establish a direct network connection to the VNet into which the workspace is deployed then you should be able to browse the workspace directly. Alternatively, a virtual machine is created as part of this deployment allowing you to connect to the workspace in case you don't have direct network path to the VNet in which the workspace is deployed. You can use the `test_vm_public_ip` and `test_vm_password` to log into this VM (password value is marked as `sensitive` but can be found in the `teraform.tfstate` file). By default, access to this machine is only allowed from the deployer's public IP address. To allow access from other sources, extra rules can be added to the Network Security Group created for the VM as part of this deployment.
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.0.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_adb-with-private-link-standard"></a> [adb-with-private-link-standard](#module\_adb-with-private-link-standard) | ../../modules/adb-with-private-link-standard | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidr_dp"></a> [cidr\_dp](#input\_cidr\_dp) | (Required) The CIDR for the Azure Data Plane VNet | `string` | n/a | yes |
| <a name="input_cidr_transit"></a> [cidr\_transit](#input\_cidr\_transit) | (Required) The CIDR for the Azure transit VNet | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | (Required) The location for the resources in this module | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Azure Subscription ID to deploy the workspace into | `string` | n/a | yes |
| <a name="input_create_data_plane_resource_group"></a> [create\_data\_plane\_resource\_group](#input\_create\_data\_plane\_resource\_group) | Set to true to create a new Azure Resource Group for data plane resources. Set to false to use an existing Resource Group specified in existing\_data\_plane\_resource\_group\_name | `bool` | `true` | no |
| <a name="input_create_transit_resource_group"></a> [create\_transit\_resource\_group](#input\_create\_transit\_resource\_group) | Set to true to create a new Azure Resource Group for transit VNet resources. Set to false to use an existing Resource Group specified in existing\_transit\_resource\_group\_name | `bool` | `true` | no |
| <a name="input_existing_data_plane_resource_group_name"></a> [existing\_data\_plane\_resource\_group\_name](#input\_existing\_data\_plane\_resource\_group\_name) | Specify the name of an existing Resource Group for Data plane resources only if you do not want Terraform to create a new one | `string` | `""` | no |
| <a name="input_existing_transit_resource_group_name"></a> [existing\_transit\_resource\_group\_name](#input\_existing\_transit\_resource\_group\_name) | Specify the name of an existing Resource Group for transit VNet resources only if you do not want Terraform to create a new one | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_test_vm_password"></a> [test\_vm\_password](#output\_test\_vm\_password) | Password to access the Test VM, use `terraform output -json test_vm_password` to get the password value |
| <a name="output_test_vm_public_ip"></a> [test\_vm\_public\_ip](#output\_test\_vm\_public\_ip) | Public IP of the Azure VM created for testing |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | The Databricks workspace ID |
| <a name="output_workspace_url"></a> [workspace\_url](#output\_workspace\_url) | The Databricks workspace URL |
<!-- END_TF_DOCS -->
