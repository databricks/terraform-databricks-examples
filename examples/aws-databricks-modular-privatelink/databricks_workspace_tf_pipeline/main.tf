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

provider "databricks" {
  alias         = "workspace"
  host          = var.databricks_host
  account_id    = var.databricks_account_id
  client_id     = var.client_id
  client_secret = var.client_secret
}

provider "aws" {
  region = var.region
}

module "starter_catalogs" {
  source = "./modules/uc_catalogs_init"
  providers = {
    databricks = databricks.workspace
    aws        = aws // using default aws provider
  }
  for_each = local.init_uc_catalogs

  catalog_name            = lower(each.value.catalog_name)
  s3_bucket_name          = lower(each.value.s3_bucket_name)
  iam_role_name           = each.value.iam_role_name
  storage_credential_name = each.value.storage_credential_name
  external_location_name  = each.value.external_location_name
}

resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

locals {
  prefix  = "demo${random_string.naming.result}"
  configs = yamldecode(file("${path.module}/configs/structured-output.yaml"))

  init_uc_catalogs = {
    for cfg in local.configs : cfg.catalog_name => cfg
  }
}
