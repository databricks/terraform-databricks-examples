# Provisioning AWS Databricks E2

This template provides an example of a simple deployment of AWS Databricks E2 workspace.

> **Note**  
> The following [Terraform guide](https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/aws-workspace) provides step-by-step instructions for this deployment. 

## Overall Architecture

![alt text](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/modules/aws-workspace-basic/images/aws-workspace-basic.png?raw=true)

Resources to be created:
* VPC and VPC endpoints
* S3 Root bucket
* Cross-account IAM role
* Databricks E2 workspace


## How to use

> **Note**  
> You can customize this module by adding, deleting or updating the Azure resources to adapt the module to your requirements.
> A deployment example using this module can be found in [examples/aws-workspace-basic](../../examples/aws-workspace-basic)

1. Reference this module using one of the different [module source types](https://developer.hashicorp.com/terraform/language/modules/sources)
2. Add a `variables.tf` with the same content in [variables.tf](variables.tf)
3. Add a `terraform.tfvars` file and provide values to each defined variable
4. Configure the following environment variables:
    * TF_VAR_databricks_account_username, set to the value of your Databricks account-level admin username.
    * TF_VAR_databricks_account_password, set to the value of the password for your Databricks account-level admin user.
    * TF_VAR_databricks_account_id, set to the value of the ID of your Databricks account. You can find this value in the corner of your Databricks account console.
5. Add a `output.tf` file.
6. (Optional) Configure your [remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/s3)
7. Run `terraform init` to initialize terraform and get provider ready.
8. Run `terraform apply` to create the resources.