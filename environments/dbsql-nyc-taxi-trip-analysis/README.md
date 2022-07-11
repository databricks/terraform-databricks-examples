# Terraform configuration for NYC Taxi Trip Analysis

This is a copy of the NYC Taxi Trip Analysis dashboard as provisioned as a sample dashboard in Databricks SQL.

To deploy this to the workspace of your choice, use one of the authentication mechanisms
described on https://registry.terraform.io/providers/databricks/databricks/latest/docs#authentication.

For example, if you wish to use a PAT, you can configure the following environment variables:
```shell
$ export DATABRICKS_HOST=https://[WORKSPACE].cloud.databricks.com/
$ export DATABRICKS_TOKEN=[MY PERSONAL ACCESS TOKEN]
```

Then, to deploy the sample dashboard, run:
```shell
$ terraform init
$ terraform apply
```

Then, to destroy the sample dashboard, its queries, and endpoint, run:
```shell
$ terraform destroy
```
