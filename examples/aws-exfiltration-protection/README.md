# Provisioning AWS Databricks workspace with a Hub & Spoke firewall for data exfiltration protection

This example is using the [aws-exfiltration-protection](../../modules/aws-exfiltration-protection) module.

This template provides an example deployment of AWS Databricks E2 workspace with a Hub & Spoke firewall for data exfiltration protection. Details are described in [Data Exfiltration Protection With Databricks on AWS](https://www.databricks.com/blog/2021/02/02/data-exfiltration-protection-with-databricks-on-aws.html). 

## Overall Architecture

![alt text](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/modules/aws-exfiltration-protection/images/aws-exfiltration-classic.png?raw=true)

## How to use

> **Note**  
> If you are using AWS Firewall to block most traffic but allow the URLs that Databricks needs to connect to, please update the configuration based on your region. You can get the configuration details for your region from [Firewall Appliance](https://docs.databricks.com/administration-guide/cloud-configurations/aws/customer-managed-vpc.html#firewall-appliance-infrastructure) document.
> 
> You can optionally enable Private Link in the variables. Enabling Private link on AWS requires Databricks "Enterprise" tier which is configured at the Databricks account level.


1. Reference this module using one of the different [module source types](https://developer.hashicorp.com/terraform/language/modules/sources)
2. Add a `variables.tf` with the same content in [variables.tf](variables.tf)
3. Add a `terraform.tfvars` file and provide values to each defined variable
4. Configure the following environment variables:
    * TF_VAR_databricks_account_username, set to the value of your Databricks account-level admin username.
    * TF_VAR_databricks_account_password, set to the value of the password for your Databricks account-level admin user.
    * TF_VAR_databricks_account_id, set to the value of the ID of your Databricks account. You can find this value in the corner of your Databricks account console.
5. (Optional) Configure your [remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/s3)
6. Run `terraform init` to initialize terraform and get provider ready.
7. Run `terraform plan` to validate and preview the deployment.
8. Run `terraform apply` to create the resources.
9. Run `terraform output -json` to print url (host) of the created Databricks workspace.
