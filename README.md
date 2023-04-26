# terraform-databricks-examples

This repository contains the following:

- Examples of implementing CI/CD pipelines to automate your Terraform deployments using Azure DevOps or Github Actions.

- Multiple examples of Databricks workspace and resources deployment on Azure, AWS and GCP using [Databricks Terraform provider](https://registry.terraform.io/providers/databricks/databricks/latest/docs).

There are two ways to use this repository:

1. Use examples as a reference for your own Terraform code: Please refer to `examples` folder for individual examples.
2. Reuse modules from this repository: Please refer to `modules` folder.

## Repository structure

Code in the repository is organized into following folders:

- `modules` - implementation of specific Terraform modules:
- `examples` - specific instances that use Terraform modules.
- `cicd-pipelines` - Detailed examples of implementing CI/CD pipelines to automate your Terraform deployments using Azure DevOps or Github Actions.

## Repository content

> **Note**  
> For detailed information about the examples, modules or CICD pipelines, refer to `README.md` file inside corresponding folder for a detailed guide on how to setup the CICD pipeline.

### Examples

The folder `examples` contains the following Terraform implementation examples :

| Cloud | Example                                                                            | Description                                                                                                                                                   |
| ----- | ---------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|
|Azure | [adb-lakehouse](examples/adb-lakehouse/)         | Lakehouse terraform blueprints|

### Modules

The folder `modules` contains the following Terraform modules :

| Cloud | Module                                                                                                    | Description                                                                                                                                                                               |
| ----- |-----------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| All   | [databricks-department-clusters](modules/databricks-department-clusters/)                                 | Terraform module that creates Databricks resources for a team                                                                                                                             |
| Azure | [adb-lakehouse](modules/adb-lakehouse/)                                                                   | Lakehouse terraform blueprints                                                                                                                                                            |
| Azure | [adb-lakehouse-uc](modules/adb-lakehouse-uc/)                                                             | Provisioning Unity Catalog resources and accounts principals                                                                                                                              |
| Azure | [adb-with-private-link-standard](modules/adb-with-private-link-standard/)                                 | Provisioning Databricks on Azure with Private Link - Standard deployment                                                                                                                  |
| Azure | [adb-exfiltration-protection](modules/adb-exfiltration-protection/)                                       | A sample implementation of [Data Exfiltration Protection](https://www.databricks.com/blog/2020/03/27/data-exfiltration-protection-with-azure-databricks.html)                             |
| Azure | [adb-with-private-links-exfiltration-protection](modules/adb-with-private-links-exfiltration-protection/) | Provisioning Databricks on Azure with Private Link and [Data Exfiltration Protection](https://www.databricks.com/blog/2020/03/27/data-exfiltration-protection-with-azure-databricks.html) |
| AWS   | [aws-workspace-basic](modules/aws-workspace-basic/)                                                       | Provisioning AWS Databricks E2                                                                                                                                                            |
| AWS   | [aws-workspace-with-firewall](modules/aws-workspace-with-firewall/)                                       | Provisioning AWS Databricks E2 with an AWS Firewall                                                                                                                                       |
| AWS   | [aws-exfiltration-protection](modules/aws-exfiltration-protection/)                                       | An implementation of [Data Exfiltration Protection on AWS](https://www.databricks.com/blog/2021/02/02/data-exfiltration-protection-with-databricks-on-aws.html)                           |
| AWS   | aws-workspace-with-private-link                                                                           | Coming soon                                                                                                                                                                               |
| GCP   | [gcp-sa-provisionning](modules/gcp-sa-provisionning/)                                                                                                |                  Provisions the identity (SA) with the correct permissions  |
| GCP   | [gcp-workspace-basic](modules/gcp-workspace-basic/)                                                                                                |                  Provisions a workspace with managed VPC                                                                                                                                                          |
| GCP   | [gcp-workspace-byovpc](modules/gcp-workspace-byovpc/)                                                                                                |                  Workspace with customer-managed VPC.                                                                                                                                                             |
## CICD pipelines

The folder `cicd-pipelines` contains the following implementation examples of pipeline:

| Tool           | CICD Pipeline                                                                            |
| -------------- | ---------------------------------------------------------------------------------------- |
| Github Actions | [manual-approve-with-github-actions](cicd-pipelines/manual-approve-with-github-actions/) |
| Azure DevOps   | [manual-approve-with-azure-devops](cicd-pipelines/manual-approve-with-azure-devops/)     |
