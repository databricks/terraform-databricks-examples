# terraform-databricks-examples

This repository contains multiple examples of implementing CI/CD pipelines to deploy Databricks resources using Terraform.

## Repository organization & implemented solutions

Code in the repository is organized into following folders:

* `modules` - implementation of specific Terraform modules:
  * [databricks-department-clusters](modules/databricks-department-clusters/) - Terraform module that creates Databricks resources for a some team.
* `environments` - specific instances that use Terraform modules, providing CI/CD capabilities for deployment. Refer to `README.md` files inside specific folder:
  * [databricks-department-clusters-pat](environments/databricks-department-clusters-pat) - implementation of `databricks-department-clusters` module using authentication with Databricks personal access token (PAT). 
