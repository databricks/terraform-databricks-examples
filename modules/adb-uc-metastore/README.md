# Creation of Unity Catalog metastore on Azure

This module contains Terraform code used to create a Unity Catalog metastore on Azure.

## Module content

This module can be used to perform following tasks:

* Create a resource group for Unity Catalog resources.
* Create a Azure storage account for Unity Catalog metastore together with storage container.
* Create a Databricks access connector.
* Assign necessary permissions.
* Create a Unity Catalog metastore with the created storage account as storage root.

## How to use

> **Note**  
> A deployment example using this module can be found in [examples/adb-lakehouse](../../examples/adb-lakehouse)

1. Reference this module using one of the different [module source types](https://developer.hashicorp.com/terraform/language/modules/sources)
2. Add a `variables.tf` with the same content in [variables.tf](variables.tf)
3. Add a `terraform.tfvars` file and provide values to each defined variable
4. Add a `output.tf` file.
5. (Optional) Configure your [remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm)
6. Run `terraform init` to initialize terraform and get provider ready.
7. Run `terraform apply` to create the resources.

