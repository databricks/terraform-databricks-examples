// create a data s3 bucket for demo purposes
resource "aws_s3_bucket" "data_bucket" {
  bucket        = "data-bucket-for-test" // hard-coded value for demo only
  acl           = "private"
  force_destroy = true
}

resource "aws_iam_policy" "added_policy" {
  name        = "grant-specific-s3-policy"
  description = "A test policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "grantS3Access",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": [
                "arn:aws:s3:::data-bucket-for-test/*",
                "arn:aws:s3:::data-bucket-for-test"
            ]
        }
    ]
}
EOF
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
  name               = "${local.prefix}-ec2-role-for-s3"
  description        = "iam role for ec2 to access s3"
  assume_role_policy = data.aws_iam_policy_document.assume_role_for_ec2.json
  tags               = var.tags
}

resource "aws_iam_policy" "pass_role_for_s3_access" {
  name   = "${local.prefix}-pass-role-for-s3-access"
  path   = "/"
  policy = data.aws_iam_policy_document.pass_role_for_s3_access.json
}

resource "aws_iam_role_policy_attachment" "cross_account" {
  policy_arn = aws_iam_policy.pass_role_for_s3_access.arn
  role       = aws_iam_role.role_for_s3_access.name
}

// add grant s3 access policy to role
resource "aws_iam_role_policy_attachment" "s3-policy-attach" {
  policy_arn = aws_iam_policy.added_policy.arn
  role       = aws_iam_role.role_for_s3_access.name
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${local.prefix}-instance-profile"
  role = aws_iam_role.role_for_s3_access.name
}

/*
resource "databricks_instance_profile" "instance_profile" {
  instance_profile_arn = aws_iam_instance_profile.instance_profile.arn
  skip_validation      = true
}
*/
