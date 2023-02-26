# Lakehouse terraform blueprints

This example contains Terraform code used to provision a Lakehouse platform using the [adb-lakehouse module](../../modules/adb-lakehouse)

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
  * Azure data factory
  * Azure Storage account

## How to use

1. Update `terraform.tfvars` file and provide values to each defined variable
2. (Optional) Configure your [remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm)
4. Run `terraform init` to initialize terraform and get provider ready.
4. Run `terraform apply` to create the resources.
