# This module expects:
# - an AWS provider with permission to manage IAM roles/policies for the account
#   that owns the S3 bucket(s) backing the external location(s)
# - a Databricks provider authenticated to a UC-enabled workspace whose assigned
#   metastore is the one you want the storage credential / external locations in
#   (workspace-level auth), or an account-level provider with metastore_id set on
#   the resources.
#
# Example:
#
#   provider "aws" {
#     region  = "ap-southeast-2"
#     profile = "my-aws-profile"
#   }
#
#   provider "databricks" {
#     profile = "my-workspace-profile"
#   }
