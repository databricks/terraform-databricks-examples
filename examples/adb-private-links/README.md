# Azure Databricks with Private Links and Hub-Spoke Firewall structure (data exfiltration protection).

Include:
1. Hub-Spoke networking with egress firewall to control all outbound traffic, e.g. to pypi.org.
2. Private Link connection for backend traffic from data plane to control plane.
3. Private Link connection from user client to webapp service.
4. Private Link connection from data plane to dbfs storage.

Overall Architecture:
![alt text](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/examples/adb-private-links/images/adb-private-links.png?raw=true)

With this deployment, traffic from user client to webapp (notebook UI), backend traffic from data plane to control plane will be through private endpoints. This terraform sample will create:
* Resource group with random prefix
* Tags, including `Owner`, which is taken from `az account show --query user`
* VNet with public and private subnet and subnet to host private endpoints
* Databricks workspace with private link to control plane, user to webapp and private link to dbfs


## Getting Started
1. Clone this repo to your local machine.
2. Run `terraform init` to initialize terraform and get provider ready.
3. Change `terraform.tfvars` values to your own values.
4. Inside the local project folder, run `terraform apply` to create the resources.

## Inputs

| Name             | Description | Type        | Default         | Required |
| ---------------- | ----------- | ----------- | --------------- | :------: |
| hubcidr          | n/a         | `string`    | "10.178.0.0/20" |   yes    |
| spokecidr        | n/a         | `string`    | "10.179.0.0/20" |   yes    |
| no\_public\_ip   | n/a         | `bool`      | `true`          |   yes    |
| rglocation       | n/a         | `string`    | "southeastasia" |   yes    |
| metastoreip      | n/a         | `string`    | "40.78.233.2"   |   yes    |
| dbfs_prefix      | n/a         | `string`    | "dbfs"          |   yes    |
| workspace_prefix | n/a         | `string`    | "adb"           |   yes    |
| firewallfqdn     | n/a         | list(`any`) | fqdn rules      |   yes    |


## Outputs

| Name                                       | Description |
| ------------------------------------------ | ----------- |
| arm\_client\_id                            | n/a         |
| arm\_subscription\_id                      | n/a         |
| arm\_tenant\_id                            | n/a         |
| azure\_region                              | n/a         |
| databricks\_azure\_workspace\_resource\_id | n/a         |
| resource\_group                            | n/a         |
| workspace\_url                             | n/a         |
