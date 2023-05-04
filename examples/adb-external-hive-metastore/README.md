# ADB workspace with external hive metastore

Credits to alexey.ott@databricks.com and bhavin.kukadia@databricks.com for notebook logic for database initialization steps.
This architecture will be deployed:

![alt text](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/examples/adb-external-hive-metastore/images/adb-external-hive-metastore.png?raw=true)

# Get Started:
There are 2 stages of deployment: stage 1 will deploy all the major infra components including the Databricks workspace and the sql server & database that serves as your external hive metastore. After stage 1 is complete, you need to log into your workspace (this will turn you into the first workspace admin), then you need to navigate into `stage-2-workspace-objects` to deploy remaining components like secret scope, cluster, job, notebook, etc. These are the workspace objects that since we are using `az cli` auth type with Databricks provider at workspace level, we rely on having the caller identity being inside the workspace before stage 2. 

Stage 1:
On your local machine:

1. Clone this repository to local.
2. Provide values to variables, some variabes will have default values defined. See inputs section below on optional/required variables.
3. For step 2, variables for db_username and db_password, you can also use your environment variables: terraform will automatically look for environment variables with name format TF_VAR_xxxxx.

    `export TF_VAR_db_username=yoursqlserveradminuser`

    `export TF_VAR_db_password=yoursqlserveradminpassword`
4. Init terraform and apply to deploy resources:
    
    `terraform init`
    
    `terraform apply`

After the deployment of stage 1 completes, you should have a Databricks workspace running in your own VNet, a sql server and azure sql database in another VNet, and private link connection from your Databricks VNet to your sql server.

Now we need to manually log into the Databricks workspace, such that you are added into the workspace (since you have Azure contributor role on the workspace resource, at lauch workspace time, you will be added as workspace admin). After first login, you can now proceed to stage 2.

Stage 2:
1. Navigate into `stage-2-workspace-objects` folder.
2. Configure input variables, see samples inside provided `terraform.tfvars`. You can get the values from stage 1 outputs.
3. Init terraform and apply to deploy resources:
    
    `terraform init`
    
    `terraform apply`

At this step, we've completes most of the work. The final step is to manually trigger the deployed job to run it only once.

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
