# Workspace S3 Bucket Component
# Creates root S3 bucket for Databricks workspace with security best practices

# Root Storage Bucket (for Databricks workspace) - Always created
resource "aws_s3_bucket" "root" {
  bucket = local.root_bucket_name
  
  tags = merge(local.common_tags, {
    Name       = local.root_bucket_name
    BucketType = "root"
    Purpose    = "Root"
  })
}

# S3 Bucket Server-Side Encryption Configuration - Root Bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "root" {
  bucket = aws_s3_bucket.root.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Note: Versioning is disabled by default (no versioning configuration resources needed)

# S3 Bucket Public Access Block - Root Bucket
resource "aws_s3_bucket_public_access_block" "root" {
  bucket = aws_s3_bucket.root.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Databricks-generated Root Bucket Policy
data "databricks_aws_bucket_policy" "root" {
  bucket = aws_s3_bucket.root.bucket
}

# Root Storage Bucket Policy (for Databricks workspace)
resource "aws_s3_bucket_policy" "root" {
  bucket = aws_s3_bucket.root.id
  policy = data.databricks_aws_bucket_policy.root.json
  
  depends_on = [aws_s3_bucket_public_access_block.root]
}


