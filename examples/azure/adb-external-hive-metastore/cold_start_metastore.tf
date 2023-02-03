# automate job to init schema of the database, prep to be hive metastore
data "databricks_current_user" "me" {
  depends_on = [azurerm_databricks_workspace.this]
}

resource "databricks_notebook" "ddl" {
  source = "./coldstart/metastore_coldstart.py"                #local notebook
  path   = "${data.databricks_current_user.me.home}/coldstart" #remote notebook
}

resource "databricks_job" "metastoresetup" {
  name                = "Initialize external hive metastore"
  existing_cluster_id = databricks_cluster.coldstart[0].id
  notebook_task {
    notebook_path = databricks_notebook.ddl.path
  }
}
