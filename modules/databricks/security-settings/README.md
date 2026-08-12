# modules/databricks/security-settings

Cloud-neutral workspace security settings: Compliance Security Profile,
Enhanced Security Monitoring, automatic cluster update, and IP access lists.
Takes a workspace-level databricks provider from the caller.

> WARNING: the Compliance Security Profile cannot be disabled once enabled.

## Usage

```hcl
module "security_settings" {
  source = "github.com/databricks/terraform-databricks-examples//modules/databricks/security-settings"

  providers = {
    databricks = databricks.workspace
  }

  enable_enhanced_security_monitoring = true
  enable_compliance_security_profile  = true
  compliance_standards                = ["HIPAA"]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >= 1.81.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | 1.120.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [databricks_automatic_cluster_update_workspace_setting.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/automatic_cluster_update_workspace_setting) | resource |
| [databricks_compliance_security_profile_workspace_setting.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/compliance_security_profile_workspace_setting) | resource |
| [databricks_enhanced_security_monitoring_workspace_setting.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/enhanced_security_monitoring_workspace_setting) | resource |
| [databricks_ip_access_list.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/ip_access_list) | resource |
| [databricks_workspace_conf.enable_ip_access_lists](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/workspace_conf) | resource |
| [terraform_data.preconditions](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compliance_standards"></a> [compliance\_standards](#input\_compliance\_standards) | Compliance standards for the CSP (e.g. ["HIPAA"]). Only meaningful when enable\_compliance\_security\_profile=true | `list(string)` | `[]` | no |
| <a name="input_enable_automatic_cluster_update"></a> [enable\_automatic\_cluster\_update](#input\_enable\_automatic\_cluster\_update) | Enable automatic cluster update for the workspace | `bool` | `false` | no |
| <a name="input_enable_compliance_security_profile"></a> [enable\_compliance\_security\_profile](#input\_enable\_compliance\_security\_profile) | Enable the Compliance Security Profile on the workspace. WARNING: irreversible - CSP cannot be disabled once enabled. Requires enable\_enhanced\_security\_monitoring=true | `bool` | `false` | no |
| <a name="input_enable_enhanced_security_monitoring"></a> [enable\_enhanced\_security\_monitoring](#input\_enable\_enhanced\_security\_monitoring) | Enable Enhanced Security Monitoring (hardened images, monitoring agents) | `bool` | `false` | no |
| <a name="input_ip_access_lists"></a> [ip\_access\_lists](#input\_ip\_access\_lists) | Workspace IP access lists. list\_type is ALLOW or BLOCK. A non-empty list also flips the enableIpAccessLists workspace conf | <pre>list(object({<br/>    label        = string<br/>    list_type    = string<br/>    ip_addresses = list(string)<br/>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
