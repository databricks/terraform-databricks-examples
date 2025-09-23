# ADB workspace with external hive metastore

Credits to alexey.ott@databricks.com and bhavin.kukadia@databricks.com for notebook logic for database initialization steps.
This architecture will be deployed:

![alt text](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/examples/adb-external-hive-metastore/images/adb-external-hive-metastore.png?raw=true)

# Get Started:
This template will complete 99% process for external hive metastore deployment with Azure Databricks, using hive version 3.1.0. The last 1% step is just to `run only once` a pre-deployed Databricks job to initialize the external hive metastore. After successful deployment, your cluster can connect to external hive metastore (using azure sql database). 

On your local machine:

1. Clone this repository to local.
2. Update `terraform.tfvars` file and provide values to each defined variable. Some variabes may have default values defined in `variables.tf` file. 
3. For step 2, variables for db_username and db_password, you can also use your environment variables: terraform will automatically look for environment variables with name format TF_VAR_xxxxx.

    `export TF_VAR_db_username=yoursqlserveradminuser`

    `export TF_VAR_db_password=yoursqlserveradminpassword`
4. Init terraform and apply to deploy resources:
    
    `terraform init`
    
    `terraform apply`

Now we log into the Databricks workspace, such that you are added into the workspace (since the user identity deployed workspace and have at least Contributor role on the workspace, upon lauching workspace, user identity will be added as workspace admin).

Once logged into workspace, the final step is to manually trigger the pre-deployed job. 

Go to databricks workspace - Job - run the auto-deployed job only once; this is to initialize the database with metastore schema.

![alt text](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/examples/adb-external-hive-metastore/images/manual-last-step.png?raw=true)

Then you can verify in a notebook:

![alt text](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/examples/adb-external-hive-metastore/images/test-metastore.png?raw=true)

We can also check inside the sql db (metastore), we've successfully linked up cluster to external hive metastore and registered the table here:

![alt text](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/examples/adb-external-hive-metastore/images/metastore-content.png?raw=true)

Now you can config all other clusters to use this external metastore, using the same spark conf and env variables of cold start cluster.


### Notes: Migrate from your existing managed metastore to external metastore

Refer to tutorial: https://kb.databricks.com/metastore/create-table-ddl-for-metastore.html

```python
dbs = spark.catalog.listDatabases()
for db in dbs:
    f = open("your_file_name_{}.ddl".format(db.name), "w")
    tables = spark.catalog.listTables(db.name)
    for t in tables:
        DDL = spark.sql("SHOW CREATE TABLE {}.{}".format(db.name, t.name))
        f.write(DDL.first()[0])
        f.write("\n")
    f.close()
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.0.0 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >=1.52.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=4.0.0 |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | >=1.52.0 |
| <a name="provider_external"></a> [external](#provider\_external) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_databricks_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/databricks_workspace) | resource |
| [azurerm_key_vault.akv1](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_access_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_secret.hivepwd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.hiveurl](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.hiveuser](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_mssql_database.sqlmetastore](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database) | resource |
| [azurerm_mssql_server.metastoreserver](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server) | resource |
| [azurerm_mssql_server_extended_auditing_policy.mssqlpolicy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_server_extended_auditing_policy) | resource |
| [azurerm_mssql_virtual_network_rule.sqlservervnetrule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_virtual_network_rule) | resource |
| [azurerm_network_security_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_private_dns_zone.dnsmetastore](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.metastorednszonevnetlink](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_endpoint.sqlserverpe](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_storage_account.sqlserversa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_subnet.plsubnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.sqlsubnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_network_security_group_association.public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_virtual_network.sqlvnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [databricks_cluster.coldstart](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/cluster) | resource |
| [databricks_job.metastoresetup](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/job) | resource |
| [databricks_notebook.ddl](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/notebook) | resource |
| [databricks_secret_scope.kv](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret_scope) | resource |
| [random_string.naming](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [databricks_current_user.me](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/current_user) | data source |
| [databricks_spark_version.latest_lts](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/spark_version) | data source |
| [external_external.me](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_db_password"></a> [db\_password](#input\_db\_password) | Database administrator password | `string` | n/a | yes |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | Database administrator username | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Azure Subscription ID to deploy the workspace into | `string` | n/a | yes |
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | Set to true to create a new Azure Resource Group. Set to false to use an existing Resource Group specified in existing\_resource\_group\_name | `bool` | `true` | no |
| <a name="input_dbfs_prefix"></a> [dbfs\_prefix](#input\_dbfs\_prefix) | n/a | `string` | `"dbfs"` | no |
| <a name="input_existing_resource_group_name"></a> [existing\_resource\_group\_name](#input\_existing\_resource\_group\_name) | Specify the name of an existing Resource Group only if you do not want Terraform to create a new one | `string` | `""` | no |
| <a name="input_node_type"></a> [node\_type](#input\_node\_type) | instance type | `string` | `"Standard_DS3_v2"` | no |
| <a name="input_private_subnet_endpoints"></a> [private\_subnet\_endpoints](#input\_private\_subnet\_endpoints) | n/a | `list` | `[]` | no |
| <a name="input_rglocation"></a> [rglocation](#input\_rglocation) | n/a | `string` | `"southeastasia"` | no |
| <a name="input_spokecidr"></a> [spokecidr](#input\_spokecidr) | n/a | `string` | `"10.179.0.0/20"` | no |
| <a name="input_sqlvnetcidr"></a> [sqlvnetcidr](#input\_sqlvnetcidr) | n/a | `string` | `"10.178.0.0/20"` | no |
| <a name="input_workspace_prefix"></a> [workspace\_prefix](#input\_workspace\_prefix) | n/a | `string` | `"adb"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azure_resource_group_id"></a> [azure\_resource\_group\_id](#output\_azure\_resource\_group\_id) | The Azure resource group ID |
| <a name="output_databricks_azure_workspace_resource_id"></a> [databricks\_azure\_workspace\_resource\_id](#output\_databricks\_azure\_workspace\_resource\_id) | **Depricated** |
| <a name="output_keyvault_id"></a> [keyvault\_id](#output\_keyvault\_id) | The Azure KeyVault ID |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | **Depricated** |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | The Databricks workspace ID |
| <a name="output_workspace_url"></a> [workspace\_url](#output\_workspace\_url) | The Databricks workspace URL |
<!-- END_TF_DOCS -->
