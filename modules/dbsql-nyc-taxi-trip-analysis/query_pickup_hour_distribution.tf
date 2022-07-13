resource "databricks_sql_query" "pickup_hour_distribution" {
  data_source_id = databricks_sql_endpoint.this.data_source_id

  name = "${var.name_prefix}Pickup Hour Distribution"
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

  query = file("${path.module}/files/pickup_hour_distribution.sql")
}

resource "databricks_permissions" "query_pickup_hour_distribution" {
  sql_query_id = databricks_sql_query.pickup_hour_distribution.id

  access_control {
    group_name       = data.databricks_group.users.display_name
    permission_level = "CAN_RUN"
  }
}

resource "databricks_sql_visualization" "pickup_hour_distribution_chart" {
  query_id = databricks_sql_query.pickup_hour_distribution.id
  type     = "chart"
  name     = "Chart"

  options = jsonencode({
    "version" : 2,
    "globalSeriesType" : "column",
    "sortX" : true,
    "legend" : {
      "enabled" : false,
      "placement" : "auto",
      "traceorder" : "normal"
    },
    "xAxis" : {
      "type" : "-",
      "labels" : {
        "enabled" : true
      },
      "title" : {
        "text" : "Pickup Hour"
      }
    },
    "yAxis" : [
      {
        "type" : "linear",
        "title" : {
          "text" : "Number of Rides"
        }
      },
      {
        "type" : "linear",
        "opposite" : true,
        "title" : {
          "text" : null
        }
      }
    ],
    "alignYAxesAtZero" : false,
    "error_y" : {
      "type" : "data",
      "visible" : true
    },
    "series" : {
      "stacking" : null,
      "error_y" : {
        "type" : "data",
        "visible" : true
      }
    },
    "seriesOptions" : {
      "number" : {
        "color" : "#20738F"
      },
      "num" : {
        "color" : "#20738F"
      },
      "Number_of_Rides" : {
        "color" : "#20738F"
      },
      "Number of Rides" : {
        "color" : "#20738F"
      }
    },
    "valuesOptions" : {},
    "direction" : {
      "type" : "counterclockwise"
    },
    "sizemode" : "diameter",
    "coefficient" : 1,
    "numberFormat" : "0,0[.]00000",
    "percentFormat" : "0[.]00%",
    "textFormat" : "{{ @@y }} Pickups at {{ @@x}}",
    "missingValuesAsZero" : true,
    "useAggregationsUi" : false,
    "showDataLabels" : false,
    "dateTimeFormat" : "YYYY-MM-DD HH:mm",
    "columnConfigurationMap" : {
      "x" : {
        "column" : "Pickup Hour"
      },
      "y" : [
        {
          "column" : "Number of Rides"
        }
      ]
    },
    "swappedAxes" : false,
    "showPlotlyControls" : true,
    "hideXAxis" : false
  })
}
