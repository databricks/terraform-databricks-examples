# Basic deployment example of Azure Databricks workspace objects

This example deploys a vnet-injected Azure Databricks workspace with a single cluster. You can use it to learn how to start using this repo's examples and deploy resources into your Azure Environment.

List of resources that will deployed:
1. Virtual Network with 2 subnets (each Databricks workspace requires 2 dedicated same-size subnets)
2. Azure Databricks workspace
3. Azure Databricks cluster

Step 1: Configure authentication to providers
---------------------------------------------
