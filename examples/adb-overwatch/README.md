# Deploying Overwatch on Azure Databricks

This project contains Terraform code used to deploy the different required modules by Overwatch

## Module content

This code uses the [multi-workspace deployment of Overwatch](https://databrickslabs.github.io/overwatch/deployoverwatch/cloudinfra/azure/#reference-architecturehttps://databrickslabs.github.io/overwatch/deployoverwatch/cloudinfra/azure/#reference-architecture). Overwatch runs in a dedicated Azure Databricks workspace, and monitors the specified workspaces in the config file `adb-overwatch/config/overwatch_deployment_config.csv`.


It covers the following modules :
* Resource group
* Eventhubs
* Storage Accounts
* Azure Databricks
* Role Assignments
* Diagnostic Logs

## How to use

> **Note**  
> In this example, Overwatch is deployed on two different existing Databricks workspaces. On the first one a small batch job is deployed and a Delta Live Tables pipeline is deployed on the second one.
> You can customize this module by adding, deleting or updating the Azure resources to adapt the module to your requirements.

1. Update the `terraform.tfvars` file with your environment values
2. Update the file `config/overwatch_deployment_config.csv`, with the correct values for `workspace_name, workspace_id, workspace_url`
4. Run `terraform init` to initialize terraform and get provider ready.
5. Run `terraform apply` to create the resources.
