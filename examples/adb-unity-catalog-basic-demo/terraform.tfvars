account_id             = "e25e5e4e-696a-4944-bdca-836f36d40a1d"
databricks_resource_id = "/subscriptions/42f7bbe6-d5c5-45a0-a9ec-8d8dff2e8f5d/resourceGroups/himanshu_rg/providers/Microsoft.Databricks/workspaces/myws"
user_groups = {
  "account admin" = {
    users              = ["user1@himanshuaroraalwgmail.onmicrosoft.com", "himanshu.arora.alw_gmail.com#EXT#@himanshuaroraalwgmail.onmicrosoft.com"],
    service_principals = [],
    role               = "account_admin"
  }
  "unity admin" = {
    users              = ["himanshu.arora.alw_gmail.com#EXT#@himanshuaroraalwgmail.onmicrosoft.com"],
    service_principals = [],
    role               = "unity_admin"
  }
  "data enginner" = {
    users              = ["user2@himanshuaroraalwgmail.onmicrosoft.com"],
    service_principals = ["9fac496d-0d09-4299-8050-da2890e0eb3f"],
    role               = ""
  }
  "data analyst" = {
    users              = ["user3@himanshuaroraalwgmail.onmicrosoft.com", "user4@himanshuaroraalwgmail.onmicrosoft.com"],
    service_principals = ["dc7d010b-fd22-479c-803d-13442ca77774"],
    role               = ""
  }
  "data scientist" = {
    users              = ["user5@himanshuaroraalwgmail.onmicrosoft.com"],
    service_principals = [],
    role               = ""
  }
}
