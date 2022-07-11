resource "databricks_sql_dashboard" "nyc_taxi_trip_analysis" {
  name = "NYC Taxi Trip Analysis"
  tags = [
    "Sample",
  ]
}

resource "databricks_sql_widget" "daily_fare_trends" {
  dashboard_id     = databricks_sql_dashboard.nyc_taxi_trip_analysis.id
  visualization_id = databricks_sql_visualization.daily_fare_to_distance_analysis_chart.id

  title = "Daily Fare Trends"

  parameter {
    name   = "pickup_date"
    type   = "dashboard-level"
    map_to = "pickup_date"
  }

  parameter {
    name   = "pickup_zip"
    type   = "dashboard-level"
    map_to = "pickup_zip"
  }

  position {
    size_x = 4
    size_y = 9
    pos_x  = 0
    pos_y  = 0
  }
}

resource "databricks_sql_widget" "pickup_hour_distribution" {
  dashboard_id     = databricks_sql_dashboard.nyc_taxi_trip_analysis.id
  visualization_id = databricks_sql_visualization.pickup_hour_distribution_chart.id

  title = "Pickup Hour Distribution"

  parameter {
    name   = "pickup_date"
    type   = "dashboard-level"
    map_to = "pickup_date"
  }

  parameter {
    name   = "pickup_zip"
    type   = "dashboard-level"
    map_to = "pickup_zip"
  }

  position {
    size_x = 4
    size_y = 6
    pos_x  = 0
    pos_y  = 9
  }
}

resource "databricks_sql_widget" "dropoff_hour_distribution" {
  dashboard_id     = databricks_sql_dashboard.nyc_taxi_trip_analysis.id
  visualization_id = databricks_sql_visualization.dropoff_hour_distribution_chart.id

  title = "Dropoff Hour Distribution"

  parameter {
    name   = "pickup_date"
    type   = "dashboard-level"
    map_to = "pickup_date"
  }

  parameter {
    name   = "pickup_zip"
    type   = "dashboard-level"
    map_to = "pickup_zip"
  }

  position {
    size_x = 4
    size_y = 6
    pos_x  = 0
    pos_y  = 15
  }
}

resource "databricks_sql_widget" "total_trips_counter" {
  dashboard_id     = databricks_sql_dashboard.nyc_taxi_trip_analysis.id
  visualization_id = databricks_sql_visualization.total_trips_counter.id

  title = " "

  parameter {
    name   = "pickup_date"
    type   = "dashboard-level"
    map_to = "pickup_date"
  }

  parameter {
    name   = "pickup_zip"
    type   = "dashboard-level"
    map_to = "pickup_zip"
  }

  position {
    size_x = 2
    size_y = 4
    pos_x  = 4
    pos_y  = 0
  }
}

resource "databricks_sql_widget" "route_revenue_attribution" {
  dashboard_id     = databricks_sql_dashboard.nyc_taxi_trip_analysis.id
  visualization_id = databricks_sql_visualization.route_revenues_table.id

  title = "Route Revenue Attribution"

  parameter {
    name   = "pickup_date"
    type   = "dashboard-level"
    map_to = "pickup_date"
  }

  parameter {
    name   = "pickup_zip"
    type   = "dashboard-level"
    map_to = "pickup_zip"
  }

  position {
    size_x = 2
    size_y = 17
    pos_x  = 4
    pos_y  = 4
  }
}
