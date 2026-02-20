# cluster-policy-from-policy-family

This module creates specific Databricks Cluster Policy using a Policy Family.  [Policy families](https://docs.databricks.com/aws/en/admin/clusters/policy-families#use-policy-families-to-create-custom-policies) are a great starting point for custom cluster policies as they include many pre-configured settings, but also allow overrides.

### Policy JSON
Each policy that is created from a policy family contains default JSON configurations prescribed by Databricks to match that persona.  In addition, this module provides two additional ways to override or augment those defaults.

The first override provided is an override that applies to all policies created by this module.  Effectively, this enables this module to ensure certain standards are met across all policies in a customer environment.  Those configurations are contained within the `cluster_policy_json` folder and they are selected for use by a combination of the `policy_key` and `environment` variables.  For example, `job-cluster` and `dev` will match to the following default configuration.  This policy will use the JSON configurations for `dev_runtimes`, `job_cluster_types`, etc.  These configurations supercede the Databricks defaults for the policy family.

```
"job-cluster-dev" = merge(local.job_cluster_types, local.required_tags, local.dev_runtimes)
```

The second override provided is a policy specific override.  Effectively, an individual policy provisioned using this module can have a bespoke setting using the `policy_overrides`.  For example, should a policy require a different autotermination setting, this field can be leveraged to do that.  See below for code example.

```
policy_overrides = { "autotermination_minutes" : { "hidden" : true, "type" : "fixed", "value" : 90 } }
```

For more details on which JSON configurations are available, please review the following [documentation](https://learn.microsoft.com/en-us/azure/databricks/admin/clusters/policy-definition).

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
| <a name="input_policy_family_id"></a> [policy\_family\_id](#input\_policy\_family\_id) | Id of policy family | `string` | n/a | yes |
| <a name="input_policy_key"></a> [policy\_key](#input\_policy\_key) | Used to lookup default JSON configuration.  Similar to policy\_family\_id, but allows for additional configurations not supported by policy families, such as Spark Declarative Pipelines (sdp) | `string` | n/a | yes |
| <a name="input_policy_version"></a> [policy\_version](#input\_policy\_version) | Cluster policy version (e.g. 0.0.1) | `string` | n/a | yes |
| <a name="input_team"></a> [team](#input\_team) | line of business that owns the workloads | `string` | n/a | yes |
| <a name="input_group_assignments"></a> [group\_assignments](#input\_group\_assignments) | Groups to assign to use cluster policy | `list(string)` | `[]` | no |
| <a name="input_policy_overrides"></a> [policy\_overrides](#input\_policy\_overrides) | Cluster policy overrides | `string` | `"{}"` | no |
| <a name="input_service_principal_assignments"></a> [service\_principal\_assignments](#input\_service\_principal\_assignments) | Service Principals to assign to cluster policy | `list(string)` | `[]` | no |
| <a name="input_user_assignments"></a> [user\_assignments](#input\_user\_assignments) | Users to assign to use cluster policy | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_policy_id"></a> [policy\_id](#output\_policy\_id) | Databricks compute\_policy\_id |
<!-- END_TF_DOCS -->
