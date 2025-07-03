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