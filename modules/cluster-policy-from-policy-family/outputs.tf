output "policy_id" {
  description = "Databricks compute_policy_id"
  value = databricks_cluster_policy.compute_policy.policy_id
}