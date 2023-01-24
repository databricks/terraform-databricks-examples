AWS Databricks Unity Catalog - Stage 1
=========================

In this template, we show a simple process to deploy Unity Catalog account level resources and infra into modules and manage your account level resources, metastores, users and groups. For Databricks official terraform samples, please refer to [Databricks Terraform Samples](
https://github.com/databricks/unity-catalog-setup)

## Context

[What is Unity Catalog?](https://docs.databricks.com/data-governance/unity-catalog/index.html)

[Terraform Guide - Set up Unity Catalog on AWS](https://registry.terraform.io/providers/databricks/databricks/latest/docs/guides/unity-catalog)

## Getting Started

AWS Databricks has 2 levels of resources:
1. Account Level (unity metastore, account level users/groups, etc)
2. Workspace Level (workspace level users/groups, workspace objects like clusters)

The 2 levels of resources use different providers configs and have different authentication method, username/password is the only method for account level provider authentication. 

For workspace level provider you can create `n` databricks providers for `n` existing workspaces, each provider to be authenticate via PAT token.

We propose 2-stage process to get onboarded to UC. Starting at the point where you only have `account owner`, and this identity will also be the first `account admin`. Account admins can add/remove other `account admin`.

We recommend using `account admin` identities to deploy unity catalog related resources.

> In stage 1, you use `account owner` to create `account admins`, this can be done in either method below:
> 1. Use this folder, authenticate the `mws` provider with `account owner`, and supply `account admin` in `terraform.tfvars`, do not put `account owner` into the admin list since we do not want terraform to manage `account owner`.
> 2. You can manually create `account admin` on [account console](accounts.cloud.databricks.com) UI. 
>
> In stage 2, you use the newly created account admin identity to authenticate the `databricks mws` provider, and create the unity catalog related resources, using example scripts in `aws_databricks_unity_catalog`.

Refer to below diagram on the process.

<img src="../charts/uc_tf_onboarding.png" width="1000">

## How to fill `terraform.tfvars`

databricks_users          = [] (you can leave this as empty list)

databricks_account_admins = ["hao.wang@databricks.com"] (do not put account owner in this list, add emails of the account admins)

unity_admin_group         = " Bootstrap admin group" (this is the display name of the admin group)

## Expected Outcome

After running this template using `terraform init` and `terraform apply` with your provided list of account admins, you should see account admins' emails under the newly created group, thus you have successfully onboarded account admins identity to your Databricks Account. 

<img src="../charts/uc_tf_account_admin.png" width="500">

Now you can proceed to stage 2, navigate to [aws_databricks_unity_catalog](https://github.com/hwang-db/tf_aws_deployment/tree/main/aws_databricks_unity_catalog) for stage 2 deployments.
