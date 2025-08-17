# databricks-department-clusters


This module creates specific Databricks objects for a given department:

* User group for a department with specific users added to it
* A shared Databricks cluster that could be used by users of the group
* A Databricks SQL Endpoint
* A Databricks cluster policy that could be used by the user group

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
| [databricks_cluster.team_cluster](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/cluster) | resource |
| [databricks_cluster_policy.fair_use](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/cluster_policy) | resource |
| [databricks_group.data_eng](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/group) | resource |
| [databricks_group_member.data_eng_member](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/group_member) | resource |
| [databricks_permissions.can_manage_sql_endpoint](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/permissions) | resource |
| [databricks_permissions.can_manage_team_cluster](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/permissions) | resource |
| [databricks_permissions.can_use_cluster_policy](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/permissions) | resource |
| [databricks_sql_endpoint.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/sql_endpoint) | resource |
| [databricks_user.de](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/user) | resource |
| [databricks_node_type.smallest](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/node_type) | data source |
| [databricks_spark_version.latest_lts](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/spark_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the shared cluster to create | `string` | n/a | yes |
| <a name="input_department"></a> [department](#input\_department) | Department name | `string` | n/a | yes |
| <a name="input_group_name"></a> [group\_name](#input\_group\_name) | Name of the group to create | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags applied to all resources created | `map(string)` | `{}` | no |
| <a name="input_user_names"></a> [user\_names](#input\_user\_names) | List of users to create in the specified group | `list(string)` | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
