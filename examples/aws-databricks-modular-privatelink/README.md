Deploy Multiple AWS Databricks Workspace with CMK, Customer-managed VPC, Private Links, IP Access Lists
=========================

In this example, we created modules and root level template to deploy multiple (e.g. 10+) E2 Databricks workspaces at scale easily. Users of this template minimally should do these:
1. Supply credentials (aws+databricks) and configuration variables for each workspaces 
2. Edit the locals block in `main.tf` to decide what & how many workspaces to deploy
3. Run `terraform init` and `terraform apply` to deploy 1 or more workspaces into your VPC.
4. Optionally, take the outputs files in `/artifacts` and patch each workspace with IP Access List.
   
This modular design also allows customer to deploy, manage and delete `individual` workspace(s) easily, with minimal configuration needed. This template takes heavy reference (e.g. CMK module + Private Links) from https://github.com/andyweaves/databricks-terraform-e2e-examples from andrew.weaver@databricks.com and this repo is adapted to meet specific customer requirements.

## Architecture

> To be added - LucidChart brewing...

## Project Folder Structure

    .
    ├── iam.tf
    ├── instance_profile.tf
    ├── main.tf
    ├── outputs.tf
    ├── privatelink.tf
    ├── providers.tf
    ├── variables.tf
    ├── vpc.tf
    ├── artifacts        # stores workspaces URL and other info for next stage deployment
        ├── workspace_1_deployment.json       
        ├── ...
    ├── modules   
        ├── databricks_cmk
            ├── data.tf
            ├── main.tf         
            ├── outputs.tf      
            ├── providers.tf
            ├── variables.tf    
        ├── mws_workspace
            ├── main.tf         
            ├── variables.tf    
            ├── outputs.tf      
            ├── modules
                ├── mws_network
                    ├── main.tf
                    ├── variables.tf
                    ├── outputs.tf
                ├── mws_storage
                    ├── main.tf
                    ├── variables.tf
                    ├── outputs.tf


## Get Started

> Step 1: Clone this repo to local, set environment variables for `aws` and `databricks` providers authentication:
    
```bash
export TF_VAR_databricks_account_username=your_username
export TF_VAR_databricks_account_password=your_password
export TF_VAR_databricks_account_id=your_databricks_E2_account_id

export AWS_ACCESS_KEY_ID=your_aws_role_access_key_id
export AWS_SECRET_ACCESS_KEY=your_aws_role_secret_access_key
```

> Step 2: Modify `variables.tf`, for each workspace you need to write a variable block like this, all attributes are required:

```terraform
variable "workspace_1_config" {
  default = {
    private_subnet_pair = { subnet1_cidr = "10.109.6.0/23", subnet2_cidr = "10.109.8.0/23" }
    workspace_name      = "test-workspace-1"
    prefix              = "ws1" // prefix decides subnets name
    region              = "ap-southeast-1"
    root_bucket_name    = "test-workspace-1-rootbucket"
    block_list          = ["58.133.93.159"]
    allow_list          = [] // if allow_list empty, all public IP not blocked by block_list are allowed
    tags = {
      "Name" = "test-workspace-1-tags",
      "Env"  = "test-ws-1" // add more tags if needed, tags will be applied on databricks subnets and root s3 bucket, but workspace objects like clusters tag needs to be defined in workspace config elsewhere
    }
  }
}
```

Since we are using CMK (customer managed key) for encryption on root S3 bucket and Databricks managed resources, you also need to provide an AWS IAM ARN for `cmk_admin`. The format will be: `arn:aws:iam::123456:user/xxx`. You need to create this user and assign KMS admin role to it.


> Step 3: Modify `main.tf` - locals block, add/remove your workspace config var inside locals, like this:

```terraform
workspace_confs = {
    workspace_1 = var.workspace_1_config
    workspace_2 = var.workspace_2_config
    workspace_3 = var.workspace_3_config
}
```

> Step 4: Check your VPC and subnet CIDR, then run `terraform init` and `terraform apply` to deploy your workspaces; this will deploy multiple E2 workspaces into your VPC.

We are calling the module `mws_workspace` to create multiple workspaces by batch, you should treat this concept as a group of workspaces that share the same VPC in a region. If you want to deploy workspaces in different VPCs, you need to create multiple `mws_workspace` instances. 

In the default setting, this template creates one VPC (with one public subnet and one private subnet for hosting VPCEs). Each incoming workspace will add 2 private subnets into this VPC. If you need to create multiple VPCs, you should copy paste the VPC configs and change accordingly, or you can wrap VPC configs into a module, we leave this to you. 

