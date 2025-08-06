output "data_bucket_name" {
  value = aws_s3_bucket.data_bucket.bucket
}

output "role_for_s3_access_id" {
  value = aws_iam_role.role_for_s3_access.id
}

output "role_for_s3_access_name" {
  value = aws_iam_role.role_for_s3_access.name
}

output "instance_profile_arn" {
  value = aws_iam_instance_profile.instance_profile.arn
}