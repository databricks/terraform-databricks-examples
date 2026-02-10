module "cluster-policies" {
  for_each = var.cluster_policies
  source = "../../modules/cluster-policy-from-policy-family"

  team = each.value.team
  environment = each.value.environment
  policy_version = each.value.policy_version
  policy_family_id = each.value.policy_family_id
  policy_key = each.value.policy_key
  policy_overrides = each.value.policy_overrides
  group_assignments = each.value.group_assignments
  service_principal_assignments = each.value.service_principal_assignments
}