At this step, your workspaces deployment and VPC networking infra should have been successfully deployed and you will have `n` config json files for `n` workspaces deployed, under `/artifacts` folder, to be used in another Terraform project to deploy workspace objects including IP Access List. 

## Private Links

In this example, we used 1 VPC for all workspaces, and we used backend VPCE for Databricks clusters to communicate with control plane. All workspaces deployed into the same VPC will share one pair of VPCEs (one for relay, one for rest api), typically since VPCEs can provide considerable bandwidth, you just need one such pair of VPCEs for all workspaces in each region. For HA setup, you can build VPCEs into multiple az as well. 

## IP Access List

For all the workspaces in this template, we allowed access from the Internet, but we restrict access using IP access list. Each workspace can be customized with `allow_list` and `block_list` in variables block.

The process of IP access list management is separated from Terraform process of workspace deployment. This is because we want:
1. To keep a clean cut between workspace deployment and workspace management. 
2. It is general good practice to separate workspace deployment and workspace management. 
3. To keep workspace objects deployment in separate terraform project, not to risk leaving orphaned resources and ruins your workspace deployment (e.g. changed provider etc).

After you have deployed your workspaces using this template (`aws_databricks_modular_privatelink`), you will have workspace host URLs saved as local file under `/artifacts`. Those files are for you to input to the next Terraform workspace management process, and to patch the workspace IP access list.

> IP Access List Decision Flow

<img src="../charts/ip-access-lists-flow.png" width="400">

> Example - blocked access from workspace: my phone is blocked to access the workspace, since the public IP was in the workspace's block list.

<img src="../charts/ip_access_list_block.png" width="400">

> Recommended to keep IP Access List management in a separate Terraform project, to avoid orphaned resources. (Similar error below)

<img src="../charts/orphaned_resources.png" width="800">

## Tagging

We added custom tagging options in `variables.tf` to tag your aws resources: in each workspace's config variable map, you can supply with any number of tags, and these tags will propagate down to resources related to that workspace, like root bucket s3 and the 2 subnets. Note that aws databricks itself does not support tagging, also the abstract layer of `storage_configuration`, and `network_configuration` does not support tagging. Instead, if you need to tag/enforce certain tags for `clusters` and `pools`, do it in `workspace management` terraform projects, (not this directory that deploys workspaces).

## Terraform States Files stored in remote S3
We recommend using remote storage, like S3, for state storage, instead of using default local backend. If you have already applied and retains state files locally, you can also configure s3 backend then apply, it will migrate local state file content into S3 bucket, then local state file will become empty. As you switch the backends, state files are migrated from `A` to `B`. 

```terraform
terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket = "terraform-up-and-running-state-unique-hwang"
    key    = "global/s3/terraform.tfstate"
    region = "ap-southeast-1"
    # Replace this with your DynamoDB table name!
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}
```

You should create the infra for remote backend in another Terraform Project, like the `aws_remote_backend_infra` project in this repo's root level - https://github.com/hwang-db/tf_aws_deployment/tree/main/aws_remote_backend_infra, since we want to separate the backend infra out from any databricks project infra. As shown below, you create a separate set of tf scripts and create the S3 and DynamoDB Table. Then all other tf projects can store their state files in this remote backend.

<img src="../charts/tf_remote_s3_backend.png" width="800">

Tips: If you want to destroy your backend infra (S3+DynamoDB), since your state files of S3 and backend infra are stored in that exact S3, to avoid falling into chicken and egg problem, you need to follow these steps:
1. Comment out remote backend and migrate states to local backend
2. Comment out all backend resources configs, run apply to get rid of them. Or you can run destroy.

## Common Actions

### To add specific workspace(s)

You just need to supply with each workspace's configuration in root level `variables.tf`, similar to the examples given.
Then you need to add the workspaces you want into locals block and run apply.

### To delete specific workspace(s)

Do Not run `terraform destroy` or `terraform destroy -target` for the purpose of deleting resources. Instead, you should just remove resources from your `.tf` scripts and run `terraform apply`.

You just need to remove the workspace config from `main.tf` - locals block, then run `terraform apply` to delete the workspace. For example, to delete `workspace_3`, you need to remove the following lines from `main.tf` - locals block, it is optional to remove the same from variable block in `variables.tf`:

