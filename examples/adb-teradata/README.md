## ADB - Teradata Demo environment

This example template automatically provisions a demo envirionment of single node Teradata Vantage express and Azure Databricks workspace. Major components to deploy include:
- 1 Vnet with 3 subnets (2 for Databricks, 1 for Teradata VM)
- 1 Azure VM (hosting Teradata Vantage Express)
- 1 VNet injected Azure Databricks Workspace
- NSGs

For setting up the VM hosting Teradata Vantage Express, we will follow the official installation guide: https://quickstarts.teradata.com/run-vantage-express-on-microsoft-azure.html; this readme provides more details in each step.

## Folder Structure
    .
    ├── main.tf
    ├── outputs.tf
    ├── data.tf
    ├── providers.tf
    ├── variables.tf
    ├── vnet.tf
    ├── workspace.tf
    ├── terraform.tfvars
    ├── images
    ├── modules
        ├── teradata_vm
            ├── main.tf
            ├── outputs.tf      
            ├── providers.tf
            ├── variables.tf

`terraform.tfvars` is provided as reference variable values, you should change it to your need.

## Getting Started

> Step 1: Preparation

Clone this repo to your local, and run `az login` to interactively login and authenticate with `azurerm` provider.

> Step 2: Deploy resources

Change the `terraform.tfvars` to your need, then run:
```bash
terraform init
terraform apply
```
This will deploy all resources wrapped in a new resource group to your the default subscription of your `az login` profile; you will see the public ip address of the VM hosting Teradata Vantage Express after the deployment is done. After deployment, you will get below resources:

![alt text](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/examples/adb-teradata/images/resources.png?raw=true)

> Step 3: Configure Teradata Vantage Express VM

The VM's private key has been generated for you in local folder; replace the public ip accordingly. SSH into Teradata VM by:
```bash
ssh -i <private_key_local_path> azureuser@<public_ip>
```

Inside the VM, we should run the commands stored inside `teradata_vm_configs.sh` step by step. 

**Note that you need to modify two commands manually to make it work:**

**The first place to modify:**

```bash
curl -o ve.7z 'https://d289lrf5tw1zls.cloudfront.net/database/teradata-express/VantageExpress17.20_Sles12_20220819081111.7z?Expires=1673417382&Signature=tiXioXzo0wg53m6ELyXenLwOeWPZFeYV4rAZIM3qw886SkkK67Pb8mHCr~jHza7FTrMfeZXTXtnis4x7WEbXsmQCfkRo2~zv97n9oE1kDiOVYRt7b61xORtPJPyVKMUs4mbebgJEl8gOAO-wqIWSmBs~mA4wZyb2X63dHcE70R2wyFHwwiiZzlcC-bb7wYuZe0emT4aTeGW6ndXXEKvGSK~OCIXx5uLNqboRAaIS0BksEOl8HjP6iYurue~kNkIGtlG3rW~XtBkfvL7hpTPG7RF1z7zvG1XXtMyxMfLXu-lt4JnCl4jodjGD8iszh6LZ28TubyIXz1y9kBYF-aq3mQ__&Key-Pair-Id=xxxxxxxx'
```

This is the cURL command to download Teradata Vantage Express from Teradata website. You can get the URL from here https://downloads.teradata.com/download/database/teradata-express/vmware; register an account and download the VM; when you clicked the download button, press `F12` to open your browser's network flow, find the latest entry started with VantageExpress, right click and copy the cURL; trim off the Http header and update the command above.

![alt text](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/examples/adb-teradata/images/cURL.png?raw=true)

**The second place to check/modify:**

`export VM_IMAGE_DIR="/opt/downloads/VantageExpress17.20_Sles12"`

Make sure you change the value to the version of VantageExpress you downloaded. If you've successfully run all the set up commands inside `teradata_vm_configs.sh`, you are now ready to SSH into your vmbox. 

> Step 4: SSH into Teradata Vantage Express VMBox and write bteq

