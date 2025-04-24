terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 4
}

variable "customized_prefix" {
  type    = string
  default = "demo"
}

variable "region" {
  type    = string
  default = "ap-southeast-1"
}

locals {
  prefix = var.customized_prefix == "" ? random_string.naming.result : "${var.customized_prefix}-${random_string.naming.result}"
  config_items = [
    {
      s3_bucket_name          = "${local.prefix}-uc-bucket-001"
      iam_role_name           = "${local.prefix}-iam-role-001"
      region                  = var.region
      storage_credential_name = "${local.prefix}-uc-credential-001"
      external_location_name  = "${local.prefix}-external-location-001"
      catalog_name            = "${local.prefix}-catalog01"
    },
    {
      s3_bucket_name          = "${local.prefix}-uc-bucket-002"
      iam_role_name           = "${local.prefix}-iam-role-002"
      region                  = var.region
      storage_credential_name = "${local.prefix}-uc-credential-002"
      external_location_name  = "${local.prefix}-external-location-002"
      catalog_name            = "${local.prefix}-catalog02"
    },
    {
      s3_bucket_name          = "${local.prefix}-uc-bucket-003"
      iam_role_name           = "${local.prefix}-iam-role-003"
      region                  = var.region
      storage_credential_name = "${local.prefix}-uc-credential-003"
      external_location_name  = "${local.prefix}-external-location-003"
      catalog_name            = "${local.prefix}-catalog03"
    },
  ]

  yaml_structure = local.config_items
}

resource "local_file" "structured_yaml" {
  filename = "../configs/structured-output.yaml"
  content  = yamlencode(local.yaml_structure)
}
