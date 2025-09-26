# dbsql-nyc-taxi-trip-analysis

This module deploys a copy of the NYC Taxi Trip Analysis sample dashboard.


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >= 1.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | >= 1.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [databricks_permissions.dashboard_nyc_taxi_trip_analysis](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/permissions) | resource |
| [databricks_permissions.query_daily_fare_to_distance_analysis](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/permissions) | resource |
| [databricks_permissions.query_dropoff_hour_distribution](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/permissions) | resource |
| [databricks_permissions.query_pickup_hour_distribution](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/permissions) | resource |
| [databricks_permissions.query_route_revenues](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/permissions) | resource |
| [databricks_permissions.query_total_trips](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/permissions) | resource |
| [databricks_sql_dashboard.nyc_taxi_trip_analysis](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/sql_dashboard) | resource |
| [databricks_sql_query.daily_fare_to_distance_analysis](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/sql_query) | resource |
| [databricks_sql_query.dropoff_hour_distribution](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/sql_query) | resource |
| [databricks_sql_query.pickup_hour_distribution](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/sql_query) | resource |
| [databricks_sql_query.route_revenues](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/sql_query) | resource |
| [databricks_sql_query.total_trips](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/sql_query) | resource |
| [databricks_sql_visualization.daily_fare_to_distance_analysis_chart](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/sql_visualization) | resource |
| [databricks_sql_visualization.dropoff_hour_distribution_chart](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/sql_visualization) | resource |
| [databricks_sql_visualization.pickup_hour_distribution_chart](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/sql_visualization) | resource |
| [databricks_sql_visualization.route_revenues_table](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/sql_visualization) | resource |
| [databricks_sql_visualization.total_trips_counter](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/sql_visualization) | resource |
| [databricks_sql_widget.daily_fare_trends](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/sql_widget) | resource |
| [databricks_sql_widget.dropoff_hour_distribution](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/sql_widget) | resource |
| [databricks_sql_widget.pickup_hour_distribution](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/sql_widget) | resource |
| [databricks_sql_widget.route_revenue_attribution](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/sql_widget) | resource |
| [databricks_sql_widget.total_trips_counter](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/sql_widget) | resource |
| [databricks_group.users](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_data_source_id"></a> [data\_source\_id](#input\_data\_source\_id) | Data source ID of the SQL warehouse to run queries against | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for the names of this module's dashboard and queries | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dashboard_id"></a> [dashboard\_id](#output\_dashboard\_id) | n/a |
<!-- END_TF_DOCS -->
