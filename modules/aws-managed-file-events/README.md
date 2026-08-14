# Module aws-managed-file-events

## Description

This module creates the infrastructure needed for Databricks Managed File Events on AWS. Managed file events enables file notification mode for Auto Loader, allowing Databricks to automatically set up S3 event notifications and SQS queues for efficient file discovery.

When enabled, Auto Loader can use `cloudFiles.useManagedFileEvents = true` for efficient incremental data ingestion without manually configuring S3 notifications.

## Features

- Creates (or uses existing) S3 bucket for file storage
- Creates IAM role with permissions for S3 access, bucket notifications, and SQS management
- Creates Unity Catalog storage credential
- Creates external location with file events enabled and managed SQS
- Optionally creates a catalog using the external location
- Supports configurable grants for storage credential, external location, and catalog

## Prerequisites

- Unity Catalog enabled workspace with metastore assigned
- Databricks Runtime 14.3 LTS or above (for Auto Loader with managed file events)
- AWS account with permissions to create IAM roles and S3 buckets

## Usage

### Basic Usage (Create new bucket)

```hcl
module "managed_file_events" {
  source = "github.com/databricks/terraform-databricks-examples/modules/aws-managed-file-events"

  prefix                = "my-project"
  region                = "us-west-2"
  aws_account_id        = "123456789012"
  databricks_account_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

  tags = {
    Environment = "production"
  }
}
```

### Using Existing Bucket

```hcl
module "managed_file_events" {
  source = "github.com/databricks/terraform-databricks-examples/modules/aws-managed-file-events"

  prefix                = "my-project"
  region                = "us-west-2"
  aws_account_id        = "123456789012"
  databricks_account_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

  create_bucket        = false
  existing_bucket_name = "my-existing-bucket"
  s3_path_prefix       = "data/incoming"

  tags = {
    Environment = "production"
  }
}
```

### With Catalog Creation

```hcl
module "managed_file_events" {
  source = "github.com/databricks/terraform-databricks-examples/modules/aws-managed-file-events"

  prefix                = "my-project"
  region                = "us-west-2"
  aws_account_id        = "123456789012"
  databricks_account_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

  create_catalog = true
  catalog_name   = "file_events_catalog"
  catalog_owner  = "data_engineers"

  catalog_grants = [
    {
      principal  = "data_engineers"
      privileges = ["USE_CATALOG", "CREATE_SCHEMA"]
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

## Using with Auto Loader

Once the module is deployed, you can use Auto Loader with managed file events:

```python
df = spark.readStream.format("cloudFiles") \
  .option("cloudFiles.format", "json") \
  .option("cloudFiles.useManagedFileEvents", "true") \
  .load("s3://bucket/path")
```

Or in Lakeflow Declarative Pipelines:

```python
@dlt.table
def my_table():
    return spark.readStream.format("cloudFiles") \
        .option("cloudFiles.format", "json") \
        .option("cloudFiles.useManagedFileEvents", "true") \
        .load("s3://bucket/path")
