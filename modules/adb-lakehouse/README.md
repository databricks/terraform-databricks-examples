# Lakehouse terraform blueprints

This module contains Terraform code used to provision a Lakehouse platform.

## Module content

This module can be used to deploy the following architecture:

![Azure Lakehouse platform](https://raw.githubusercontent.com/yessawab/terraform-databricks-examples/main/modules/adb-lakehouse/images/azure_lakehouse_platform_diagram.png?raw=true)

* A new resource group
* Networking resources including:
  * Azure vnet
  * The requiredt subnets for the Azure Databricks workspace.
  * Azure route table (if needed)
  * NSG
* The Lakehouse platform resources, including:
  * Azure Databricks workspace
  * Azure key vault
  * Azure data factory
  * Azure storage account

## How to use

> **Note**  
> *  You can customize this module by adding, deleting or updating the Azure resources to adapt the module to your requirements.

1. Reference this module using one of the different [module source types](https://developer.hashicorp.com/terraform/language/modules/sources)
3. Add a `terraform.tfvars` file and provide values to each variable defined in [variables.tf](https://raw.githubusercontent.com/yessawab/terraform-databricks-examples/main/modules/adb-lakehouse/variables.tf?raw=true)
2. Run `terraform init` to initialize terraform and get provider ready.
3. Change `terraform.tfvars` values to your own values.
4. Inside the local project folder, run `terraform apply` to create the resources.
