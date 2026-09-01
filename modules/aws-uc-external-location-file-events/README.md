# aws-uc-external-location-file-events

Creates AWS Unity Catalog **storage credentials** and **external locations** with
[managed file events](https://docs.databricks.com/aws/en/connect/unity-catalog/cloud-storage/manage-external-locations)
enabled via Amazon SNS + SQS (managed SQS). The module builds the
**self-assuming IAM role** and the IAM policy that Unity Catalog requires, including the
extra `sns:*` / `sqs:*` / S3 bucket-notification permissions needed for automatic file-event
setup.

This is useful for [file arrival triggers](https://docs.databricks.com/aws/en/jobs/file-arrival-triggers)
and other ingestion patterns (for example [Auto Loader](https://docs.databricks.com/aws/en/ingestion/cloud-object-storage/auto-loader/file-events-explained))
that benefit from cloud storage change notifications.

This is the AWS counterpart to
[`adb-uc-external-location-file-events`](../adb-uc-external-location-file-events) (Azure).

## Prerequisites

- Unity Catalog–enabled Databricks workspace whose assigned metastore is the target metastore
  (the Databricks provider should authenticate to that workspace), **or** an account-level
  provider with `metastore_id` set.
- One or more existing S3 buckets that back the external locations. This module does **not**
  create the buckets — the caller owns them (see the example).
- Permission to create IAM roles/policies in the AWS account that owns the bucket(s).
- Permission to create UC storage credentials and external locations (metastore admin or the
  `CREATE STORAGE CREDENTIAL` / `CREATE EXTERNAL LOCATION` privileges).

## What it creates

| Resource | Purpose |
| -------- | ------- |
| `aws_iam_policy` | S3 data access on the target bucket(s), `sts:AssumeRole` self-permission, and (when `enable_file_events`) the `csms-*`-scoped SNS/SQS/bucket-notification permissions |
| `aws_iam_role` | Self-assuming role trusted by the UC master role (gated by the Databricks account ID as external ID) |
| `time_sleep` | Waits for IAM propagation before UC validates the credential (avoids transient "non self-assuming" / 403 errors) |
| `databricks_storage_credential` | UC storage credential backed by the IAM role |
| `databricks_external_location` | One per entry in `external_locations`, with automatic managed SQS file events |
| `databricks_grants` | Optional UC grants on the credential and locations |

## Managed file events (automatic mode)

When `enable_file_events = true` (default), the IAM policy includes the documented
`ManagedFileEventsSetupStatement` / `ManagedFileEventsListStatement` /
`ManagedFileEventsTeardownStatement` statements, scoped to the target bucket(s) and the
`csms-*` SNS/SQS namespace. Unity Catalog then provisions one SNS topic and one SQS queue
(prefixed `csms-*`) per external location and configures the S3 bucket notification. Without
these permissions, file events silently fail to provision even though the location reports it
as enabled.

## Example

```hcl
# The caller owns the bucket.
resource "aws_s3_bucket" "demo" {
  bucket        = "my-uc-demo-bucket"
  force_destroy = true
}

module "uc_locations" {
  source = "../../modules/aws-uc-external-location-file-events"

  name_prefix           = "demo"
  databricks_account_id = "00000000-0000-0000-0000-000000000000"
  bucket_names          = [aws_s3_bucket.demo.id]

  external_locations = [
    {
      name    = "demo_landing"
      url     = "s3://${aws_s3_bucket.demo.id}/landing"
      comment = "Landing zone with managed SQS file events"
    }
  ]

  location_grants = [
    {
      principal  = "data-engineers"
      privileges = ["BROWSE", "READ_FILES", "WRITE_FILES", "CREATE_EXTERNAL_TABLE", "CREATE_EXTERNAL_VOLUME"]
    }
  ]
}
```

See also [examples/aws-uc-external-location-file-events](../../examples/aws-uc-external-location-file-events).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >= 1.81.1 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | >= 1.81.1 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.9.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [databricks_external_location.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/external_location) | resource |
| [databricks_grants.credential](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants) | resource |
| [databricks_grants.location](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants) | resource |
| [databricks_storage_credential.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/storage_credential) | resource |
| [time_sleep.wait_iam](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_bucket_names"></a> [bucket\_names](#input\_bucket\_names) | Names of the S3 buckets that the storage credential IAM role is granted access to (and, when file events are enabled, allowed to configure notifications on). The buckets must already exist; this module does not create them. | `list(string)` | n/a | yes |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | Databricks account ID. Used as the sts:ExternalId in the IAM role trust policy (the Unity Catalog storage credential external ID). | `string` | n/a | yes |
| <a name="input_external_locations"></a> [external\_locations](#input\_external\_locations) | External locations to create. Each location has managed SQS file events enabled when enable\_file\_events is true. | <pre>list(object({<br/>    name      = string<br/>    url       = string<br/>    comment   = optional(string, "Managed by Terraform")<br/>    read_only = optional(bool, false)<br/>  }))</pre> | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used to derive default names for the IAM role, IAM policy, and storage credential. | `string` | n/a | yes |
| <a name="input_create_storage_credential"></a> [create\_storage\_credential](#input\_create\_storage\_credential) | When true, create a storage credential backed by the IAM role this module manages. When false, reuse existing\_credential\_name (the IAM role/policy are still managed). | `bool` | `true` | no |
| <a name="input_credential_grants"></a> [credential\_grants](#input\_credential\_grants) | UC grants applied to the storage credential. Defaults to empty (owner-only). | <pre>list(object({<br/>    principal  = string<br/>    privileges = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_enable_file_events"></a> [enable\_file\_events](#input\_enable\_file\_events) | Enable automatic managed file events (SNS topic + SQS queue + S3 bucket notification, csms-* prefixed) on every external location. Adds the required sns/sqs/bucket-notification permissions to the IAM policy. | `bool` | `true` | no |
| <a name="input_existing_credential_name"></a> [existing\_credential\_name](#input\_existing\_credential\_name) | Name of an existing storage credential to reference on the external locations when create\_storage\_credential is false. | `string` | `""` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Force destroy the storage credential and external locations even if dependents exist. | `bool` | `false` | no |
| <a name="input_iam_policy_name"></a> [iam\_policy\_name](#input\_iam\_policy\_name) | Name of the IAM policy attached to the role. Defaults to "<iam\_role\_name>-policy". | `string` | `""` | no |
| <a name="input_iam_propagation_delay"></a> [iam\_propagation\_delay](#input\_iam\_propagation\_delay) | Delay to wait after creating the IAM role/policy before creating the storage credential and external locations, so IAM changes propagate (avoids "non self-assuming" / 403 validation errors). Set to "" to disable the wait (e.g. when the role already exists). | `string` | `"60s"` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name of the IAM role used by the storage credential. Defaults to "<name\_prefix>-uc". | `string` | `""` | no |
| <a name="input_location_grants"></a> [location\_grants](#input\_location\_grants) | UC grants applied to every external location.<br/>Recommended privileges for data engineers: BROWSE, READ\_FILES, WRITE\_FILES,<br/>CREATE\_EXTERNAL\_TABLE, CREATE\_EXTERNAL\_VOLUME. | <pre>list(object({<br/>    principal  = string<br/>    privileges = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_storage_credential_comment"></a> [storage\_credential\_comment](#input\_storage\_credential\_comment) | Comment applied to the created storage credential. | `string` | `"Storage credential for external locations with file events. Managed by Terraform."` | no |
| <a name="input_storage_credential_name"></a> [storage\_credential\_name](#input\_storage\_credential\_name) | Name for the created storage credential. Defaults to "<name\_prefix>-storage-credential". | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the IAM role and policy. | `map(string)` | `{}` | no |
| <a name="input_uc_master_role_arn"></a> [uc\_master\_role\_arn](#input\_uc\_master\_role\_arn) | ARN of the Unity Catalog AWS master role that assumes the storage credential role. Defaults to the Databricks commercial (non-GovCloud) UC master role. | `string` | `"arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-14S5ZJVKOTYTL"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_external_location_ids"></a> [external\_location\_ids](#output\_external\_location\_ids) | Map of external location name to ID |
| <a name="output_external_location_names"></a> [external\_location\_names](#output\_external\_location\_names) | Names of the created external locations |
| <a name="output_external_location_urls"></a> [external\_location\_urls](#output\_external\_location\_urls) | Map of external location name to URL |
| <a name="output_file_events_enabled"></a> [file\_events\_enabled](#output\_file\_events\_enabled) | Whether managed file events are enabled on the external locations |
| <a name="output_iam_policy_arn"></a> [iam\_policy\_arn](#output\_iam\_policy\_arn) | ARN of the IAM policy attached to the role |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | ARN of the IAM role trusted by the Unity Catalog storage credential |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | Name of the IAM role backing the storage credential |
| <a name="output_storage_credential_id"></a> [storage\_credential\_id](#output\_storage\_credential\_id) | ID of the created storage credential (null when reusing an existing credential) |
| <a name="output_storage_credential_name"></a> [storage\_credential\_name](#output\_storage\_credential\_name) | Name of the storage credential used by the external locations |
<!-- END_TF_DOCS -->
