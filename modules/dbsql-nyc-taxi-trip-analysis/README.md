# dbsql-nyc-taxi-trip-analysis

This module deploys a copy of the NYC Taxi Trip Analysis sample dashboard.

## Inputs

| Name           | Description                          | Type   | Default | Required |
|----------------|--------------------------------------|--------|---------|----------|
|`name_prefix`|Prefix for the names of this module's dashboard and queries|string||yes|
|`data_source_id`|Data source ID of the SQL warehouse to run queries against|string||yes|
