# terraform-databricks-examples

This repository contains the following: 

* Examples of implementing CI/CD pipelines to automate your Terraform deployments using Azure DevOps or Github Actions.

* Multiple examples of Databricks workspace and resources deployment on Azure, AWS and GCP using [Databricks Terraform provider](https://registry.terraform.io/providers/databricks/databricks/latest/docs).

There are two ways to use this repository:
1. Use examples as a reference for your own Terraform code: Please refer to `examples` folder for individual examples.   
2. Reuse modules from this repository: Please refer to `modules` folder.


## Repository structure

Code in the repository is organized into following folders:

* `modules` - implementation of specific Terraform modules:
  * [databricks-department-clusters](modules/databricks-department-clusters/) - Terraform module that creates Databricks resources for a team.
* `examples` - specific instances that use Terraform modules.
* `cicd-pipelines` - Detailed examples of implementing CI/CD pipelines to automate your Terraform deployments using Azure DevOps or Github Actions.

## Repository content

### Examples

The folder `examples` contains the following Terraform implementation examples :

| Cloud | Example | Description |
|---|---|---|
| Azure | [adb-basic](examples/adb-basic/) |   |
| AWS | [aws-databricks-flat](examples/aws-databricks-flat/)  |   |
| GCP | Coming soon |   |

### Modules

The folder `modules` contains the following Terraform modules :

| Cloud | Module | Description |
|---|---|---|
| Azure | [adb-basic](modules/adb-basic/) |   |
| AWS | [aws-databricks-flat](modules/aws-databricks-flat/)  |   |
| GCP | Coming soon |   |

## CICD pipelines

The folder `cicd-pipelines` contains the following implementation examples of pipeline:

| Tool  | CICD Pipeline |
|---|---|
| Github Actions | [manual-approve-with-github-actions](cicd-pipelines/manual-approve-with-github-actions/) |
| Azure DevOps | [manual-approve-with-azure-devops](cicd-pipelines/manual-approve-with-azure-devops/) |

Refer to `README.md` file inside corresponding folder for a detailed guide on how to setup the CICD pipeline.