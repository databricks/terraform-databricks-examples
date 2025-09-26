S3 bucket remote backend for Terraform state files
=========================

In this example, we show how to use S3 bucket as a remote backend for Terraform project's state files. Two major reasons that you should use remote backend instead of default local backend are:
1. State files contains sensitive information and you want to protect them, encrypt and store in a secured storage.
2. When collaborating with other team members, you want to safe keep your state files and enforce locking to prevent conflicts.

### Architecture

> The image below shows the components of a S3 remote backend  

![alt text](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/examples/aws-databricks-modular-privatelink/images/tf-remote-s3-backend.png?raw=true)

### Setup remote backend

1. Use the default local backend (comment out all the scripts in `terraform` block, line 5 in `main.tf`), read and modify `main.tf` accordingly, this is to create a S3 bucket (with versioning and server-side encryption) and a dynamoDB table for the locking mechanism.
2. Run `terraform init` and `terraform apply` to create the S3 bucket and dynamoDB table, at this step, you observe states stored in local file `terraform.tfstate`.
3. Uncomment the `terraform` block, to configure the backend. Then run `terraform init` again, this will migrate the state file from local to S3 bucket. Input `Yes` when prompted.
4. After you entered `Yes`, you will see the state file is now stored in S3 bucket. You can also check the dynamoDB table to see the lock record; and now the local state file will become empty.


### How to destroy remote backend infra

To properly destroy remote backend infra, you need to migrate the state files to local first, to avoid having conflicts. 

1. Comment out the `terraform` block in `main.tf`, to switch to use local backend. This step moves the state file from S3 bucket to local.
2. Run `terraform init` and `terraform destroy` to destroy the remote backend infra.

### Other projects to use this remote backend

You only need to configure the same terraform backend block in other terraform projects, to let them use the same remote backend. Inside the backend configs, you need to design the `key` in your bucket to be unique for each project.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.31.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.terraform_locks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_dynamodb_table.terraform_locks_databricks_project](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_s3_bucket.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The name of the S3 bucket to store the Terraform state file | `string` | `"tf-backend-bucket-haowang"` | no |
| <a name="input_dynamodb_table"></a> [dynamodb\_table](#input\_dynamodb\_table) | The name of the DynamoDB table to use for state locking | `string` | `"tf-backend-dynamodb-haowang"` | no |
| <a name="input_dynamodb_table_databricks_project"></a> [dynamodb\_table\_databricks\_project](#input\_dynamodb\_table\_databricks\_project) | The name of the DynamoDB table to use for state locking | `string` | `"tf-backend-dynamodb-databricks-project"` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to use for the backend | `string` | `"ap-southeast-1"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
