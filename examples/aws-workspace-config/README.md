AWS Databricks workspace management using Terraform
=========================

This template shows how to use terraform to manage workspace configurations and objects (like clusters, policies etc). We attempt to balance between configuration code complexity and flexibility. The goal is to provide a simple way to manage workspace configurations and objects, while allowing for maximum customization and governance. We assume you have already deployed workspace, if not, you can refer to the parallel folder `aws_databricks_modular_privatelink`. 


Specifically, you can find examples here for:
1. [Provider configurations for multiple workspaces](https://github.com/hwang-db/tf_aws_deployment/tree/main/aws_workspace_config#provider-configurations-for-multiple-workspaces)
2. [Configure IP Access List for multiple workspaces](https://github.com/hwang-db/tf_aws_deployment/tree/main/aws_workspace_config#configure-ip-access-list-for-multiple-workspaces)
3. [Workspace Object Management](https://github.com/hwang-db/tf_aws_deployment/tree/main/aws_workspace_config#workspace-object-management)
4. [Cluster Policy Management](https://github.com/hwang-db/tf_aws_deployment/tree/main/aws_workspace_config#cluster-policy-management)
5. [Workspace users and groups](https://github.com/hwang-db/tf_aws_deployment/tree/main/aws_workspace_config#workspace-users-and-groups)

## Provider configurations for multiple workspaces

If you want to manage multiple databricks workspaces using the same terraform project (folder), you must specify different provider configurations for each workspace. Examples can be found in `providers.tf`.
When you spin up resources/modules, you need to explicitly pass in the provider information for each instance of module, such that terraform knows which workspace host to deploy the resources into; read this tutorial for details: https://www.terraform.io/language/modules/develop/providers

## Configure IP Access List for multiple workspaces

In this example, we show how to patch multiple workspaces using multiple json files as input; the json file contains block lists and allow lists for each workspace and we use the exact json files generated in workspace deployment template inside this repo, see this [[link](https://github.com/hwang-db/tf_aws_deployment/tree/main/aws_databricks_modular_privatelink#ip-access-list)] for more details.

Assume you have deployed 2 workspaces using the `aws_databricks_modular_privatelink` template, you will find 2 generated json file under `../aws_databricks_modular_privatelink/artifacts/`, and you want to patch the IP access list for both workspaces. You can refer to `main.tf` and continue to add/remove the module instances you want. For each workspace, we recommend you using a dedicated block for configuration, like the one below:

```hcl
module "ip_access_list_workspace_1" {
  providers = {
    databricks = databricks.ws1 // manually adding each workspace's module
  }

  source              = "./modules/ip_access_list"
  allow_list          = local.allow_lists_map.workspace_1
  block_list          = local.block_lists_map.workspace_1
  allow_list_label    = "Allow List for workspace_1"
  deny_list_label     = "Deny List for workspace_1"
}
```

Note that we also passed in the labels, this is to prevent strange errors when destroying IP Access Lists. This setup has been tested to work well for arbitrary re-patch / destroy of IP Access lists for multiple workspaces.

About the Host Machine's IP - in the generated json file, we had automatically added the host (the machine that runs this terraform script) public IP into the allow list (this is required by the IP access list feature).

## Workspace Object Management

We show how to create cluster from terraform `clusters.tf`. You can also create other objects like jobs, policies, permissions, users, groups etc.

## Cluster Policy Management

We show a base policy module under `modules/base_policy`, using this you can supply with your custom rules into the policy, assign the permission to use the policy to different groups.

Within the json definition of policy you can do things like tag enforcement, read this for details: [Tagging from cluster policy](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/cluster_policy)

By defining in the cluster policy json like below, you can enforce default tags from policy:

    "custom_tags.Team" : {
      "type" : "fixed",
      "value" : var.team
    }

<img src="../charts/tf_tagging.png" width="600">

Ordinary (non-admin) users, by default will not be able to create unrestricted clusters; if allowed to create clusters, they will only be able to use the policies assigned to them to spin up clusters, thus you can have strict control over the cluster configurations among different groups. See below for and example of ordinary user created via terraform.

The process will be: provision ordinary users -> assign users to groups -> assign groups to have permissions to use specific policies only -> the groups can only create clusters using assigned policies.

<img src="../charts/user_policy.png" width="1200">

## Workspace users and groups

You can manage users/groups inside terraform. Examples were given in `main.tf`. Note that with Unity Catalog, you can have account level users/groups. The example here is at workspace level.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name                                                                               | Version |
| ---------------------------------------------------------------------------------- | ------- |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks)             | 1.3.1   |
| <a name="provider_databricks.ws1"></a> [databricks.ws1](#provider\_databricks.ws1) | 1.3.1   |

## Modules

| Name                                                                                                                       | Source                   | Version |
| -------------------------------------------------------------------------------------------------------------------------- | ------------------------ | ------- |
| <a name="module_engineering_compute_policy"></a> [engineering\_compute\_policy](#module\_engineering\_compute\_policy)     | ./modules/base_policy    | n/a     |
| <a name="module_ip_access_list_workspace_1"></a> [ip\_access\_list\_workspace\_1](#module\_ip\_access\_list\_workspace\_1) | ./modules/ip_access_list | n/a     |
| <a name="module_ip_access_list_workspace_2"></a> [ip\_access\_list\_workspace\_2](#module\_ip\_access\_list\_workspace\_2) | ./modules/ip_access_list | n/a     |

## Resources

| Name                                                                                                                                        | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [databricks_cluster.tiny](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/cluster)                      | resource    |
| [databricks_group.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/group)                          | resource    |
| [databricks_group_member.vip_member](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/group_member)      | resource    |
| [databricks_user.user2](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/user)                           | resource    |
| [databricks_spark_version.latest_lts](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/spark_version) | data source |
| [databricks_user.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/user)                         | data source |

## Inputs

| Name                                                           | Description | Type     | Default | Required |
| -------------------------------------------------------------- | ----------- | -------- | ------- | :------: |
| <a name="input_pat_ws_1"></a> [pat\_ws\_1](#input\_pat\_ws\_1) | n/a         | `string` | n/a     |   yes    |
| <a name="input_pat_ws_2"></a> [pat\_ws\_2](#input\_pat\_ws\_2) | n/a         | `string` | n/a     |   yes    |

## Outputs

| Name                                                                                                            | Description |
| --------------------------------------------------------------------------------------------------------------- | ----------- |
| <a name="output_all_allow_lists_patched"></a> [all\_allow\_lists\_patched](#output\_all\_allow\_lists\_patched) | n/a         |
| <a name="output_all_block_lists_patched"></a> [all\_block\_lists\_patched](#output\_all\_block\_lists\_patched) | n/a         |
| <a name="output_sample_cluster_id"></a> [sample\_cluster\_id](#output\_sample\_cluster\_id)                     | n/a         |
<!-- END_TF_DOCS -->