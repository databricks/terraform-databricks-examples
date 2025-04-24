terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    databricks = {
      source = "databricks/databricks"
    }
  }
}


resource "databricks_mws_networks" "mwsnetwork" {
  account_id         = var.databricks_account_id
  network_name       = "${var.resource_prefix}-network"
  security_group_ids = [var.security_group_id]
  subnet_ids         = var.private_subnet_ids
  vpc_id             = var.vpc_id

  vpc_endpoints {
    rest_api        = [var.workspace_endpoint_id]
    dataplane_relay = [var.scc_relay_endpoint_id]
  }
}
