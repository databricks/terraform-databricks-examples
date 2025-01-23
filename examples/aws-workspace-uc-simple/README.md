AWS Databricks Unity Catalog - One apply
=========================

Using this template, you can deploy all the necessary resources in order to have a simple Databricks AWS workspace with Unity Catalog enabled.

This is a one apply template, you will create the base aws resources for a workspace (VPC, subnets, VPC endpoints, S3 Bucket and cross account IAM role) and the unity catalog metastore and cross account role. 

In order to run this template, you need to have an `account admin` identity, preferably with a service principal. Running with a user account also works, but one should not include the `account owner` in the terraform UC admin or databricks users list as you cannot destroy yourself from the admin list. 

When running tf configs for UC resources, due to sometimes requires a few minutes to be ready and you may encounter errors along the way, so you can either wait for the UI to be updated before you apply and patch the next changes; or specifically add depends_on to account level resources. We tried to add the necessary wait times but should you encounter an error just apply again and you should be good to go.

## Get Started

> Step 1: Fill in values in `terraform.tfvars`; also configure env necessary variables for AWS provider authentication.

> Step 2: Run `terraform init` and `terraform apply` to deploy the resources. This will deploy both AWS resources that Unity Catalog requires and Databricks Account Level resources.

## Requirements

| Name                                                                         | Version           |
|------------------------------------------------------------------------------|-------------------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws)                      | ~> 5.0            |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >= 1.2.0, < 2.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random)             | =3.4.1            |
| <a name="requirement_time"></a> [time](#requirement\_time)                   | =0.9.1            |

## Providers

| Name                                                                                                 | Version           |
|------------------------------------------------------------------------------------------------------|-------------------|
| <a name="provider_aws"></a> [aws](#provider\_aws)                                                    | ~> 5.0            |
| <a name="provider_databricks.mws"></a> [databricks.mws](#provider\_databricks.mws)                   | >= 1.2.0, < 2.0.0 |
| <a name="provider_databricks.workspace"></a> [databricks.workspace](#provider\_databricks.workspace) | >= 1.2.0, < 2.0.0 |
| <a name="provider_random"></a> [random](#provider\_random)                                           | =3.4.1            |
| <a name="provider_time"></a> [time](#provider\_time)                                                 | =0.9.1            |


## Resources

| Name                                                                                                                                                                  | Type        |
|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| [databricks_catalog.demo_catalog](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/catalog)                                        | resource    |
| [databricks_cluster.unity_catalog_cluster](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/cluster)                               | resource    |
| [databricks_grants.unity_catalog_grants](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants)                                  | resource    |
| [databricks_group.admin_group](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/group)                                             | resource    |
| [databricks_group.users](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/group)                                                   | resource    |
| [databricks_group_member.admin_group_member](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/group_member)                        | resource    |
| [databricks_group_member.my_service_principal](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/group_member)                      | resource    |
| [databricks_group_member.users_group_members](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/group_member)                       | resource    |
| [databricks_mws_permission_assignment.add_admin_group](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_permission_assignment) | resource    |
| [databricks_mws_permission_assignment.add_user_group](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_permission_assignment)  | resource    |
| [databricks_user.unity_users](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/user)                                               | resource    |
| [random_string.naming](https://registry.terraform.io/providers/hashicorp/random/3.4.1/docs/resources/string)                                                          | resource    |
| [time_sleep.wait_for_permission_apis](https://registry.terraform.io/providers/hashicorp/time/0.9.1/docs/resources/sleep)                                              | resource    |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)                                         | data source |
| [databricks_node_type.smallest](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/node_type)                                     | data source |
| [databricks_service_principal.admin_service_principal](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/service_principal)      | data source |
| [databricks_spark_version.latest_version](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/spark_version)                       | data source |

## Inputs

| Name                                                                                                                              | Description                                                                                                                                                                               | Type           | Default | Required |
|-----------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|---------|:--------:|
| <a name="input_aws_access_services_role_name"></a> [aws\_access\_services\_role\_name](#input\_aws\_access\_services\_role\_name) | (Optional) Name for the AWS Services role by this module                                                                                                                                  | `string`       | `null`  |    no    |
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile)                                                             | (Required) AWS cli profile to be used for authentication with AWS                                                                                                                         | `string`       | n/a     |   yes    |
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block)                                                                | (Required) CIDR block to be used to create the Databricks VPC                                                                                                                             | `string`       | n/a     |   yes    |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id)                             | (Required) Databricks Account ID                                                                                                                                                          | `string`       | n/a     |   yes    |
| <a name="input_databricks_client_id"></a> [databricks\_client\_id](#input\_databricks\_client\_id)                                | (Required) Client ID to authenticate the Databricks provider at the account level                                                                                                         | `string`       | n/a     |   yes    |
| <a name="input_databricks_client_secret"></a> [databricks\_client\_secret](#input\_databricks\_client\_secret)                    | (Required) Client secret to authenticate the Databricks provider at the account level                                                                                                     | `string`       | n/a     |   yes    |
| <a name="input_databricks_metastore_admins"></a> [databricks\_metastore\_admins](#input\_databricks\_metastore\_admins)           | List of Admins to be added at account-level for Unity Catalog.<br/>  Enter with square brackets and double quotes<br/>  e.g ["first.admin@domain.com", "second.admin@domain.com"]         | `list(string)` | n/a     |   yes    |
| <a name="input_databricks_users"></a> [databricks\_users](#input\_databricks\_users)                                              | List of Databricks users to be added at account-level for Unity Catalog.<br/>  Enter with square brackets and double quotes<br/>  e.g ["first.last@domain.com", "second.last@domain.com"] | `list(string)` | n/a     |   yes    |
| <a name="input_my_username"></a> [my\_username](#input\_my\_username)                                                             | (Required) Username in the form of an email to be added to the tags and be declared as owner of the assets                                                                                | `string`       | n/a     |   yes    |
| <a name="input_region"></a> [region](#input\_region)                                                                              | (Required) AWS region where the assets will be deployed                                                                                                                                   | `string`       | n/a     |   yes    |
| <a name="input_tags"></a> [tags](#input\_tags)                                                                                    | (Optional) List of tags to be propagated accross all assets in this demo                                                                                                                  | `map(string)`  | n/a     |   yes    |
| <a name="input_unity_admin_group"></a> [unity\_admin\_group](#input\_unity\_admin\_group)                                         | (Required) Name of the admin group. This group will be set as the owner of the Unity Catalog metastore                                                                                    | `string`       | n/a     |   yes    |
| <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name)                                                    | (Required) Databricks workspace name to be used for deployment                                                                                                                            | `string`       | n/a     |   yes    |

## Outputs

| Name                                                                                                             | Description              |
|------------------------------------------------------------------------------------------------------------------|--------------------------|
| <a name="output_databricks_workspace_id"></a> [databricks\_workspace\_id](#output\_databricks\_workspace\_id)    | Databricks workspace ID  |
| <a name="output_databricks_workspace_url"></a> [databricks\_workspace\_url](#output\_databricks\_workspace\_url) | Databricks workspace URL |