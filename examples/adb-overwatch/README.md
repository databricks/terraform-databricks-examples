# Deploying Overwatch on Azure Databricks

This example contains Terraform code used to deploy Overwatch using the following modules :
- [adb-overwatch-regional-config](../../modules/adb-overwatch-regional-config)
- [adb-overwatch-mws-config](../../modules/adb-overwatch-mws-config)
- [adb-overwatch-main-ws](../../modules/adb-overwatch-main-ws)
- [adb-overwatch-ws-to-monitor](../../modules/adb-overwatch-ws-to-monitor)
- [adb-overwatch-analysis](../../modules/adb-overwatch-analysis)


## Example content

This code uses the [multi-workspace deployment of Overwatch](https://databrickslabs.github.io/overwatch/deployoverwatch/cloudinfra/azure/#reference-architecturehttps://databrickslabs.github.io/overwatch/deployoverwatch/cloudinfra/azure/#reference-architecture). Overwatch runs in a dedicated, or existing, Azure Databricks workspace, and monitors the specified workspaces in the config file [overwatch_deployment_config.csv](./overwatch_deployment_config.csv). This configuration file is generated automatically by the module [adb-overwatch-ws-to-monitor](../../modules/adb-overwatch-ws-to-monitor).

  ![Overwatch_Arch_Azure](https://user-images.githubusercontent.com/103026825/230571464-5892c5c7-82c2-4808-9003-61b501b75f69.png?raw=true)

The deployment is structured as followed :
* Use an existing **Resource group**
* Deploy **Eventhubs** topic per workspace, that could be in the same **Eventhubs** namespace
* Deploy **Storage Accounts**, one for the cluster logs and one for Overwatch database output
* Deploy the dedicated **Azure Databricks** workspace, or use an existing one for Overwatch, with some Databricks quick-start notebooks to analyse the results
* Deploy **Azure Key Vault** to store the secrets
* Configure **Role Assignments** and **mounts** to attribute the necessary permissions
* Configure **Diagnostic Logs** on the Databricks workspaces to monitor

> **Note**  
> As Terraform requires providers and modules to be declared statically before deploying the resources, we are using in this example a [bash script](./dynamic_providers_modules_generation.sh)
> that generates the provider configurations for N workspaces along with the modules references.

## How to use

1. Configure the workspaces that will be observed by Overwatch in [workspaces_to_monitor.json](./workspaces_to_monitor.json)
2. Make the script [dynamic_providers_modules_generation.sh](./dynamic_providers_modules_generation.sh) executable : `chmod +x dynamic_providers_modules_generation.sh`
3. Update the `terraform.tfvars` file with your environment values 
4. Run the script [dynamic_providers_modules_generation.sh](./dynamic_providers_modules_generation.sh) : `./dynamic_providers_modules_generation.sh`. This will dynamically generate `providers_ws_to_monitor.tf` and `main_ws_to_monitor.tf` files with the right terraform setup for all the workspaces defined in [workspaces_to_monitor.json](./workspaces_to_monitor.json)
5. Run `terraform init` to initialize terraform and get provider ready
6. Run `terraform plan` to check the resources that are affected
7. Run `terraform apply` to create the resources
