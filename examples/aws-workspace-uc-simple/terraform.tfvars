aws_profile                 = "YOUR_AWS_PROFILE"                             // For AWS cli authentication
region                      = "AWS_CLOUD_REGION"                             // AWS region where you want to deploy your resources
cidr_block                  = "10.4.0.0/16"                                  // CIDR block for the workspace VPC, will be divided in two equal sized subnets
my_username                 = "user.one@domain.com"                          // Username for tagging the resources
databricks_users            = ["user.one@domain.com", "user.two@domain.com"] // List of users that will be admins at the workspace level
databricks_metastore_admins = ["user.two@domain.com"]                        // List of users that will be admins for Unity Catalog
unity_admin_group           = "unity-admin-group"                            // Metastore Owner and Admin
databricks_account_id       = "YOUR_DATABRICKS_ACCOUNT_ID"                   // Databricks Account ID
databricks_client_id        = "SERVICE_PRINCIPAL_CLIENT_ID"                  // Databricks Service Principal Client ID
databricks_client_secret    = "SERVICE_PRINCIPAL_CLIENT_SECRET"              // Databricks Service Principal Client Secret
tags = {
  Environment = "Demo-with-terraform"
}
