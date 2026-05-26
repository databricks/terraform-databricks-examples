# modules/gcp/unity-catalog

Unity Catalog metastore, GCS bucket, storage credential, external location, and catalog for GCP Databricks workspaces. Called by examples after the workspace exists (uses workspace-scoped Databricks provider alias).

## Usage

Called after `modules/gcp/databricks-workspace` to create a metastore, GCS bucket, storage credential, external location, and default catalog.

```hcl
module "unity_catalog" {
  source = "github.com/databricks/terraform-databricks-examples//modules/gcp/unity-catalog"

  providers = {
    databricks           = databricks
    databricks.workspace = databricks.workspace
  }

  databricks_workspace_id  = module.workspace.workspace_id
  databricks_workspace_url = module.workspace.workspace_url
  google_project           = "my-workspace-project"
  google_region            = "us-central1"
  prefix                   = "acme"
  metastore_name           = "main-metastore"
  catalog_name             = "main"
}
```

The consumer must declare a `databricks.workspace` provider alias pointing at the workspace URL.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | 1.115.0 |
| <a name="provider_databricks.workspace"></a> [databricks.workspace](#provider\_databricks.workspace) | 1.115.0 |
| <a name="provider_google"></a> [google](#provider\_google) | 7.32.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [databricks_catalog.main](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/catalog) | resource |
| [databricks_external_location.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/external_location) | resource |
| [databricks_metastore.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/metastore) | resource |
| [databricks_metastore_assignment.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/metastore_assignment) | resource |
| [databricks_storage_credential.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/storage_credential) | resource |
| [google_storage_bucket.ext_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.unity_cred_admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket_iam_member.unity_cred_reader](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_catalog_name"></a> [catalog\_name](#input\_catalog\_name) | Name to assign to default catalog | `string` | n/a | yes |
| <a name="input_databricks_workspace_id"></a> [databricks\_workspace\_id](#input\_databricks\_workspace\_id) | The unique identifier of the Databricks workspace in which resources will be managed. | `any` | n/a | yes |
| <a name="input_databricks_workspace_url"></a> [databricks\_workspace\_url](#input\_databricks\_workspace\_url) | The URL of the Databricks workspace to which resources will be deployed (e.g., https://<region>.gcp.databricks.com). | `any` | n/a | yes |
| <a name="input_google_project"></a> [google\_project](#input\_google\_project) | The Google Cloud project ID where the Databricks workspace and associated resources will be created. | `string` | n/a | yes |
| <a name="input_google_region"></a> [google\_region](#input\_google\_region) | Google Cloud region where the resources will be created | `string` | n/a | yes |
| <a name="input_metastore_name"></a> [metastore\_name](#input\_metastore\_name) | Name to assign to regional metastore | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to use in generated resources name | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