Inside your Azure VM, now we have created vmbox (that's your Teradata Vantage Express VM) and we can ssh into it by:

```bash
ssh -p 4422 root@localhost
```
Password is `root`; and then run
```bash
pdestate -a
```
to check the TD service is up and running; if successful you should see below:

![alt text](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/examples/adb-teradata/images/validate-td-running.png?raw=true)

Next, we can use bteq to create databases and tables. Run:
```bash
bteq
```
then enter
`.logon localhost/dbc`
then enter `dbc`.
Now you are able to create databases / tables in TD; for example:

```sql
CREATE DATABASE HR
AS PERMANENT = 60e6,
    SPOOL = 120e6;
```

```sql
CREATE SET TABLE HR.Employees (
   GlobalID INTEGER,
   FirstName VARCHAR(30),
   LastName VARCHAR(30),
   DateOfBirth DATE FORMAT 'YYYY-MM-DD',
   JoinedDate DATE FORMAT 'YYYY-MM-DD',
   DepartmentCode BYTEINT
)
UNIQUE PRIMARY INDEX ( GlobalID );
```

```sql
INSERT INTO HR.Employees (
   GlobalID,
   FirstName,
   LastName,
   DateOfBirth,
   JoinedDate,
   DepartmentCode
)
VALUES (
   101,
   'Adam',
   'Tworkowski',
   '1980-01-05',
   '2004-08-01',
   01
);
```

Then you can query this table inside bteq:
```sql
SELECT * FROM HR.Employees;
```

![alt text](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/examples/adb-teradata/images/td-vm-bteq.png?raw=true)

> Step 5: Automatically spin up Teradata when Azure VM starts

Refer to [official guide](https://quickstarts.teradata.com/run-vantage-express-on-microsoft-azure.html#_optional_setup) to set up.

> Step 6: Integration with Azure Databricks

Now your Teradata VM is running; let's set up the Databricks cluster to connect to it. First we need to download TD JDBC driver from https://downloads.teradata.com/download/connectivity/jdbc-driver. Then upload the driver to your workspace dbfs.

![alt text](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/examples/adb-teradata/images/upload-driver.png?raw=true)

Then create a cluster with the uploaded jdbc driver installed.

![alt text](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/examples/adb-teradata/images/cluster.png?raw=true)

Then follow the notebook examples, to connect to your TD VM public IP, below shows how to read from Databricks to TD tables:

![alt text](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/examples/adb-teradata/images/adb-connection.png?raw=true)

For a full integration example, you can upload the notebooks under `artifacts` from this repo to your workspace.

### Common issues:

1. `kex_exchange_identification: read: Connection reset by peer`: you need to wait for the vmbox to start, try again in a few minutes.
2. `vt-x is not available (verr_vmx_no_vmx)`: This is because you've altered the VM size and chose a size that's incompatible with gen2 image. You should choose VM that supports: `Nested Virtualization: Supported`. Please refer to: https://learn.microsoft.com/en-us/azure/virtual-machines/generation-2 for compatibility. As we are doing SSH twice, you need nested Virtualization.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.12.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.4 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.4.5 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_test_vm_instance"></a> [test\_vm\_instance](#module\_test\_vm\_instance) | ./modules/teradata_vm | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_databricks_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/databricks_workspace) | resource |
| [azurerm_network_security_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.vmnsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.teradatasubnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_network_security_group_association.private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_network_security_group_association.public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [random_string.naming](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [external_external.me](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [http_http.my_public_ip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dbfs_prefix"></a> [dbfs\_prefix](#input\_dbfs\_prefix) | n/a | `string` | n/a | yes |
| <a name="input_rglocation"></a> [rglocation](#input\_rglocation) | n/a | `string` | n/a | yes |
| <a name="input_spokecidr"></a> [spokecidr](#input\_spokecidr) | n/a | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Azure Subscription ID to deploy the workspace into | `string` | n/a | yes |
| <a name="input_workspace_prefix"></a> [workspace\_prefix](#input\_workspace\_prefix) | n/a | `string` | n/a | yes |
| <a name="input_cidr"></a> [cidr](#input\_cidr) | n/a | `string` | `"10.179.0.0/20"` | no |
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | Set to true to create a new Azure Resource Group. Set to false to use an existing Resource Group specified in existing\_resource\_group\_name | `bool` | `true` | no |
| <a name="input_existing_resource_group_name"></a> [existing\_resource\_group\_name](#input\_existing\_resource\_group\_name) | Specify the name of an existing Resource Group only if you do not want Terraform to create a new one | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azure_resource_group_id"></a> [azure\_resource\_group\_id](#output\_azure\_resource\_group\_id) | ID of the created Azure resource group |
| <a name="output_pip"></a> [pip](#output\_pip) | n/a |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | The Databricks workspace ID |
| <a name="output_workspace_url"></a> [workspace\_url](#output\_workspace\_url) | The Databricks workspace URL |
<!-- END_TF_DOCS -->