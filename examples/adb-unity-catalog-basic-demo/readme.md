# Azure Databricks Unity Catalog Implementation

This Terraform project is deploying all the resources needed to properly setup unity catalog for azure databricks governance. We are essentially deploying all the resources shown in the diagram below:

![UC Image](uc.png)


## Run the following terraform commands to deploy (in the order)
1. `terraform init`
2. `terraform validate`
3. `terraform apply -target=module.metastore_and_users`
4. `terraform apply`

_Note:_ We need to run terraform apply into 2 part here because to add users to their group membership, will need to dynamically pull the members of each group into a for_each loop and recent version of Terraform don't allow to use values derived from resource attributes that cannot be determined until apply. Therefore as a work-around we just run the target module (metastore_and_users) to first deploy metastore, users and groups and then we run a separate terraform apply to deploy remaining resource including the user to group membership. With a CI/CD in place we can automate these commands in required order. 