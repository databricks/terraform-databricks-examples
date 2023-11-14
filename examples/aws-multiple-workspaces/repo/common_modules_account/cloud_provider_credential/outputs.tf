output "cloud_provider_credential" {
  value = aws_iam_role.cross_account_role.arn
}