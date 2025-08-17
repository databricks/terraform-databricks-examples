AWS Databricks Unity Catalog - Stage 2
=========================

In this template, we show how to dpeloy Unity Catalog related resources such as unity metastores, account level users and groups.

This is stage 2 of UC deployment, you can also run this stage 2 template directly without stage 1 (which helps you create `account admin` identity), but you need to make sure using account admin identity to authenticate the `databricks mws` provider, instead of using `account owner`. One major reason of not using `account owner` in terraform is you cannot destroy yourself from admin list.

If you don't have an `account admin` identity, you can refer to stage 1: 
[aws-databricks-unity-catalog-bootstrap](https://github.com/databricks/terraform-databricks-examples/tree/main/examples/aws-databricks-uc-bootstrap)

![alt text](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/examples/aws-databricks-uc/images/uc-tf-onboarding.png?raw=true)

When running tf configs for UC resources, due to sometimes requires a few minutes to be ready and you may encounter errors along the way, so you can either wait for the UI to be updated before you apply and patch the next changes; or specifically add depends_on to accoune level resources

## Get Started

Step 1: Fill in values in `terraform.tfvars`; also configure env necessary variables for AWS and Databricks provider authentication. Such as:


```bash
export TF_VAR_databricks_account_client_id=your_account_level_spn_application_id
export TF_VAR_databricks_account_client_secret=your_account_level_spn_secret
export TF_VAR_databricks_account_id=your_databricks_account_id

export AWS_ACCESS_KEY_ID=your_aws_role_access_key_id
export AWS_SECRET_ACCESS_KEY=your_aws_role_secret_access_key
``` 

Step 2: Run `terraform init` and `terraform apply` to deploy the resources. This will deploy both AWS resources that Unity Catalog requires and Databricks Account Level resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.32.0 |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | 1.3.1 |
| <a name="provider_databricks.mws"></a> [databricks.mws](#provider\_databricks.mws) | 1.3.1 |
| <a name="provider_databricks.ws1"></a> [databricks.ws1](#provider\_databricks.ws1) | 1.3.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.external_data_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.sample_data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.unity_metastore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.external_data_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.metastore_data_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_s3_bucket.external](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.metastore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.metastore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_public_access_block.external](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.metastore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_versioning.metastore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [databricks_catalog.sandbox](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/catalog) | resource |
| [databricks_default_namespace_setting.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/default_namespace_setting) | resource |
| [databricks_external_location.some](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/external_location) | resource |
| [databricks_grants.sandbox](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants) | resource |
| [databricks_grants.some](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants) | resource |
| [databricks_grants.things](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants) | resource |
| [databricks_group.admin_group](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/group) | resource |
| [databricks_group_member.admin_group_member](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/group_member) | resource |
| [databricks_metastore.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/metastore) | resource |
| [databricks_metastore_assignment.default_metastore](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/metastore_assignment) | resource |
| [databricks_metastore_data_access.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/metastore_data_access) | resource |
| [databricks_schema.things](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/schema) | resource |
| [databricks_storage_credential.external](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/storage_credential) | resource |
| [databricks_user.unity_users](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/user) | resource |
| [databricks_user_role.metastore_admin](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/user_role) | resource |
| [aws_iam_policy_document.passrole_for_uc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | (Required) AWS account ID where the cross-account role for Unity Catalog will be created | `string` | n/a | yes |
| <a name="input_databricks_account_admins"></a> [databricks\_account\_admins](#input\_databricks\_account\_admins) | List of Admins to be added at account-level for Unity Catalog.<br/>  Enter with square brackets and double quotes<br/>  e.g ["first.admin@domain.com", "second.admin@domain.com"] | `list(string)` | n/a | yes |
| <a name="input_databricks_account_client_id"></a> [databricks\_account\_client\_id](#input\_databricks\_account\_client\_id) | Application ID of account-level service principal | `string` | n/a | yes |
| <a name="input_databricks_account_client_secret"></a> [databricks\_account\_client\_secret](#input\_databricks\_account\_client\_secret) | Client secret of account-level service principal | `string` | n/a | yes |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | Databricks Account ID | `string` | n/a | yes |
| <a name="input_databricks_users"></a> [databricks\_users](#input\_databricks\_users) | List of Databricks users to be added at account-level for Unity Catalog. should we put the account owner email here? maybe not since it's always there and we dont want tf to destroy<br/>  Enter with square brackets and double quotes<br/>  e.g ["first.last@domain.com", "second.last@domain.com"] | `list(string)` | n/a | yes |
| <a name="input_pat_ws_1"></a> [pat\_ws\_1](#input\_pat\_ws\_1) | n/a | `string` | n/a | yes |
| <a name="input_pat_ws_2"></a> [pat\_ws\_2](#input\_pat\_ws\_2) | n/a | `string` | n/a | yes |
| <a name="input_unity_admin_group"></a> [unity\_admin\_group](#input\_unity\_admin\_group) | Name of the admin group. This group will be set as the owner of the Unity Catalog metastore | `string` | n/a | yes |
| <a name="input_databricks_workspace_ids"></a> [databricks\_workspace\_ids](#input\_databricks\_workspace\_ids) | List of Databricks workspace IDs to be enabled with Unity Catalog.<br/>  Enter with square brackets and double quotes<br/>  e.g. ["111111111", "222222222"] | `list(string)` | <pre>[<br/>  "2424101092929547"<br/>]</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region to deploy to | `string` | `"ap-southeast-1"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Optional tags to add to created resources | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
