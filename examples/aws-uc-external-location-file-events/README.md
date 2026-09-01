# Example: aws-uc-external-location-file-events

Creates an S3 bucket and uses the
[`aws-uc-external-location-file-events`](../../modules/aws-uc-external-location-file-events)
module to create a Unity Catalog storage credential (backed by a self-assuming IAM role) and an
external location with **automatic managed file events** (SNS + SQS, `csms-*` prefixed).

## Prerequisites

- A Unity Catalog–enabled Databricks workspace whose assigned metastore is the target metastore.
- AWS credentials for the account where the bucket/IAM role live (profile or env vars).
- Databricks auth for that workspace (CLI profile or `DATABRICKS_*` env vars).
- Permission to create IAM roles/policies and UC storage credentials + external locations.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars

terraform init
terraform plan
terraform apply
```

After apply, verify file events with the Unity Catalog storage-credential validation API:

```bash
databricks api post /api/2.1/unity-catalog/validate-storage-credentials \
  --json '{"storage_credential_name":"<name>","external_location_name":"<name>"}'
```

`READ_MESSAGE` transitions from `SKIP` ("being provisioned") to `PASS` once Databricks
provisions the managed SNS topic + SQS queue and the S3 bucket notification.

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

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_uc_external_location_file_events"></a> [uc\_external\_location\_file\_events](#module\_uc\_external\_location\_file\_events) | ../../modules/aws-uc-external-location-file-events | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Globally unique S3 bucket name to create for the external location | `string` | n/a | yes |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | Databricks account ID (used as the sts:ExternalId in the IAM role trust policy). | `string` | n/a | yes |
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | AWS CLI profile for the account that owns the bucket. Leave empty to use the default credential chain / env vars. | `string` | `""` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region for the S3 bucket | `string` | `"us-east-1"` | no |
| <a name="input_databricks_profile"></a> [databricks\_profile](#input\_databricks\_profile) | Databricks CLI profile for a workspace assigned to the target metastore. Leave empty to use DATABRICKS\_* env vars. | `string` | `""` | no |
| <a name="input_external_location_name"></a> [external\_location\_name](#input\_external\_location\_name) | Name of the Unity Catalog external location | `string` | `"file_events_landing"` | no |
| <a name="input_external_location_prefix"></a> [external\_location\_prefix](#input\_external\_location\_prefix) | Prefix within the bucket managed by the external location | `string` | `"landing"` | no |
| <a name="input_grant_principal"></a> [grant\_principal](#input\_grant\_principal) | UC group or user to grant on the credential and external location. Leave empty to skip grants. | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for UC object and IAM names | `string` | `"file-events-demo"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | n/a |
| <a name="output_external_location_ids"></a> [external\_location\_ids](#output\_external\_location\_ids) | n/a |
| <a name="output_external_location_urls"></a> [external\_location\_urls](#output\_external\_location\_urls) | n/a |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | n/a |
| <a name="output_storage_credential_name"></a> [storage\_credential\_name](#output\_storage\_credential\_name) | n/a |
<!-- END_TF_DOCS -->
