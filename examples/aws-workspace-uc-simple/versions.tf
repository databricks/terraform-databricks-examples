terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "=4.57.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "=3.4.1"
    }

    time = {
      source  = "hashicorp/time"
      version = "=0.9.1"
    }

    databricks = {
      source  = "databricks/databricks"
      version = "=1.12.0"
    }

  }
}