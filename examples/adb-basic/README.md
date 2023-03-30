# Basic deployment example of Azure Databricks workspace objects

This example deploys a [vnet-injected Azure Databricks](https://learn.microsoft.com/en-us/azure/databricks/administration-guide/cloud-configurations/azure/vnet-inject) workspace with a single cluster. You can use it to learn how to start using this repo's examples and deploy resources into your Azure Environment.

List of resources that will deployed:
1. Virtual Network with 2 subnets (each Databricks workspace requires 2 dedicated same-size subnets)
2. Azure Databricks workspace
3. Azure Databricks cluster

Step 1: Configure authentication to providers
---------------------------------------------
Navigate to `providers.tf` and configure authentication to `azurerm` and `Databricks` providers. Read following docs for extensive information on how to configure authentication to providers:

[azurerm provider authentication methods](https://learn.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure?tabs=bash)

[databricks provider authentication methods](https://registry.terraform.io/providers/databricks/databricks/latest/docs#authentication) and [MSFT doc](https://learn.microsoft.com/en-us/azure/databricks/dev-tools/terraform/#requirements)

In this demo we can use the simplest AZ CLI method to authenticate to both `azurerm` and `databricks` providers via `az login`. For production deployment, we recommend using service principal authentication method.

Step 2: Configure input values to your terraform template
--------------------------------------------------------
Navigate to `variables.tf` and configure input values to your terraform template. Read following docs for extensive information on how to configure input values to your terraform template:

[hashicorp tutorial on input variables](https://developer.hashicorp.com/terraform/language/values/variables)

Step 3: Deploy to your Azure environment
---------------------------------------
Do following steps:

Run `terraform init` to initialize terraform and download required providers.

Run `terraform plan` to see what resources will be deployed.

Run `terraform apply` to deploy resources to your Azure environment. Since we used `az login` method to authenticate to providers, you will be prompted to login to Azure via browser. Enter `yes` when prompted to deploy resources.

Step 4: Verify deployment
-------------------------
Navigate to Azure Portal and verify that all resources were deployed successfully. You should now have a vnet-injected workspace with one cluster deployed.