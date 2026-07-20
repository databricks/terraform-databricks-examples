# The caller owns the bucket; the module wires up IAM + Unity Catalog.
resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

module "uc_external_location_file_events" {
  source = "../../modules/aws-uc-external-location-file-events"

  name_prefix           = var.name_prefix
  databricks_account_id = var.databricks_account_id
  bucket_names          = [aws_s3_bucket.this.id]

  external_locations = [
    {
      name    = var.external_location_name
      url     = "s3://${aws_s3_bucket.this.id}/${var.external_location_prefix}"
      comment = "Landing zone with managed SQS file events"
    }
  ]

  credential_grants = var.grant_principal == "" ? [] : [
    {
      principal  = var.grant_principal
      privileges = ["CREATE_EXTERNAL_LOCATION", "READ_FILES", "WRITE_FILES"]
    }
  ]

  location_grants = var.grant_principal == "" ? [] : [
    {
      principal  = var.grant_principal
      privileges = ["BROWSE", "READ_FILES", "WRITE_FILES", "CREATE_EXTERNAL_TABLE", "CREATE_EXTERNAL_VOLUME"]
    }
  ]
}
