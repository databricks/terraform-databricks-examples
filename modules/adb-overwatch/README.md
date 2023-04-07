# Deploying Overwatch on Azure Databricks

This project contains Terraform code used to deploy the different required modules by Overwatch

## Module content

This code uses the [multi-workspace deployment of Overwatch](https://databrickslabs.github.io/overwatch/deployoverwatch/cloudinfra/azure/#reference-architecturehttps://databrickslabs.github.io/overwatch/deployoverwatch/cloudinfra/azure/#reference-architecture). Overwatch runs in a dedicated Azure Databricks workspace, and monitors the specified workspaces in the config file `adb-overwatch/config/overwatch_deployment_config.csv`.
  ![Overwatch_Arch_Azure (1)](https://user-images.githubusercontent.com/103026825/230571464-5892c5c7-82c2-4808-9003-61b501b75f69.png)
  
It covers the following modules :
* Resource group
* Eventhubs
* Storage Accounts
* Azure Databricks
* Role Assignments
* Diagnostic Logs

## How to use

> **Note**  
> You can customize this module by adding, deleting or updating the Azure resources to adapt the module to your requirements.

1. Update the `terraform.tfvars` file with your environment values
2. Update the file `config/overwatch_deployment_config.csv`, with the correct values for `workspace_name, workspace_id, workspace_url`
4. Run `terraform init` to initialize terraform and get provider ready.
5. Run `terraform apply` to create the resources.
