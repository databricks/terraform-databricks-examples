aws_profile                 = "YOUR_AWS_PROFILE"          // For AWS cli authentication
region                      = "us-west-1"                 // AWS region where you want to deploy your resources
cidr_block                  = "10.4.0.0/16"               // CIDR block for the workspace VPC, will be divided in two equal sized subnets
my_username                 = "owner.user@domain.com"     // Username for tagging the resources
databricks_users            = ["second.user@domain.com"]  // List of users that will be admins at the workspace level
databricks_metastore_admins = ["first.admin@domain.com"]  // List of users that will be admins for Unity Catalog
unity_admin_group           = "unity-admin-group"         // Metastore Owner and Admin
tags = {
  Environment = "Demo-with-terraform"
}
