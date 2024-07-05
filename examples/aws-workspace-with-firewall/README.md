# Provisioning AWS Databricks E2 with an AWS Firewall

This example is using the [aws-workspace-with-firewall](../../modules/aws-workspace-with-firewall) module.

This template provides an example of a simple deployment of AWS Databricks E2 workspace with an AWS Firewall.

## Overall Architecture

![alt text](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/modules/aws-workspace-with-firewall/images/aws-workspace-with-firewall.png?raw=true)

## How to use

1. Reference this module using one of the different [module source types](https://developer.hashicorp.com/terraform/language/modules/sources)
2. Add a `variables.tf` with the same content in [variables.tf](variables.tf)
3. Add a `terraform.tfvars` file and provide values to each defined variable
4. Configure the following environment variables:
    * TF_VAR_databricks_account_client_id, set to the value of application ID of your Databricks account-level service principal with admin permission.
    * TF_VAR_databricks_account_client_secret, set to the value of the client secret for your Databricks account-level service principal.
    * TF_VAR_databricks_account_id, set to the value of the ID of your Databricks account. You can find this value in the corner of your Databricks account console.
5. Add a `output.tf` file.
6. (Optional) Configure your [remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/s3)
7. Run `terraform init` to initialize terraform and get provider ready.
8. Run `terraform apply` to create the resources.
