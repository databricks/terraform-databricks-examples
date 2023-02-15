## Objective
1. Use packer to create azure image that functions as a squid proxy.
2. Use terraform to create vm / vmss, as squid proxy instance(s).
3. Deploy necessary networking infra.
4. Deploy Azure Databricks Workspace with all outbound traffic going through squid proxy, as such, we can achieve granular ACL control for outbound destinations.

## Credits

Credits to andrew.weaver@databricks.com for creating the original instructions to set up squid proxy and shu.wu@databricks.com for efforts in testing and debugging init scripts for databricks cluster proxy setup.

## Overall Architecture:
![alt text](../charts/adb-squid-proxy.png?raw=true)

Narratives: Databricks workspace 1 is deployed into a VNet, which is peered to another VNet hosting a single Squid proxy server, every databricks spark cluster will be configured using init script to direct traffic to this Squid server. We control ACL in squid.conf, such that we can allow/deny traffic to certain outbound destinations.

Does this apply to azure services as well (that goes through azure backbone network)

## Execution Steps:
### Step 1:

This step creates an empty resource group for hosting custom-built squid image and a local file of config variables in `/packer/os`.

Redirect to `/packer/tf_coldstart`, run:
   1. `terraform init`
   2. `terraform apply`

### Step 2:

This step you will use packer to build squid image. Packer will read the auto-generated `*.auto.pkrvars.hcl` file and build the image.

Redirect to `/packer/os`, run:
   1. `packer build .`
   
### Step 3:

This step creates all the other infra for this project, specified in `/main`.

Redirect to `/main`, run:
   1. `terraform init`
   2. `terraform apply`

Now in folder of `/main`, you can find the auto-generated private key for ssh, to ssh into the provisioned vm, run:
`ssh -i ./ssh_private.pem azureuser@52.230.84.169`, change to the public ip of the squid vm accordingly. Check the nsg rules of the squid vm, we have inbound rule 300 allowing any source for ssh, this is for testing purpose only! You do not need ssh on squid vm for production setup. Once you ssh into squid vm, vi /etc/squid/squid.conf and you will find similar content like:

![alt text](../charts/squidconf.png?raw=true)

The content was auto inserted by packer in step 2.

### Step 4:

Open your databricks workspace, you will find a notebook been created in `Shared/` folder, this is the notebook to create the cluster init script.
Create a small vanilla cluster to run this notebook.

### Step 5:
Spin up another cluster using the init script generated in step 4, spark traffic will be routed to the squid proxy.

![alt text](../charts/setproxy.png?raw=true)

### Step 6:

Now all your clusters that spins up using this init script, will route spark/non-spark traffic to the squid proxy and ACL rules in squid.conf will be applied. Example effects are shown below:

![alt text](../charts/http_proxy.png?raw=true)

Traffic to storage accounts will also be allowed / blocked by the proxy. These rules are to be set in `/packer/scripts/setproxy.sh` script.

## Conclusion

We used a single instance of squid proxy server to control granular outbound traffic from Databricks clusters. You can use cluster proxy to enforce the init script, such that all clusters will abide to the init script config and go through the proxy.

## Future Work

To expand to VMSS from current 1 vm setup, with load balancer. For now this project achieves the purpose of granular outbound traffic control, without using a firewall. 