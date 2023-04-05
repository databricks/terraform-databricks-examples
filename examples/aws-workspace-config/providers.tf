terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}

provider "databricks" {
  alias = "ws1"
  host  = "https://dbc-a1d8d35b-9204.cloud.databricks.com"
  token = var.pat_ws_1
}

provider "databricks" {
  alias = "ws2"
  host  = "https://dbc-5779d7bc-08cb.cloud.databricks.com"
  token = var.pat_ws_2
}
