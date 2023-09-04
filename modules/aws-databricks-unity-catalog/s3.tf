resource "aws_s3_bucket" "metastore" {
  bucket        = "${var.prefix}-metastore"
  force_destroy = true
  tags = merge(var.tags, {
    Name = "${var.prefix}-metastore"
  })
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.metastore.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "root_storage_bucket" {
  bucket = aws_s3_bucket.metastore.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "metastore" {
  bucket                  = aws_s3_bucket.metastore.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.metastore]
}
