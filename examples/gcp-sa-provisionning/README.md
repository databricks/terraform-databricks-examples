# Provisioning a Google Service Account that can be used to deploy Databricks workspace on GCP
=========================

In this template, we show how to deploy a service account that can be used to deploy Databricks workspace on GCP.

In this template, we create a [Service Account](https://cloud.google.com/iam/docs/service-account-overview) with minimal permissions that allow to provision a workspace with both managed and user-provisioned VPC.


## Requirements

- Your user that you use to delegate from needs a set of permissions detailed [here](https://docs.gcp.databricks.com/administration-guide/cloud-configurations/gcp/permissions.html#required-user-permissions-or-service-account-permissions-to-create-a-workspace)

- The built-in roles of Kubernetes Admin and Compute Storage Admin needs to be available

- you need to run `glcoud auth application-default login` and login with your google account

## Run as an SA 

You can do the same thing by provisionning a service account that will have the same permissions - and associate the key associated to it.


## Run the tempalte

- You need to fill in the variables.tf 
- run `terraform init`
- run `teraform apply`