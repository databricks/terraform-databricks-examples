# Hub Networking

Submodule of [`aws-infra`](../../README.md) that implements a hub-and-spoke network topology with centralized egress inspection for Databricks workloads. It creates:

* **Transit Gateway** — an `aws_ec2_transit_gateway` with dedicated hub and spoke route tables, VPC attachments, and routes that steer all spoke egress through the hub VPC.
* **Hub VPC** — an `aws_vpc` with public, private and firewall subnets across the provided availability zones, an internet gateway, NAT gateway and associated route tables.
* **Network Firewall** — an optional `aws_networkfirewall_firewall` with FQDN allow-list, network-level allow rules and a default deny, so outbound traffic from the spoke VPC is inspected and filtered before reaching the internet.

Spoke traffic is routed to the Transit Gateway, into the hub VPC, through the Network Firewall, and out via the NAT/internet gateway — giving a single, centrally controlled egress point.

This is an internal submodule consumed by the `aws-infra` module and is not intended to be deployed standalone. It expects an existing spoke VPC (its ID, CIDR, private subnets and route tables are passed in as variables).

## How to use

This submodule is called by the parent [`aws-infra`](../../README.md) module. To use it directly, pass the spoke VPC details and hub configuration via the variables documented below and provide the `aws` provider.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ec2_transit_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway) | resource |
| [aws_ec2_transit_gateway_route.hub_to_spoke](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.spoke_default_to_hub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route.spoke_to_hub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route_table.hub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table) | resource |
| [aws_ec2_transit_gateway_route_table.spoke](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table) | resource |
| [aws_ec2_transit_gateway_route_table_association.hub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_association.spoke](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_vpc_attachment.hub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment) | resource |
| [aws_ec2_transit_gateway_vpc_attachment.spoke](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment) | resource |
| [aws_eip.hub_nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.hub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.hub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_networkfirewall_firewall.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall) | resource |
| [aws_networkfirewall_firewall_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall_policy) | resource |
| [aws_networkfirewall_rule_group.allow_fqdns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_rule_group.allow_network](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [aws_networkfirewall_rule_group.deny_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |
| [aws_route.hub_public_to_firewall](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.hub_public_to_igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.hub_public_to_spoke](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.private_to_tgw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.hub_firewall](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.hub_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.hub_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.hub_firewall](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.hub_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.hub_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.hub_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.hub_firewall](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.hub_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.hub_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.hub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of availability zones | `list(string)` | n/a | yes |
| <a name="input_hub_vpc_cidr"></a> [hub\_vpc\_cidr](#input\_hub\_vpc\_cidr) | CIDR block for the hub VPC | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for resource names | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | n/a | yes |
| <a name="input_spoke_private_subnet_ids"></a> [spoke\_private\_subnet\_ids](#input\_spoke\_private\_subnet\_ids) | IDs of the spoke VPC private subnets | `list(string)` | n/a | yes |
| <a name="input_spoke_route_table_ids"></a> [spoke\_route\_table\_ids](#input\_spoke\_route\_table\_ids) | IDs of the spoke VPC private route tables | `list(string)` | n/a | yes |
| <a name="input_spoke_vpc_cidr"></a> [spoke\_vpc\_cidr](#input\_spoke\_vpc\_cidr) | CIDR block of the spoke (main) VPC | `string` | n/a | yes |
| <a name="input_spoke_vpc_id"></a> [spoke\_vpc\_id](#input\_spoke\_vpc\_id) | ID of the spoke (main) VPC | `string` | n/a | yes |
| <a name="input_allowed_fqdns"></a> [allowed\_fqdns](#input\_allowed\_fqdns) | List of FQDNs to allow through the firewall | `list(string)` | `[]` | no |
| <a name="input_allowed_network_rules"></a> [allowed\_network\_rules](#input\_allowed\_network\_rules) | List of network-level rules (IP, protocol, port) | <pre>list(object({<br/>    protocol         = string<br/>    source_ip        = string<br/>    destination_ip   = string<br/>    destination_port = string<br/>  }))</pre> | `[]` | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Common tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | Enable DNS support on the Transit Gateway | `bool` | `true` | no |
| <a name="input_enable_firewall"></a> [enable\_firewall](#input\_enable\_firewall) | Enable Network Firewall in the hub VPC | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hub_vpc_id"></a> [hub\_vpc\_id](#output\_hub\_vpc\_id) | ID of the hub VPC |
<!-- END_TF_DOCS -->
