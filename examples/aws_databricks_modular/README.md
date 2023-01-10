## AWS Databricks Multiple Workspace Deployment with KMS and Customer-managed VPC at scale

In this example, we created modules to deploy E2 Databricks workspaces at scale. Users of this template should supply configuration variables for each workspaces and edit the locals block in `main.tf`, to deploy multiple E2 workspaces (customer-managed VPC setup). This modular design of E2 workspaces allow customer to deploy, manage and delete individual workspaces easily, with minimal set of scripts. This template takes reference (e.g. CMK module) from https://github.com/andyweaves/databricks-terraform-e2e-examples from andrew.weaver@databricks.com and adapted to specific customer requirements.

## Get Started

Step 1: Clone this repo to local, set environment variables for `aws` and `databricks` providers authentication:
    
```bash
export TF_VAR_databricks_account_username=your_username
export TF_VAR_databricks_account_password=your_password
export TF_VAR_databricks_account_id=your_databricks_E2_account_id

export AWS_ACCESS_KEY_ID=your_aws_role_access_key_id
export AWS_SECRET_ACCESS_KEY=your_aws_role_secret_access_key
```

Step 2: Modify `variables.tf`, for each workspace you need to write a variable block like this:

```terraform
variable "workspace_1_config" {
    default = {
        private_subnet_pair = { subnet1_cidr = "10.109.4.0/23", subnet2_cidr = "10.109.6.0/23" }
        workspace_name      = "test-workspace-1"
        prefix              = "ws1"
        region              = "ap-southeast-1"
        root_bucket_name    = "test-workspace-1-rootbucket"
    }
}
```

Since we are using CMK (customer managed key) for encryption on root S3 bucket and Databricks managed resources, you also need to provide an AWS IAM ARN for `cmk_admin`. The format will be: `arn:aws:iam::123456:user/xxx`. You need to create this user and assign KMS admin role to it.


Step 3: Modify `main.tf` - locals block, add/remove your workspace config var inside locals, like this:

```terraform
workspace_confs = {
    workspace_1 = var.workspace_1_config
    workspace_2 = var.workspace_2_config
    workspace_3 = var.workspace_3_config
}
```

Step 4: Check your VPC and subnet CIDR, then run `terraform init` and `terraform apply` to deploy your workspaces; this will deploy multiple E2 workspaces into your VPC.

## Common Actions

### To delete specific workspace
You just need to remove the workspace config from `main.tf` - locals block, then run `terraform apply` to delete the workspace. For example, to delete workspace_1, you need to remove the following lines from `main.tf` - locals block:

```terraform
workspace_1 = var.workspace_1_config
```

Then run `terraform apply` to delete workspace_1.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name                                                    | Version |
| ------------------------------------------------------- | ------- |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0  |

## Providers

| Name                                                                               | Version |
| ---------------------------------------------------------------------------------- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws)                                  | 4.29.0  |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks)             | 1.2.1   |
| <a name="provider_databricks.mws"></a> [databricks.mws](#provider\_databricks.mws) | 1.2.1   |
| <a name="provider_random"></a> [random](#provider\_random)                         | 3.4.2   |
| <a name="provider_time"></a> [time](#provider\_time)                               | 0.8.0   |

## Modules

| Name                                                                                               | Source                  | Version |
| -------------------------------------------------------------------------------------------------- | ----------------------- | ------- |
| <a name="module_workspace_collection"></a> [workspace\_collection](#module\_workspace\_collection) | ./modules/mws_workspace | n/a     |

## Resources

| Name                                                                                                                                                               | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------- |
| [aws_eip.nat_gateway_elastic_ips](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip)                                                 | resource    |
| [aws_iam_role.cross_account_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                            | resource    |
| [aws_iam_role_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy)                                            | resource    |
| [aws_internet_gateway.igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway)                                           | resource    |
| [aws_nat_gateway.nat_gateways](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway)                                            | resource    |
| [aws_route_table.public_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)                                      | resource    |
| [aws_route_table_association.public_route_table_associations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource    |
| [aws_security_group.test_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)                                           | resource    |
| [aws_subnet.public_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)                                                    | resource    |
| [aws_vpc.mainvpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)                                                                 | resource    |
| [databricks_mws_credentials.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_credentials)                             | resource    |
| [random_string.naming](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string)                                                      | resource    |
| [time_sleep.wait](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep)                                                              | resource    |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones)                              | data source |
| [databricks_aws_assume_role_policy.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/aws_assume_role_policy)            | data source |
| [databricks_aws_crossaccount_policy.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/aws_crossaccount_policy)          | data source |

## Inputs

| Name                                                                                                                    | Description | Type           | Default                                                                                                                                                                                                                                  | Required |
| ----------------------------------------------------------------------------------------------------------------------- | ----------- | -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------: |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id)                   | n/a         | `string`       | n/a                                                                                                                                                                                                                                      |   yes    |
| <a name="input_databricks_account_password"></a> [databricks\_account\_password](#input\_databricks\_account\_password) | n/a         | `string`       | n/a                                                                                                                                                                                                                                      |   yes    |
| <a name="input_databricks_account_username"></a> [databricks\_account\_username](#input\_databricks\_account\_username) | n/a         | `string`       | n/a                                                                                                                                                                                                                                      |   yes    |
| <a name="input_public_subnets_cidr"></a> [public\_subnets\_cidr](#input\_public\_subnets\_cidr)                         | n/a         | `list(string)` | <pre>[<br>  "10.109.2.0/23"<br>]</pre>                                                                                                                                                                                                   |    no    |
| <a name="input_region"></a> [region](#input\_region)                                                                    | n/a         | `string`       | `"ap-southeast-1"`                                                                                                                                                                                                                       |    no    |
| <a name="input_tags"></a> [tags](#input\_tags)                                                                          | n/a         | `map`          | `{}`                                                                                                                                                                                                                                     |    no    |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr)                                                            | n/a         | `string`       | `"10.109.0.0/17"`                                                                                                                                                                                                                        |    no    |
| <a name="input_workspace_1_config"></a> [workspace\_1\_config](#input\_workspace\_1\_config)                            | n/a         | `map`          | <pre>{<br>  "prefix": "ws1",<br>  "private_subnet_pair": {<br>    "subnet1_cidr": "10.109.4.0/23",<br>    "subnet2_cidr": "10.109.6.0/23"<br>  },<br>  "region": "ap-southeast-1",<br>  "workspace_name": "test-workspace-1"<br>}</pre>  |    no    |
| <a name="input_workspace_2_config"></a> [workspace\_2\_config](#input\_workspace\_2\_config)                            | n/a         | `map`          | <pre>{<br>  "prefix": "ws2",<br>  "private_subnet_pair": {<br>    "subnet1_cidr": "10.109.8.0/23",<br>    "subnet2_cidr": "10.109.10.0/23"<br>  },<br>  "region": "ap-southeast-1",<br>  "workspace_name": "test-workspace-2"<br>}</pre> |    no    |

## Outputs

| Name                                                                                   | Description |
| -------------------------------------------------------------------------------------- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn)                                          | n/a         |
| <a name="output_databricks_hosts"></a> [databricks\_hosts](#output\_databricks\_hosts) | n/a         |
<!-- END_TF_DOCS -->