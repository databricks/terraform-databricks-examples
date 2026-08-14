resource "aws_s3_bucket" "file_events" {
  count         = var.create_bucket ? 1 : 0
  bucket        = local.bucket_name
  force_destroy = var.force_destroy_bucket
  tags = merge(var.tags, {
    Name = local.bucket_name
  })
}

resource "aws_s3_bucket_versioning" "file_events" {
  count  = var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.file_events[0].id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "file_events" {
  count  = var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.file_events[0].bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "file_events" {
  count                   = var.create_bucket ? 1 : 0
  bucket                  = aws_s3_bucket.file_events[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.file_events]
}

data "aws_s3_bucket" "existing" {
  count  = var.create_bucket ? 0 : 1
  bucket = var.existing_bucket_name
}
