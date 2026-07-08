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
<!-- END_TF_DOCS -->
