terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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
      version = ">= 1.2.0, < 2.0.0"
    }

  }
}