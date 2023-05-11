gcp byovpc
=========================

In this template, we show how to deploy a workspace with a custom vpc.


## Requirements

- You need to have run gcp-sa-provisionning and have a service account to fill in the variables.
- If you want to deploy to a new project, you will need to grant the custom role generated in that template to the service acount in the new project.
- The sizing of the custom vpc subnets needs to be appropriate for the usage of the workspace. [This documentation covers it](https://docs.gcp.databricks.com/administration-guide/cloud-configurations/gcp/network-sizing.html)

## Run as an SA 

You can do the same thing by provisionning a service account that will have the same permissions - and associate the key associated to it.


## Run the tempalte

- You need to fill in the variables.tf 
- run `terraform init`
- run `teraform apply`