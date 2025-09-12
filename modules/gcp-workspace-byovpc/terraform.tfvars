# GCP Project Configuration
# custom_role_url = "https://console.cloud.google.com/iam-admin/roles/details/projects%3C%3Croles%3Cdatabricks_workspace_creator"
# service_account = "databricks-sa2@enhanced-kit-420908.iam.gserviceaccount.com"

databricks_account_id = "3d4f740f-880a-432b-8c03-2953b0ee5cf2"
google_project = "enhanced-kit-420908"
google_region = "us-central1"
prefix = "databricks-poc-vpc"
subnet_ip_cidr_range = "10.0.1.0/25"
subnet_name = "databricks-poc-subnet"
router_name = "databricks-poc-router"
nat_name = "databricks-poc-nat"
delegate_from = ["serviceAccount:databricks-sa2@enhanced-kit-420908.iam.gserviceaccount.com"]
