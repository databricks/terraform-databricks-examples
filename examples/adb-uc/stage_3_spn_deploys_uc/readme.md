### Stage 3 SPN deploys UC resources

In this stage, we use a SPN that has been granted Databricks Account Admin role to deploy UC resouces. This SPN does not require AAD Global Admin role.

Stage 3 deployment steps:

az login as SPN:

```bash
az login --service-principal -u <app-id> -p <password-or-cert> --tenant <tenant>
```

Change the `account_id` attribute in the Databricks provider, you should already have the account id info from stage 2, if not you can get it from Azure Databricks Account Console, or reach out to your Databricks contacts:

```
provider "databricks" {
  alias      = "azure_account"
  host       = "https://accounts.azuredatabricks.net"
  account_id = "34f1bb02-ac1d-4c04-b051-58e094fa668c" // Databricks can provide
  auth_type  = "azure-cli"
}
```

Supply your Databricks workspace Resource ID to the variable `databricks_resource_id`.

In this stage 3 folder, run

```bash
terraform init & terraform apply
```

This completes Stage 3 and you should now have UC resources deployed, including UC metastore.