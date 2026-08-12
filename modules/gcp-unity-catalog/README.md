# GCP Unity Catalog

This module provisions Unity Catalog for a Databricks workspace on Google Cloud and the GCS storage that backs it. It creates:

* `google_storage_bucket` — a GCS bucket used as the storage root for Unity Catalog data.
* `databricks_metastore` and `databricks_metastore_assignment` — a regional metastore, assigned to the target workspace.
* `databricks_storage_credential` — a storage credential backed by a Databricks-managed GCP service account.
* `google_storage_bucket_iam_member` — grants the storage credential's service account read/admin access on the bucket.
* `databricks_external_location` — an external location pointing at the bucket, using the storage credential.
* `databricks_catalog` — a catalog whose storage root is the external location.

The module expects an existing Databricks workspace on GCP and uses two `databricks` provider configurations (account-level and workspace-level via the `databricks.workspace` alias).

## How to use

1. Reference this module using one of the different [module source types](https://developer.hashicorp.com/terraform/language/modules/sources).
2. Configure two `databricks` providers: the default (account-level) and a `databricks.workspace` alias pointing at the target workspace, plus the `google` provider.
3. Provide values for the required variables (`databricks_workspace_url`, `databricks_workspace_id`, `google_region`, `google_project`, `prefix`, `metastore_name`, `catalog_name`).
4. Run `terraform init`.
5. Run `terraform apply`.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | n/a |
| <a name="provider_databricks.workspace"></a> [databricks.workspace](#provider\_databricks.workspace) | n/a |
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

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
