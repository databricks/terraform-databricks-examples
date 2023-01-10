### This is a quick set up example for ADB - Teradata Demo environment

For quick set up of Teradata Vantage Express on Azure VM, single node deployment. 
Deploys - 
- Azure VM
- Azure Databricks Workspace


## Folder Structure
    .
    ├── main.tf
    ├── outputs.tf
    ├── providers.tf
    ├── variables.tf
    ├── modules
        ├── teradata_vm
            ├── data.tf
            ├── main.tf
            ├── outputs.tf      
            ├── providers.tf
            ├── variables.tf
        ├── adb_workspace_vnet_injected
            ├── main.tf
            ├── variables.tf
            ├── outputs.tf
