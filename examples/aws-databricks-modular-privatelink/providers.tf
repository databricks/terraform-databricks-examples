terraform {
  /*
  backend "s3" {
    bucket         = "tf-backend-bucket-haowang" # Replace this with your bucket name!
    key            = "global/s3-databricks-project/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "tf-backend-dynamodb-databricks-project" # Replace this with your DynamoDB table name!
    encrypt        = true
  }
  */
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

// initialize provider in "MWS" mode to provision new workspace
provider "databricks" {
  alias      = "mws"
  host       = "https://accounts.cloud.databricks.com"
  account_id = var.databricks_account_id
  username   = var.databricks_account_username
  password   = var.databricks_account_password
  auth_type  = "basic"
}
