# Provisioning Databricks Managed File Events on AWS

This example is using the [aws-managed-file-events](../../modules/aws-managed-file-events) module.

This template provides a deployment of AWS infrastructure for Databricks Managed File Events, enabling file notification mode for Auto Loader with automatic S3 event notifications and SQS queues.

## How to use

1. Reference this module using one of the different [module source types](https://developer.hashicorp.com/terraform/language/modules/sources)
2. Add a `variables.tf` with the same content in [variables.tf](variables.tf)
3. Add a `terraform.tfvars` file and provide values to each defined variable
4. Configure authentication to your Databricks workspace and AWS account
5. Add a `output.tf` file
6. (Optional) Configure your [remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/s3)
7. Run `terraform init` to initialize terraform and get provider ready
8. Run `terraform apply` to create the resources

## Complete Example with All Options

The following shows all available module options:

```hcl
module "managed_file_events" {
  source = "../../modules/aws-managed-file-events"

  # Required variables
  prefix                = var.prefix
  region                = var.region
  aws_account_id        = var.aws_account_id
  databricks_account_id = var.databricks_account_id

  # S3 Configuration
  create_bucket        = true                    # Set to false to use existing bucket
  existing_bucket_name = null                    # Required if create_bucket = false
  bucket_name          = "my-custom-bucket-name" # Custom bucket name (default: prefix-file-events)
  s3_path_prefix       = "data/incoming"         # Path prefix within the bucket
  force_destroy_bucket = false                   # Allow bucket deletion with objects

  # External Location Configuration
  external_location_name  = "my-external-location"  # Custom name (default: prefix-file-events-location)
  storage_credential_name = "my-storage-credential" # Custom name (default: prefix-file-events-credential)

  # Catalog Configuration (Optional)
  create_catalog         = true
  catalog_name           = "my_catalog"
  catalog_owner          = "data-engineers@company.com"
  catalog_isolation_mode = "OPEN"  # OPEN or ISOLATED

  # Grants Configuration
  external_location_grants = [
    {
      principal  = "data-engineers@company.com"
      privileges = ["READ_FILES", "WRITE_FILES"]
    }
  ]

  storage_credential_grants = [
    {
      principal  = "data-engineers@company.com"
      privileges = ["CREATE_EXTERNAL_LOCATION"]
    }
  ]

  catalog_grants = [
    {
      principal  = "data-engineers@company.com"
      privileges = ["USE_CATALOG", "CREATE_SCHEMA"]
    },
    {
      principal  = "analysts@company.com"
      privileges = ["USE_CATALOG"]
    }
  ]

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Project     = "data-platform"
  }
}
```

## Using with Auto Loader

Once deployed, you can use Auto Loader with managed file events in your Databricks notebooks:

```python
df = spark.readStream.format("cloudFiles") \
    .option("cloudFiles.format", "json") \
    .option("cloudFiles.useManagedFileEvents", "true") \
    .load("s3://your-bucket/path")
```

Or in Lakeflow Declarative Pipelines:

```python
from pyspark import pipelines as dp

@dp.table
def my_table():
    return spark.readStream.format("cloudFiles") \
        .option("cloudFiles.format", "json") \
        .option("cloudFiles.useManagedFileEvents", "true") \
        .load("/Volumes") # Ingesting from a volume that points to your S3 bucket will be more performant than the S3 location itself.
```

## Reference

- [Databricks File Notification Mode Documentation](https://docs.databricks.com/aws/en/ingestion/cloud-object-storage/auto-loader/file-notification-mode)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >=1.24.1 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_managed_file_events"></a> [managed\_file\_events](#module\_managed\_file\_events) | ../../modules/aws-managed-file-events | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | (Required) AWS Account ID | `string` | n/a | yes |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | (Required) Databricks Account ID | `string` | n/a | yes |
| <a name="input_databricks_client_id"></a> [databricks\_client\_id](#input\_databricks\_client\_id) | (Required) Databricks service principal client ID | `string` | n/a | yes |
| <a name="input_databricks_client_secret"></a> [databricks\_client\_secret](#input\_databricks\_client\_secret) | (Required) Databricks service principal client secret | `string` | n/a | yes |
| <a name="input_databricks_host"></a> [databricks\_host](#input\_databricks\_host) | (Required) Databricks workspace URL (e.g., https://xxx.cloud.databricks.com) | `string` | n/a | yes |
| <a name="input_databricks_pat_token"></a> [databricks\_pat\_token](#input\_databricks\_pat\_token) | (Required) Databricks service principal client secret | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | (Required) Prefix for resource naming | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | (Required) AWS region to deploy to | `string` | n/a | yes |
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | (Optional) AWS CLI profile name for authentication | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags to add to created resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | Name of the S3 bucket |
| <a name="output_external_location_name"></a> [external\_location\_name](#output\_external\_location\_name) | Name of the external location |
| <a name="output_external_location_url"></a> [external\_location\_url](#output\_external\_location\_url) | S3 URL of the external location |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | ARN of the IAM role |
| <a name="output_storage_credential_name"></a> [storage\_credential\_name](#output\_storage\_credential\_name) | Name of the storage credential |
<!-- END_TF_DOCS -->
