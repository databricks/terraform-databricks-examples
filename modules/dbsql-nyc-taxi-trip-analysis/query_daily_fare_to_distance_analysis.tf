resource "databricks_sql_query" "daily_fare_to_distance_analysis" {
  data_source_id = databricks_sql_endpoint.this.data_source_id

  name = "${local.name_prefix}Daily Fare to Distance Analysis"
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

  query = file("${path.module}/files/daily_fare_to_distance_analysis.sql")
}

resource "databricks_permissions" "query_daily_fare_to_distance_analysis" {
  sql_query_id = databricks_sql_query.daily_fare_to_distance_analysis.id

  access_control {
    group_name       = data.databricks_group.users.display_name
    permission_level = "CAN_RUN"
  }
}

resource "databricks_sql_visualization" "daily_fare_to_distance_analysis_chart" {
  query_id = databricks_sql_query.daily_fare_to_distance_analysis.id
  type     = "chart"
  name     = "Fare by Distance"

  options = jsonencode({
    "version" : 2,
    "globalSeriesType" : "scatter",
    "sortX" : true,
    "legend" : {
      "enabled" : true,
      "placement" : "below",
      "traceorder" : "normal"
    },
    "xAxis" : {
      "type" : "-",
      "labels" : {
        "enabled" : true
      },
      "title" : {
        "text" : "Trip Distance (miles)"
      }
    },
    "yAxis" : [
      {
        "type" : "linear",
        "title" : {
          "text" : "Fare Amount (USD)"
        },
        "rangeMin" : null
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
      "Sunday" : {
        "color" : "#20738F"
      },
      "Monday" : {
        "color" : "#FCA137"
      },
      "Tuesday" : {
        "color" : "#FE3227"
      },
      "Wednesday" : {
        "color" : "#1FA873"
      },
      "Thursday" : {
        "color" : "#FFD465"
      },
      "Friday" : {
        "color" : "#9C2638"
      },
      "Saturday" : {
        "color" : "#85CADE"
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
    "textFormat" : "Trip Distance: {{ @@x }} and Fare Amount: {{ @@y }}",
    "missingValuesAsZero" : true,
    "useAggregationsUi" : false,
    "showDataLabels" : false,
    "dateTimeFormat" : "YYYY-MM-DD HH:mm",
    "columnConfigurationMap" : {
      "x" : {
        "column" : "trip_distance"
      },
      "y" : [
        {
          "column" : "fare_amount"
        }
      ],
      "series" : {
        "column" : "day_of_week"
      }
    },
    "swappedAxes" : false,
    "showPlotlyControls" : true
  })
}
