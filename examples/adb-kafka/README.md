## ADB - Kafka Single VM Demo environment

This template provisions a single VM and Azure Databricks workspace, installation of Kafka service is a manual step. Major components to deploy include:
- 1 Vnet with 3 subnets (2 for Databricks, 1 for Kafka VM)
- 1 Azure VM (to host Kafka and Zookeeper services), with port 9092 exposed to other devices in same VNet (allowed by default NSG rules).
- 1 VNet injected Azure Databricks Workspace
- NSGs for Databricks and Kafka subnets

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
        ├── general_vm
            ├── main.tf
            ├── outputs.tf      
            ├── providers.tf
            ├── variables.tf

`terraform.tfvars` is provided as reference variable values, you should change it based on your need.

## Getting Started

> Step 1: Preparation

Clone this repo to your local, and run `az login` to interactively login thus get authenticated with `azurerm` provider.

> Step 2: Deploy resources

Change the `terraform.tfvars` to your need (you can also leave as default values as a random string will be generated in prefix), then run:
```bash
terraform init
terraform apply
```
This will deploy all resources wrapped in a new resource group to your the default subscription of your `az login` profile; you will see the public ip address of the VM after the deployment is done. After deployment, you will get below resources:

![alt text](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/examples/adb-kafka/images/resources.png?raw=true)


> Step 3: Configure your VM to run Kafka and Zookeeper services

At this moment, you have a vanilla VM without any bootstraping performed. We are to manually log into the VM and install Kafka and Zookeeper services.

The VM's private key has been generated for you in local folder; replace the public ip accordingly. SSH into VM by (azureuser is the hardcoded username for VMs in this template):

```bash
ssh -i <private_key_local_path> azureuser@<public_ip>
```

Now you should follow this [guide from DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-install-apache-kafka-on-ubuntu-20-04) to install Kafka on the VM. Note that a few commands need to be updated:
1. When downloading the kafka binary, go to https://kafka.apache.org/downloads.html and copy the latest binary link and replace it here:
```bash
curl "https://downloads.apache.org/kafka/3.3.2/kafka_2.12-3.3.2.tgz" -o ~/Downloads/kafka.tgz
```

![alt text](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/examples/adb-kafka/images/kafka-download.png?raw=true)

1. When testing your Kafka installation, --zookeeper is deprecated, use --bootstrap-server instead:
   
```bash
~/kafka/bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic TutorialTopic
```

At the end of the guide, you should have a running Kafka service on your VM. You can test it by running the following command:
```bash
sudo systemctl status kafka
```

![alt text](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/examples/adb-kafka/images/test-kafka.png?raw=true)

> Step 4: Integration with Azure Databricks

Now your Kafka Broker is running; let's connect to it in Databricks. 
We first create a topic `TutorialTopic2` in Kafka via your VM's Command Line:

```bash
~/kafka/bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic TutorialTopic2
```

Then we can write from Spark DataFrame to this topic; you can also test the connection by `telnet vm-private-ip 9092` first.

![alt text](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/examples/adb-kafka/images/write-to-kafka.png?raw=true)

Read from this topic in another stream job:

![alt text](https://raw.githubusercontent.com/databricks/terraform-databricks-examples/main/examples/adb-kafka/images/read-kafka.png?raw=true)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=4.0.0 |
| <a name="provider_external"></a> [external](#provider\_external) | n/a |
| <a name="provider_http"></a> [http](#provider\_http) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kafka_broker"></a> [kafka\_broker](#module\_kafka\_broker) | ./modules/general_vm | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_databricks_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/databricks_workspace) | resource |
| [azurerm_network_security_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_group.vmnsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.vm_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_network_security_group_association.private](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_network_security_group_association.public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [random_string.naming](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [external_external.me](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [http_http.ipinfo](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

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
| <a name="output_azure_resource_group_id"></a> [azure\_resource\_group\_id](#output\_azure\_resource\_group\_id) | The Azure resource group ID |
| <a name="output_pip"></a> [pip](#output\_pip) | Public IP of the Kafka broker |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | The Databricks workspace ID |
| <a name="output_workspace_url"></a> [workspace\_url](#output\_workspace\_url) | The Databricks workspace URL |
<!-- END_TF_DOCS -->
