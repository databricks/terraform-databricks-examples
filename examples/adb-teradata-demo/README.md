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

This tutorial refers to the official Teradata Vantage Express installation guide:
https://quickstarts.teradata.com/run-vantage-express-on-microsoft-azure.html

> Step 1
Getting the cURL from Teradata Vantage Express download page
This will be a manual step; you get the URL and curl command, then supply them in this terraform template.

> Step 2
Terraform apply deploy resources

> Step 3 Log into Teradata VM to validate TD is up and running
Change accordingly
```bash
ssh -i <private_key_local_path> azureuser@<public_ip>
```