# Terraform Example for cluster-policy-from-policy-family module

This is an example of how one can use the [cluster-policy-from-policy-family](../../modules/cluster-policy-from-policy-family) module in this repository to effectively rollout baseline cluster policies for many different teams with team specific overrides.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cluster-policies"></a> [cluster-policies](#module\_cluster-policies) | ../../modules/cluster-policy-from-policy-family | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_workspace_host"></a> [workspace\_host](#input\_workspace\_host) | URL of the workspace to execute this module against | `string` | n/a | yes |
| <a name="input_cluster-policies"></a> [cluster-policies](#input\_cluster-policies) | Convenience variable that bundles all required variables for cluster-policy-from-policy-family module.  Each object in the map represents one policy to create. | <pre>map(object({<br/>    team = string<br/>    environment = string<br/>    policy_version = string<br/>    policy_key = string<br/>    policy_family_id = string<br/>    policy_overrides = optional(string, "{}")<br/>    group_assignments = list(string)<br/>    service_principal_assignments = list(string)<br/>  }))</pre> | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
