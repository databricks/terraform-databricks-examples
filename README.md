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
| Azure | [adb-basic](examples/adb-basic/)                                                   | A basic example of Azure Databricks workspace deployment                                                                                                      |
| Azure | [adb-exfiltration-protection](examples/adb-exfiltration-protection/)               | A sample implementation of [Data Exfiltration Protection](https://www.databricks.com/blog/2020/03/27/data-exfiltration-protection-with-azure-databricks.html) |
| Azure | [adb-external-hive-metastore](examples/adb-external-hive-metastore/)               | Example template to implement [external hive metastore](https://learn.microsoft.com/en-us/azure/databricks/data/metastores/external-hive-metastore)           |
| Azure | [adb-kafka](examples/adb-kafka/)                                                   | ADB - single node kafka template                                                                                                                              |
| Azure | [adb-private-links](examples/adb-private-links/)                                   | Azure Databricks Private Links                                                                                                                                |
| Azure | [adb-private-links-general](examples/adb-private-links-general/)                   | Azure Databricks Private Links General Implementation                                                                                                         |
| Azure | [adb-splunk](examples/adb-splunk/)                                                 | ADB workspace with single VM splunk integration                                                                                                               |
| Azure | [adb-squid-proxy](examples/adb-squid-proxy/)                                       | ADB clusters with HTTP proxy                                                                                                                                  |
| Azure | [adb-teradata](examples/adb-teradata/)                                             | ADB with single VM Teradata integration                                                                                                                       |
| Azure | [adb-uc](examples/adb-uc/)                                                         | ADB Unity Catalog Process                                                                                                                                     |
| AWS   | [aws-databricks-flat](examples/aws-databricks-flat/)                               | AWS Databricks simple example                                                                                                                                 |
| AWS   | [aws-databricks-modular-privatelink](examples/aws-databricks-modular-privatelink/) | Deploy multiple AWS Databricks workspaces                                                                                                                     |
| AWS   | [aws-databricks-uc](examples/aws-databricks-uc/)                                   | AWS UC                                                                                                                                                        |
| AWS   | [aws-databricks-uc-bootstrap](examples/aws-databricks-uc-bootstrap/)               | AWS UC                                                                                                                                                        |
| AWS   | [aws-remote-backend-infra](examples/aws-remote-backend-infra/)                     | Simple example on remote backend                                                                                                                              |
| AWS   | [aws-workspace-config](examples/aws-workspace-config/)                             | Configure workspace objects                                                                                                                                   |
| GCP   | [gcp-sa-provisionning](examples/gcp-sa-provisionning/)                                                                         |    Service Account provisionning                                                                                                                                       |
| GCP   | [gcp-sa-lakehouse](examples/gcp-sa-lakehouse/)                                                                         |    Workspace Deployment on GCP                                                                                                                                       |
| GCP   | [gcp-byovpc](examples/gcp-byovpc/)                                                                         |    Workspace Deployment with custom VPC Template                                                                                                                                  |

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
| GCP   | Coming soon                                                                                               |                                                                                                                                                                                           |

## CICD pipelines

The folder `cicd-pipelines` contains the following implementation examples of pipeline:

| Tool           | CICD Pipeline                                                                            |
| -------------- | ---------------------------------------------------------------------------------------- |
| Github Actions | [manual-approve-with-github-actions](cicd-pipelines/manual-approve-with-github-actions/) |
| Azure DevOps   | [manual-approve-with-azure-devops](cicd-pipelines/manual-approve-with-azure-devops/)     |
