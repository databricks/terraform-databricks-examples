data "aws_availability_zones" "available" {}

data "aws_vpc_endpoint" "firewall" {
  vpc_id = aws_vpc.hub_vpc.id

  tags = {
    "AWSNetworkFirewallManaged" = "true"
    "Firewall"                  = aws_networkfirewall_firewall.exfiltration_firewall.arn
  }

  depends_on = [aws_networkfirewall_firewall.exfiltration_firewall]
}

data "databricks_aws_assume_role_policy" "this" {
  external_id = var.databricks_account_id
}

data "databricks_aws_crossaccount_policy" "this" {
}

data "databricks_aws_bucket_policy" "this" {
  bucket = aws_s3_bucket.root_storage_bucket.bucket
}