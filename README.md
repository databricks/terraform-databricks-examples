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
|Azure | [adb-lakehouse](examples/adb-lakehouse/)         | Lakehouse terraform blueprints|
| Azure | [adb-with-private-link-standard](examples/adb-with-private-link-standard/)         | Provisioning Databricks on Azure with Private Link - [Standard deployment](https://learn.microsoft.com/en-us/azure/databricks/administration-guide/cloud-configurations/azure/private-link-standard) |
| Azure | [adb-vnet-injection](examples/adb-vnet-injection/)                                 | A basic example of VNet injected Azure Databricks workspace                                                                                                                                          |
| Azure | [adb-exfiltration-protection](examples/adb-exfiltration-protection/)               | A sample implementation of [Data Exfiltration Protection](https://www.databricks.com/blog/2020/03/27/data-exfiltration-protection-with-azure-databricks.html)                                        |
| Azure | [adb-external-hive-metastore](examples/adb-external-hive-metastore/)               | Example template to implement [external hive metastore](https://learn.microsoft.com/en-us/azure/databricks/data/metastores/external-hive-metastore)                                                  |
| Azure | [adb-kafka](examples/adb-kafka/)                                                   | ADB - single node kafka template                                                                                                                                                                     |
| Azure | [adb-private-links](examples/adb-private-links/)                                   | Azure Databricks Private Links                                                                                                                                                                       |
| Azure | [adb-splunk](examples/adb-splunk/)                                                 | ADB workspace with single VM splunk integration                                                                                                                                                      |
| Azure | [adb-squid-proxy](examples/adb-squid-proxy/)                                       | ADB clusters with HTTP proxy                                                                                                                                                                         |
| Azure | [adb-teradata](examples/adb-teradata/)                                             | ADB with single VM Teradata integration                                                                                                                                                              |
| Azure | [adb-uc](examples/adb-uc/)                                                         | ADB Unity Catalog Process                                                                                                                                                                            |
| Azure | [adb-unity-catalog-basic-demo](examples/adb-unity-catalog-basic-demo/)             | ADB Unity Catalog end to end demo including UC metastore setup, Users/groups sync from AAD to databricks account, UC Catalog, External locations, Schemas, & Access Grants                           |
| Azure | [adb-overwatch](examples/adb-overwatch/)             | Overwatch multi-workspace deployment on Azure                          |
| AWS   | [aws-workspace-basic](examples/aws-workspace-basic/)                               | Provisioning AWS Databricks E2                                                                                                                                                                       |
| AWS   | [aws-workspace-with-firewall](examples/aws-workspace-with-firewall/)               | Provisioning AWS Databricks E2 with an AWS Firewall                                                                                                                                                  |
| AWS   | [aws-exfiltration-protection](examples/aws-exfiltration-protection/)               | An implementation of [Data Exfiltration Protection on AWS](https://www.databricks.com/blog/2021/02/02/data-exfiltration-protection-with-databricks-on-aws.html)                                      |
| AWS   | aws-workspace-with-private-link                                                    | Coming soon                                                                                                                                                                                          |
| AWS   | [aws-databricks-flat](examples/aws-databricks-flat/)                               | AWS Databricks simple example                                                                                                                                                                        |
| AWS   | [aws-databricks-modular-privatelink](examples/aws-databricks-modular-privatelink/) | Deploy multiple AWS Databricks workspaces                                                                                                                                                            |
| AWS   | [aws-databricks-uc](examples/aws-databricks-uc/)                                   | AWS UC                                                                                                                                                                                               |
| AWS   | [aws-databricks-uc-bootstrap](examples/aws-databricks-uc-bootstrap/)               | AWS UC                                                                                                                                                                                               |
| AWS   | [aws-remote-backend-infra](examples/aws-remote-backend-infra/)                     | Simple example on remote backend                                                                                                                                                                     |
| AWS   | [aws-workspace-config](examples/aws-workspace-config/)                             | Configure workspace objects                                                                                 |
| GCP   | [gcp-sa-provisionning](examples/gcp-sa-provisionning/)                                                                         |    Provisionning of the identity with the permissions required to deploy on GCP.                                                                                                                                 |
| GCP   | [gcp-basic](examples/gcp-basic/)                                                                         |    Workspace Deployment with managed vpc                                                                                                                               |
| GCP   | [gcp-byovpc](examples/gcp-byovpc/)                                                                         |    Workspace Deployment with customer-managed vpc                                                                                                                              |
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
| Azure | [adb-overwatch-regional-config](modules/adb-overwatch-regional-config/)                                   | Overwatch regional configuration on Azure                                                                                                                                                 |
| Azure | [adb-overwatch-mws-config](modules/adb-overwatch-mws-config/)                                             | Overwatch multi-workspace deployment on Azure                                                                                                                                             |
| Azure | [adb-overwatch-main-ws](modules/adb-overwatch-main-ws/)                                                   | Main Overwatch workspace deployment                                                                                                                                                       |
| Azure | [adb-overwatch-ws-to-monitor](modules/adb-overwatch-ws-to-monitor/)                                       | Overwatch deployment on the Azure workspace to monitor                                                                                                                                    |
| Azure | [adb-overwatch-analysis](modules/adb-overwatch-analysis/)                                                 | Overwatch analysis notebooks deployment on Azure                                                                                                                                          |
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
