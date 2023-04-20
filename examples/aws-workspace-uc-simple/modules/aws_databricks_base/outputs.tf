output "security_group_ids" {
  value       = [module.vpc.default_security_group_id]
  description = "Security group ID for DB Compliant VPC"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "subnets" {
  value       = module.vpc.private_subnets
  description = "private subnets for workspace creation"
}

output "vpc_main_route_table_id" {
  value       = module.vpc.vpc_main_route_table_id
  description = "ID for the main route table associated with this VPC"
}

output "private_route_table_ids" {
  value       = module.vpc.private_route_table_ids
  description = "IDs for the private route tables associated with this VPC"
}

output "root_bucket" {
  value       = aws_s3_bucket.root_storage_bucket.bucket
  description = "root bucket"
}

output "cross_account_role_arn" {
  value       = aws_iam_role.cross_account_role.arn
  description = "AWS Cross account role arn"
}
