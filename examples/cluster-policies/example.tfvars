workspace_host = "https://WORKSPACEURL"
cluster-policies = {
  "teamA" = {
    team = "teamA"
    environment = "dev"
    policy_version = "1.0.0"
    policy_key = "personal-vm"
    policy_family_id = "personal-vm"
    group_assignments = ["groupA"]
    service_principal_assignments = []
  },
  "teamB" = {
    team = "teamB"
    environment = "prod"
    policy_version = "1.0.0"
    policy_key = "power-user"
    policy_family_id = "power-user"
    group_assignments = ["groupB"]
    service_principal_assignments = []
    policy_overrides = "{\"autotermination_minutes\":{\"type\":\"fixed\",\"value\":60,\"hidden\": true}}"
  }
}