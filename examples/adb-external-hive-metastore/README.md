# ADB workspace with external hive metastore

Credits to alexey.ott@databricks.com and bhavin.kukadia@databricks.com for notebook logic for database initialization steps.
This architecture will be deployed:

![alt text](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/examples/adb-external-hive-metastore/images/adb-external-hive-metastore.png?raw=true)

# Get Started:
This template will complete 99% process for external hive metastore deployment with Azure Databricks, using hive version 3.1.0. The last 1% step is just to `run only once` a pre-deployed Databricks job to initialize the external hive metastore. After successful deployment, your cluster can connect to external hive metastore (using azure sql database). 

On your local machine:

1. Clone this repository to local.
2. Provide values to variables, some variabes will have default values defined. See inputs section below on optional/required variables.
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
