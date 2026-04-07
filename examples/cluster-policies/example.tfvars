workspace_host = "https://WORKSPACEURL"
cluster_policies = {
  "teamA" = {
    team = "teamA"
    environment = "dev"
    policy_version = "1.0.0"
    policy_key = "sdp-cluster"
    policy_family_id = "job-cluster"
    group_assignments = ["groupA"]
    user_assignments = ["userA@corporateemail.com"]
  },
  "teamB" = {
    team = "teamB"
    environment = "prod"
    policy_version = "1.0.0"
    policy_key = "power-user"
    policy_family_id = "power-user"
    group_assignments = ["groupB"]   
    policy_overrides = "{\"autotermination_minutes\":{\"type\":\"fixed\",\"value\":60,\"hidden\": true}}"
  }
}