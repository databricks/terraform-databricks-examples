AWS Databricks Unity Catalog - One apply
=========================

Using this template, you can deploy all the necessary resources in order to have a simple Databricks AWS workspace with Unity Catalog enabled.

This is a one apply template, you will create the base aws resources for a workspace (VPC, subnets, VPC endpoints, S3 Bucket and cross account IAM role) and the unity catalog metastore and cross account role. 

In order to run this template, you need to have an `account admin` identity, preferably with a service principal. Running with a user account also works, but one should not include the `account owner` in the terraform UC admin or databricks users list as you cannot destroy yourself from the admin list. 

When running tf configs for UC resources, due to sometimes requires a few minutes to be ready and you may encounter errors along the way, so you can either wait for the UI to be updated before you apply and patch the next changes; or specifically add depends_on to account level resources. We tried to add the necessary wait times but should you encounter an error just apply again and you should be good to go.

## Get Started

> Step 1: Fill in values in `terraform.tfvars`; also configure env necessary variables for AWS provider authentication.

> Step 2: Run `terraform init` and `terraform apply` to deploy the resources. This will deploy both AWS resources that Unity Catalog requires and Databricks Account Level resources.
