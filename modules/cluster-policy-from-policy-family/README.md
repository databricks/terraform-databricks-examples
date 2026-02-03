# cluster-policy-from-policy-family

This module creates specific Databricks Cluster Policy using a Policy Family.  [Policy families](https://docs.databricks.com/aws/en/admin/clusters/policy-families#use-policy-families-to-create-custom-policies) are a great starting point for custom cluster policies as they include many pre-configured settings, but also allow overrides.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [databricks_cluster_policy.compute_policy](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/cluster_policy) | resource |
| [databricks_permissions.policy_usage](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/permissions) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | development environment policy belongs to | `string` | n/a | yes |
| <a name="input_policy_family_id"></a> [policy\_family\_id](#input\_policy\_family\_id) | Id of policy family | `any` | n/a | yes |
| <a name="input_policy_key"></a> [policy\_key](#input\_policy\_key) | Used to lookup default JSON configuration | `string` | n/a | yes |
| <a name="input_policy_version"></a> [policy\_version](#input\_policy\_version) | Cluster policy version (e.g. 0.0.1) | `string` | n/a | yes |
| <a name="input_team"></a> [team](#input\_team) | line of business that owns the workloads | `string` | n/a | yes |
| <a name="input_group_assignments"></a> [group\_assignments](#input\_group\_assignments) | Groups to assign to use cluster policy | `list(string)` | `[]` | no |
| <a name="input_policy_overrides"></a> [policy\_overrides](#input\_policy\_overrides) | Cluster policy overrides | `map` | `{}` | no |
| <a name="input_service_principal_assignments"></a> [service\_principal\_assignments](#input\_service\_principal\_assignments) | Service Principles to assign to cluster policy | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_policy_id"></a> [policy\_id](#output\_policy\_id) | Databricks compute\_policy\_id |
<!-- END_TF_DOCS -->
