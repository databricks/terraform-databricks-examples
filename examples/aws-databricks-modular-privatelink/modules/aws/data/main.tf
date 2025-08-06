resource "aws_s3_bucket" "data_bucket" {
  bucket        = var.data_bucket_name
  acl           = "private"
  force_destroy = true
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "${var.resource_prefix}-s3-access-policy"
  description = "Policy for S3 data bucket access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "grantS3Access"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::${var.data_bucket_name}/*",
          "arn:aws:s3:::${var.data_bucket_name}"
        ]
      }
    ]
  })
}

data "aws_iam_policy_document" "assume_role_for_ec2" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "pass_role_for_s3_access" {
  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.role_for_s3_access.arn]
  }
}

resource "aws_iam_role" "role_for_s3_access" {
  name               = "${var.resource_prefix}-ec2-role-for-s3"
  description        = "IAM role for EC2 to access S3"
  assume_role_policy = data.aws_iam_policy_document.assume_role_for_ec2.json
  tags               = var.tags
}

resource "aws_iam_policy" "pass_role_for_s3_access" {
  name   = "${var.resource_prefix}-pass-role-for-s3-access"
  path   = "/"
  policy = data.aws_iam_policy_document.pass_role_for_s3_access.json
}

resource "aws_iam_role_policy_attachment" "cross_account" {
  policy_arn = aws_iam_policy.pass_role_for_s3_access.arn
  role       = aws_iam_role.role_for_s3_access.name
}

resource "aws_iam_role_policy_attachment" "s3_policy_attach" {
  policy_arn = aws_iam_policy.s3_access_policy.arn
  role       = aws_iam_role.role_for_s3_access.name
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.resource_prefix}-instance-profile"
  role = aws_iam_role.role_for_s3_access.name
}