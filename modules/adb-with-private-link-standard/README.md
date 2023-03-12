# Provisioning Databricks on Azure with Private Link - Standard deployment

This module contains Terraform code used to deploy an Azure Databricks workspace with Azure Private Link.

> **Note**  
> An Azure VM is deployed using this module in order to test the connectivity to the Azure Databricks workspace. 

## Module content

This module can be used to deploy the following:

![Azure Databricks with Private Link - Standard](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/modules/adb-with-private-link-standard/images/azure-private-link-standard.png?raw=true)

It covers a [standard deployment](https://learn.microsoft.com/en-us/azure/databricks/administration-guide/cloud-configurations/azure/private-link-standard) to configure Azure Databricks with Private Link:
* Two seperate VNets are used:
  * A transit VNet 
  * A customer Data Plane VNet
* A private endpoint is used for back-end connectivity and deployed in the customer Data Plane VNet.
* A private endpoint is used for front-end connectivity and deployed in the transit VNet.
* A private endpoint is used for web authentication and deployed in the transit VNet.
* A dedicated Databricks workspace, called Web Auth workspace, is used for web authentication traffic. This workspace is configured with the sub resource **browser_authentication** and deployed using subnets in the transit VNet.

## How to use

> **Note**  
> You can customize this module by adding, deleting or updating the Azure resources to adapt the module to your requirements.
> A deployment example using this module can be found in [examples/adb-with-private-link-standard](../../examples/adb-with-private-link-standard)

1. Reference this module using one of the different [module source types](https://developer.hashicorp.com/terraform/language/modules/sources)
2. Add a `variables.tf` with the same content in [variables.tf](variables.tf)
3. Add a `terraform.tfvars` file and provide values to each defined variable
4. Add a `output.tf` file.
5. (Optional) Configure your [remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm)
6. Run `terraform init` to initialize terraform and get provider ready.
7. Run `terraform apply` to create the resources.
