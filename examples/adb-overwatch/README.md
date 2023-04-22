# Deploying Overwatch on Azure Databricks

This example contains Terraform code used to deploy Overwatch using the [adb-overwatch module](../../modules/adb-overwatch)


## Module content

This code uses the [multi-workspace deployment of Overwatch](https://databrickslabs.github.io/overwatch/deployoverwatch/cloudinfra/azure/#reference-architecturehttps://databrickslabs.github.io/overwatch/deployoverwatch/cloudinfra/azure/#reference-architecture). Overwatch runs in a dedicated Azure Databricks workspace, and monitors the specified workspaces in the config file `modules/adb-overwatch/config/overwatch_deployment_config.csv`.

  ![Overwatch_Arch_Azure](https://user-images.githubusercontent.com/103026825/230571464-5892c5c7-82c2-4808-9003-61b501b75f69.png?raw=true)

It covers the following steps :
* Use an existing **Resource group**
* Deploy **Eventhubs** topic per workspace, that could be in the same **Eventhubs** namespace
* Deploy **Storage Accounts**, one for the cluster logs and one for the Overwatch database output
* Deploy the dedicated **Azure Databricks** workspace for Overwatch, with some Databricks quick-start notebooks to analyse the results
* Configure **Role Assignments** and **mounts** to attribute the necessary permissions
* Configure **Diagnostic Logs** on the Databricks workspaces to monitor

## How to use

> **Note**  
> In this example, Overwatch is deployed on two different existing Databricks workspaces. On the first one a small batch job is deployed and a Delta Live Tables pipeline is deployed on the second one.
> You can customize this module by adding, deleting or updating the Azure resources to adapt the module to your requirements.

1. Make the script executable `chmod +x dynamic_providers_modules_generation.sh`
2. Update the `terraform.tfvars` file with your environment values
3. Update the file `config/overwatch_deployment_config.csv`, with the correct values for `workspace_name, workspace_id, workspace_url`
4. Run `terraform init` to initialize terraform and get provider ready.
5. Run `terraform apply` to create the resources.