```terraform
workspace_3 = var.workspace_3_config
```

Then run `terraform apply`, workspace_3 will be deleted.

### Configure IAM roles, S3 access policies and Instance Profile for clusters

This template illustrates the traditional method of creating Instance Profile to grant cluster with S3 bucket access, see [original official guide](https://docs.databricks.com/administration-guide/cloud-configurations/aws/instance-profiles.html)

The sample script in `instance_profile.tf` will help you create the underlying IAM role and policies for you to create instance profile at workspace level, you will find the `arn` from tf output, you can then manually take the value and configure at workspace admin setting page like below:

<img src="../charts/instance_profile.png" width="500">

Next you need to configure permissions for users/groups to use this instance profile to spin up clusters, and the cluster will be able to access the S3 specified in the instance profile's IAM role's policy.


### Grant Access to other users to use this instance profile

Deploying instance profile to workspace is obviously a workspace configuration process, and we suggest you write the relevant tf scripts in workspace management project (such as inside `aws_workspace_config`), not in this workspace deployment project. The screenshot in the above step is a manual version of adding instance profile inside your workspace.

By default, the instance profile you created from the above steps is only accessible to its creator and admin group. Thus you also need to do access control (permissions) and specify who can use such instance profile to spin up clusters. See sample tf script and tutorial here: 
[Tutorial](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/instance_profile#granting-access-to-all-users)


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name                                                    | Version |
| ------------------------------------------------------- | ------- |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0  |

## Providers

| Name                                                                               | Version |
| ---------------------------------------------------------------------------------- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws)                                  | 4.32.0  |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks)             | 1.3.1   |
| <a name="provider_databricks.mws"></a> [databricks.mws](#provider\_databricks.mws) | 1.3.1   |
| <a name="provider_http"></a> [http](#provider\_http)                               | 3.1.0   |
| <a name="provider_local"></a> [local](#provider\_local)                            | 2.2.3   |
| <a name="provider_random"></a> [random](#provider\_random)                         | 3.4.3   |
| <a name="provider_time"></a> [time](#provider\_time)                               | 0.8.0   |

## Modules

| Name                                                                                               | Source                   | Version |
| -------------------------------------------------------------------------------------------------- | ------------------------ | ------- |
| <a name="module_databricks_cmk"></a> [databricks\_cmk](#module\_databricks\_cmk)                   | ./modules/databricks_cmk | n/a     |
| <a name="module_workspace_collection"></a> [workspace\_collection](#module\_workspace\_collection) | ./modules/mws_workspace  | n/a     |

## Resources

| Name                                                                                                                                                               | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------- |
| [aws_eip.nat_gateway_elastic_ips](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip)                                                 | resource    |
| [aws_iam_role.cross_account_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                            | resource    |
| [aws_iam_role_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy)                                            | resource    |
| [aws_internet_gateway.igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway)                                           | resource    |
| [aws_nat_gateway.nat_gateways](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway)                                            | resource    |
| [aws_route_table.pl_subnet_rt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)                                            | resource    |
| [aws_route_table.public_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)                                      | resource    |
| [aws_route_table_association.dataplane_vpce_rtb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)              | resource    |
| [aws_route_table_association.public_route_table_associations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource    |
| [aws_security_group.privatelink](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)                                       | resource    |
| [aws_security_group.sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)                                                | resource    |
| [aws_subnet.privatelink](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)                                                       | resource    |
| [aws_subnet.public_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)                                                    | resource    |
| [aws_vpc.mainvpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)                                                                 | resource    |
| [aws_vpc_endpoint.backend_relay](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint)                                         | resource    |
| [aws_vpc_endpoint.backend_rest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint)                                          | resource    |
| [databricks_mws_credentials.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_credentials)                             | resource    |
| [databricks_mws_vpc_endpoint.backend_rest_vpce](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_vpc_endpoint)              | resource    |
| [databricks_mws_vpc_endpoint.relay](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_vpc_endpoint)                          | resource    |
| [local_file.deployment_information](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file)                                            | resource    |
| [random_string.naming](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string)                                                      | resource    |
| [time_sleep.wait](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep)                                                              | resource    |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones)                              | data source |
| [databricks_aws_assume_role_policy.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/aws_assume_role_policy)            | data source |
| [databricks_aws_crossaccount_policy.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/aws_crossaccount_policy)          | data source |
| [http_http.my](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http)                                                               | data source |

## Inputs

| Name                                                                                                                    | Description | Type           | Default                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | Required |
| ----------------------------------------------------------------------------------------------------------------------- | ----------- | -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------: |
| <a name="input_cmk_admin"></a> [cmk\_admin](#input\_cmk\_admin)                                                         | cmk         | `string`       | `"arn:aws:iam::026655378770:user/hao"`                                                                                                                                                                                                                                                                                                                                                                                                                                                            |    no    |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id)                   | n/a         | `string`       | n/a                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |   yes    |
| <a name="input_databricks_account_password"></a> [databricks\_account\_password](#input\_databricks\_account\_password) | n/a         | `string`       | n/a                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |   yes    |
| <a name="input_databricks_account_username"></a> [databricks\_account\_username](#input\_databricks\_account\_username) | n/a         | `string`       | n/a                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |   yes    |
| <a name="input_privatelink_subnets_cidr"></a> [privatelink\_subnets\_cidr](#input\_privatelink\_subnets\_cidr)          | n/a         | `list(string)` | <pre>[<br>  "10.109.4.0/23"<br>]</pre>                                                                                                                                                                                                                                                                                                                                                                                                                                                            |    no    |
| <a name="input_public_subnets_cidr"></a> [public\_subnets\_cidr](#input\_public\_subnets\_cidr)                         | n/a         | `list(string)` | <pre>[<br>  "10.109.2.0/23"<br>]</pre>                                                                                                                                                                                                                                                                                                                                                                                                                                                            |    no    |
| <a name="input_region"></a> [region](#input\_region)                                                                    | n/a         | `string`       | `"ap-southeast-1"`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |    no    |
| <a name="input_relay_vpce_service"></a> [relay\_vpce\_service](#input\_relay\_vpce\_service)                            | n/a         | `string`       | `"com.amazonaws.vpce.ap-southeast-1.vpce-svc-0557367c6fc1a0c5c"`                                                                                                                                                                                                                                                                                                                                                                                                                                  |    no    |
| <a name="input_tags"></a> [tags](#input\_tags)                                                                          | n/a         | `map`          | `{}`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |    no    |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr)                                                            | n/a         | `string`       | `"10.109.0.0/17"`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |    no    |
| <a name="input_workspace_1_config"></a> [workspace\_1\_config](#input\_workspace\_1\_config)                            | n/a         | `map`          | <pre>{<br>  "allow_list": [<br>    "65.184.145.97"<br>  ],<br>  "block_list": [<br>    "58.133.93.159"<br>  ],<br>  "prefix": "ws1",<br>  "private_subnet_pair": {<br>    "subnet1_cidr": "10.109.6.0/23",<br>    "subnet2_cidr": "10.109.8.0/23"<br>  },<br>  "region": "ap-southeast-1",<br>  "root_bucket_name": "test-workspace-1-rootbucket",<br>  "tags": {<br>    "Env": "test-ws-1",<br>    "Name": "test-workspace-1-tags"<br>  },<br>  "workspace_name": "test-workspace-1"<br>}</pre>  |    no    |
| <a name="input_workspace_2_config"></a> [workspace\_2\_config](#input\_workspace\_2\_config)                            | n/a         | `map`          | <pre>{<br>  "allow_list": [<br>    "65.184.145.97"<br>  ],<br>  "block_list": [<br>    "54.112.179.135",<br>    "195.78.164.130"<br>  ],<br>  "prefix": "ws2",<br>  "private_subnet_pair": {<br>    "subnet1_cidr": "10.109.10.0/23",<br>    "subnet2_cidr": "10.109.12.0/23"<br>  },<br>  "region": "ap-southeast-1",<br>  "root_bucket_name": "test-workspace-2-rootbucket",<br>  "tags": {<br>    "Name": "test-workspace-2-tags"<br>  },<br>  "workspace_name": "test-workspace-2"<br>}</pre> |    no    |
| <a name="input_workspace_vpce_service"></a> [workspace\_vpce\_service](#input\_workspace\_vpce\_service)                | n/a         | `string`       | `"com.amazonaws.vpce.ap-southeast-1.vpce-svc-02535b257fc253ff4"`                                                                                                                                                                                                                                                                                                                                                                                                                                  |    no    |

## Outputs

| Name                                                                                   | Description |
| -------------------------------------------------------------------------------------- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn)                                          | n/a         |
| <a name="output_databricks_hosts"></a> [databricks\_hosts](#output\_databricks\_hosts) | n/a         |
<!-- END_TF_DOCS -->