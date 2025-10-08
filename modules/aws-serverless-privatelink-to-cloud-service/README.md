# Module aws-serverless-privatelink-to-cloud-service

## Description

This module creates a PrivateLink connection for Databricks Serverless compute to reach AWS native services (e.g. Lambda, Secrets Manager, Kinesis) securely and privately.

> **Note**
> This architecture should not be used for S3. Databricks Serverless uses a Gateway type VPC Endpoint by default so S3 requests do not go over public Internet. If you would like to use PrivateLink for a dedicated connection, see [Configure private connectivity to AWS S3 storage buckets](https://docs.databricks.com/aws/en/security/network/serverless-network-security/pl-aws-resources) for a more direct and cost-effective method than this module.
> 
> Enabling Private link on AWS requires Databricks "Enterprise" tier which is configured at the Databricks account level.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.10 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | ~> 1.84 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.10 |
| <a name="provider_databricks.mws"></a> [databricks.mws](#provider\_databricks.mws) | ~> 1.84 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_endpoint.aws_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint_service.private_link_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_service) | resource |
| [aws_vpc_endpoint_service_allowed_principal.databricks_access_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_service_allowed_principal) | resource |
| [databricks_mws_ncc_private_endpoint_rule.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_ncc_private_endpoint_rule) | resource |
| [aws_network_interface.aws_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/network_interface) | data source |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_service"></a> [aws\_service](#input\_aws\_service) | The AWS service to connect to (e.g. secretsmanager, lambda, etc.) | `string` | n/a | yes |
| <a name="input_network_connectivity_config_id"></a> [network\_connectivity\_config\_id](#input\_network\_connectivity\_config\_id) | The network connectivity config ID to use for the resources | `string` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | The private subnet IDs to use for the resources | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `string` | n/a | yes |
| <a name="input_allowed_ingress_cidr_blocks"></a> [allowed\_ingress\_cidr\_blocks](#input\_allowed\_ingress\_cidr\_blocks) | The CIDR blocks to allow inbound traffic from. If empty, the VPC's CIDR block will be used. | `list(string)` | `[]` | no |
| <a name="input_allowed_ingress_security_groups"></a> [allowed\_ingress\_security\_groups](#input\_allowed\_ingress\_security\_groups) | The security groups to allow inbound traffic from | `set(string)` | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix to use for the resources | `string` | `"pl-demo"` | no |
| <a name="input_private_dns_name"></a> [private\_dns\_name](#input\_private\_dns\_name) | The private DNS name to use for the resources | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | The region of the cloud service | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nlb_arn"></a> [nlb\_arn](#output\_nlb\_arn) | The ARN of the NLB |
| <a name="output_vpc_endpoint_id"></a> [vpc\_endpoint\_id](#output\_vpc\_endpoint\_id) | ID of the VPCE created by Databricks |
| <a name="output_vpce_ips"></a> [vpce\_ips](#output\_vpce\_ips) | Private IP addresses of the VPCE ENI; useful if you are using this for an NLB target group. |
| <a name="output_vpce_sg_id"></a> [vpce\_sg\_id](#output\_vpce\_sg\_id) | Security Group ID of the VPCE |
<!-- END_TF_DOCS -->