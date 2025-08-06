# Databricks Configuration
databricks_account_client_id     = "your-databricks-client-id"
databricks_account_client_secret = "your-databricks-client-secret"
databricks_account_id            = "your-databricks-account-id"

# AWS Configuration
region = "ap-southeast-1"

# CMK Configuration
cmk_admin = "arn:aws:iam::026655378770:user/hao"

# Network Configuration
vpc_cidr                     = "10.109.0.0/17"
public_subnets_cidr          = ["10.109.2.0/23"]
privatelink_subnets_cidr     = ["10.109.4.0/23"]

# VPC Endpoint Services (ap-southeast-1 specific)
workspace_vpce_service = "com.amazonaws.vpce.ap-southeast-1.vpce-svc-02535b257fc253ff4"
relay_vpce_service     = "com.amazonaws.vpce.ap-southeast-1.vpce-svc-0557367c6fc1a0c5c"

# Tags
tags = {
  Environment = "development"
  Project     = "databricks-privatelink"
  Owner       = "data-team"
}

# Workspace 1 Configuration
workspace_1_config = {
  private_subnet_pair = {
    subnet1_cidr = "10.109.6.0/23"
    subnet2_cidr = "10.109.8.0/23"
  }
  workspace_name   = "test-workspace-1"
  prefix           = "ws1"
  region           = "ap-southeast-1"
  root_bucket_name = "test-workspace-1-rootbucket"
  block_list       = ["58.133.93.159"]
  allow_list       = ["65.184.145.97"]
  tags = {
    Name = "test-workspace-1-tags"
    Env  = "test-ws-1"
  }
}

# Workspace 2 Configuration
workspace_2_config = {
  private_subnet_pair = {
    subnet1_cidr = "10.109.10.0/23"
    subnet2_cidr = "10.109.12.0/23"
  }
  workspace_name   = "test-workspace-2"
  prefix           = "ws2"
  region           = "ap-southeast-1"
  root_bucket_name = "test-workspace-2-rootbucket"
  block_list       = ["54.112.179.135", "195.78.164.130"]
  allow_list       = ["65.184.145.97"]
  tags = {
    Name = "test-workspace-2-tags"
  }
}