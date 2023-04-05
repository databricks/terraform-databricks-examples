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
