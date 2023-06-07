# automate job to init schema of the database, prep to be hive metastore
resource "databricks_notebook" "ddl" {
  source = "../coldstart/metastore_coldstart.py"               #local notebook
  path   = "${data.databricks_current_user.me.home}/coldstart" #remote notebook
}

resource "databricks_job" "metastoresetup" {
  name                = "Initialize external hive metastore"
  existing_cluster_id = databricks_cluster.coldstart.id
  notebook_task {
    notebook_path = databricks_notebook.ddl.path
  }
}
