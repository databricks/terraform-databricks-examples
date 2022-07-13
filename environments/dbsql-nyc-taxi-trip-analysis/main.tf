data "databricks_current_user" "me" {
  # Loads the current user so that we can interpolate their name
  # in the names of the dashboard and queries.
}

resource "databricks_sql_endpoint" "this" {
  name         = "Sample endpoint"
  cluster_size = "Small"

  enable_photon             = true
  enable_serverless_compute = true
}

module "dbsql_nyc_taxi_trip_analysis" {
  source = "../../modules/dbsql-nyc-taxi-trip-analysis"

  name_prefix    = "[${data.databricks_current_user.me.user_name}] "
  data_source_id = databricks_sql_endpoint.this.data_source_id
}

output "dashboard_url" {
  value = "${data.databricks_current_user.me.workspace_url}/sql/dashboards/${module.dbsql_nyc_taxi_trip_analysis.dashboard_id}?&p_pickup_date=2016-01-01+12:07--2016-01-16+12:07"
}
