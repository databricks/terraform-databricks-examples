# Provisioning AWS Databricks E2 with an AWS Firewall

This template provides an example deployment of AWS Databricks E2 workspace with an AWS Firewall. 

> **Note**  
> The following [Terraform guide](https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/aws-e2-firewall-workspace) provides step-by-step instructions for this deployment. 

## Overall Architecture

![alt text](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/modules/aws-workspace-with-firewall/images/aws-workspace-with-firewall.png?raw=true)

Resources to be created:
* VPC and VPC endpoints
* AWS NAT Gateway and Internet Gateway
* AWS Network Firewall
* S3 Root bucket
* Cross-account IAM role
* Databricks E2 workspace


## How to use

> **Note**  
> You can customize this module by adding, deleting or updating the Azure resources to adapt the module to your requirements.
> A deployment example using this module can be found in [examples/aws-workspace-with-firewall](../../examples/aws-workspace-with-firewall)
> If you are using AWS Firewall to block most traffic but allow the URLs that Databricks needs to connect to, please update the configuration based on your region. You can get the configuration details for your region from [Firewall Appliance](https://docs.databricks.com/administration-guide/cloud-configurations/aws/customer-managed-vpc.html#firewall-appliance-infrastructure) document.

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
