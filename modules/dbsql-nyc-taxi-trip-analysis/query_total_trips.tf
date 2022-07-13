resource "databricks_sql_query" "total_trips" {
  data_source_id = var.data_source_id

  name = "${var.name_prefix}Total Trips"
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

  query = file("${path.module}/files/total_trips.sql")
}

resource "databricks_permissions" "query_total_trips" {
  sql_query_id = databricks_sql_query.total_trips.id

  access_control {
    group_name       = data.databricks_group.users.display_name
    permission_level = "CAN_RUN"
  }
}

resource "databricks_sql_visualization" "total_trips_counter" {
  query_id = databricks_sql_query.total_trips.id
  type     = "counter"
  name     = "Counter"
  options = jsonencode({
    "counterLabel" : "Total Trips",
    "counterColName" : "total_trips",
    "rowNumber" : 1,
    "targetRowNumber" : 1,
    "stringDecimal" : 0,
    "stringDecChar" : ".",
    "stringThouSep" : ",",
    "tooltipFormat" : "0,0.000"
  })
}