```

## Reference

- [Databricks File Notification Mode Documentation](https://docs.databricks.com/aws/en/ingestion/cloud-object-storage/auto-loader/file-notification-mode)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >= 1.65.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >=0.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.31.0 |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | 1.105.0 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.13.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.unity_catalog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.file_events_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.unity_catalog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket.file_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.file_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.file_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.file_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [databricks_catalog.file_events](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/catalog) | resource |
| [databricks_external_location.file_events](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/external_location) | resource |
| [databricks_grants.catalog](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants) | resource |
| [databricks_grants.external_location](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants) | resource |
| [databricks_grants.storage_credential](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants) | resource |
| [databricks_storage_credential.file_events](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/storage_credential) | resource |
| [time_sleep.wait_role_creation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_s3_bucket.existing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |
| [databricks_aws_unity_catalog_assume_role_policy.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/aws_unity_catalog_assume_role_policy) | data source |
| [databricks_aws_unity_catalog_policy.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/aws_unity_catalog_policy) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | (Required) AWS account ID where the IAM role will be created | `string` | n/a | yes |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | (Required) Databricks Account ID | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | (Required) Prefix to name the resources created by this module | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | (Required) AWS region where the assets will be deployed | `string` | n/a | yes |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | (Optional) Name for the S3 bucket. If not provided, uses prefix-file-events | `string` | `null` | no |
| <a name="input_catalog_grants"></a> [catalog\_grants](#input\_catalog\_grants) | (Optional) List of grants for the catalog (if created) | <pre>list(object({<br/>    principal  = string<br/>    privileges = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_catalog_isolation_mode"></a> [catalog\_isolation\_mode](#input\_catalog\_isolation\_mode) | (Optional) Isolation mode for the catalog (OPEN or ISOLATED) | `string` | `"OPEN"` | no |
| <a name="input_catalog_name"></a> [catalog\_name](#input\_catalog\_name) | (Optional) Name for the catalog. Required if create\_catalog is true | `string` | `null` | no |
| <a name="input_catalog_owner"></a> [catalog\_owner](#input\_catalog\_owner) | (Optional) Owner of the catalog | `string` | `null` | no |
| <a name="input_create_bucket"></a> [create\_bucket](#input\_create\_bucket) | (Optional) Whether to create a new S3 bucket or use an existing one | `bool` | `true` | no |
| <a name="input_create_catalog"></a> [create\_catalog](#input\_create\_catalog) | (Optional) Whether to create a catalog using this external location | `bool` | `false` | no |
| <a name="input_existing_bucket_name"></a> [existing\_bucket\_name](#input\_existing\_bucket\_name) | (Optional) Name of existing S3 bucket when create\_bucket is false | `string` | `null` | no |
| <a name="input_external_location_grants"></a> [external\_location\_grants](#input\_external\_location\_grants) | (Optional) List of grants for the external location | <pre>list(object({<br/>    principal  = string<br/>    privileges = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_external_location_name"></a> [external\_location\_name](#input\_external\_location\_name) | (Optional) Name for the external location. If not provided, uses prefix-file-events-location | `string` | `null` | no |
| <a name="input_force_destroy_bucket"></a> [force\_destroy\_bucket](#input\_force\_destroy\_bucket) | (Optional) Allow bucket destruction even with objects inside | `bool` | `false` | no |
| <a name="input_s3_path_prefix"></a> [s3\_path\_prefix](#input\_s3\_path\_prefix) | (Optional) Path prefix within the S3 bucket for the external location | `string` | `""` | no |
| <a name="input_storage_credential_grants"></a> [storage\_credential\_grants](#input\_storage\_credential\_grants) | (Optional) List of grants for the storage credential | <pre>list(object({<br/>    principal  = string<br/>    privileges = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_storage_credential_name"></a> [storage\_credential\_name](#input\_storage\_credential\_name) | (Optional) Name for the storage credential. If not provided, uses prefix-file-events-credential | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags to be propagated across all AWS resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | ARN of the S3 bucket used for file events |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | Name of the S3 bucket used for file events |
| <a name="output_catalog_id"></a> [catalog\_id](#output\_catalog\_id) | ID of the catalog (if created) |
| <a name="output_catalog_name"></a> [catalog\_name](#output\_catalog\_name) | Name of the catalog (if created) |
| <a name="output_external_location_id"></a> [external\_location\_id](#output\_external\_location\_id) | ID of the external location |
| <a name="output_external_location_name"></a> [external\_location\_name](#output\_external\_location\_name) | Name of the external location |
| <a name="output_external_location_url"></a> [external\_location\_url](#output\_external\_location\_url) | URL of the external location |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | ARN of the IAM role for file events access |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | Name of the IAM role for file events access |
| <a name="output_s3_url"></a> [s3\_url](#output\_s3\_url) | S3 URL for the external location |
| <a name="output_storage_credential_id"></a> [storage\_credential\_id](#output\_storage\_credential\_id) | ID of the storage credential |
| <a name="output_storage_credential_name"></a> [storage\_credential\_name](#output\_storage\_credential\_name) | Name of the storage credential |
<!-- END_TF_DOCS -->
