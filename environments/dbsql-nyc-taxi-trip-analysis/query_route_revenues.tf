resource "databricks_sql_query" "route_revenues" {
  data_source_id = databricks_sql_endpoint.this.data_source_id

  name = "Route Revenues"
  tags = [
    "Sample",
  ]

  parameter {
    name  = "pickup_date"
    title = "Date range"

    datetime_range {
      value = ""
      // start = "2016-01-01 12:07"
      // end   = "2016-01-16 12:07"
    }
  }

  parameter {
    name  = "pickup_zip"
    title = "Pickup Zip Code"

    enum {
      options = local.pickup_zip_options

      values = [
        "10001",
      ]

      multiple {
        prefix    = ""
        suffix    = ""
        separator = ","
      }
    }
  }

  query = file("query_route_revenues.sql")
}

resource "databricks_sql_visualization" "route_revenues_table" {
  query_id = databricks_sql_query.route_revenues.id
  type     = "table"
  name     = "Table"
  options  = jsonencode({})
}
