# Unity Catalog S3 Buckets Component
# Creates metastore and data S3 buckets with security best practices

# Metastore Bucket (for Unity Catalog)
resource "aws_s3_bucket" "metastore" {
  count = var.create_metastore_bucket ? 1 : 0
  
  bucket = local.metastore_bucket_name
  
  tags = merge(local.common_tags, {
    Name       = local.metastore_bucket_name
    BucketType = "metastore"
    Purpose    = "Metastore"
  })
}

resource "aws_s3_bucket" "data" {
  bucket = local.data_bucket_name
  
  tags = merge(local.common_tags, {
    Name       = local.data_bucket_name
    BucketType = "data"
    Purpose    = "Data"
  })
}

# S3 Bucket Server-Side Encryption Configuration - Metastore Bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "metastore" {
  count = var.create_metastore_bucket ? 1 : 0
  
  bucket = aws_s3_bucket.metastore[0].id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Server-Side Encryption Configuration - Data Bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Note: Versioning is disabled by default (no versioning configuration resources needed)

# S3 Bucket Public Access Block - Metastore Bucket
resource "aws_s3_bucket_public_access_block" "metastore" {
  count = var.create_metastore_bucket ? 1 : 0
  
  bucket = aws_s3_bucket.metastore[0].id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Public Access Block - Data Bucket
resource "aws_s3_bucket_public_access_block" "data" {
  bucket = aws_s3_bucket.data.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


