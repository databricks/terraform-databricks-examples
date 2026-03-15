# AWS Infrastructure Module for Databricks

A comprehensive, production-ready AWS infrastructure module that provides all necessary resources for Databricks workloads using official AWS Terraform modules and best practices.

## Overview

This module creates a complete AWS infrastructure foundation optimized for Databricks, featuring:

- **🔧 Simplified Configuration**: Uses official `terraform-aws-modules/vpc` for networking
- **🔒 Secure Storage**: S3 buckets with configurable encryption (SSE-S3 default, or SSE-KMS with your own key)
- **👤 IAM Integration**: Cross-account and Unity Catalog roles with Databricks-generated policies; cross-account policy type is configurable (`managed`, `restricted`, or `customer-managed`)
- **🔗 VPC Endpoints**: Private access to AWS services (S3, STS, Kinesis)
- **🛡️ Network Firewall**: Configurable FQDN and network-based filtering (optional)
- **🌐 Hub-Spoke Architecture**: Transit Gateway with centralized internet egress (optional)
- **🔐 Private Link**: Databricks Private Link endpoints (optional)

## Architecture

### Basic Architecture

```
┌─────────────────────────────────────────────┐
│  VPC (10.0.0.0/16)                         │
│                                             │
│  ┌──────────────┐  ┌──────────────┐       │
│  │ Private Sub  │  │ Private Sub  │       │
│  │ (AZ-a)       │  │ (AZ-b)       │       │
│  │ Databricks   │  │ Databricks   │       │
│  └──────┬───────┘  └──────┬───────┘       │
│         │                  │                │
│         └─────────┬────────┘                │
│                   │                         │
│         ┌─────────▼─────────┐              │
│         │   NAT Gateway     │              │
│         │  (Public Subnet)  │              │
│         └─────────┬─────────┘              │
│                   │                         │
│         ┌─────────▼─────────┐              │
│         │ Internet Gateway  │              │
│         └───────────────────┘              │
└─────────────────────────────────────────────┘
            │
            ▼
        Internet
```

### Hub-Spoke Architecture with Firewall

```
┌──────────────────────────────────────────────────┐
│  Spoke VPC (Databricks - 10.0.0.0/16)          │
│  Private Subnets                                 │
└────────────────┬─────────────────────────────────┘
                 │ Transit Gateway
                 ▼
┌──────────────────────────────────────────────────┐
│  Hub VPC (10.1.0.0/16)                          │
│                                                  │
│  Private Subnet → Network Firewall → NAT → IGW │
│  (TGW attach)     (Inspection)                  │
└──────────────────────────────────────────────────┘
                 │
                 ▼
             Internet
```

## Module Components

### Core Components (Always Created)
- **networking.tf** - VPC, subnets, security groups, NAT gateway (via AWS VPC module). When hub-spoke is enabled, NAT is automatically disabled in the spoke — the hub VPC handles all egress.
- **workspacestorage.tf** - Root S3 bucket for Databricks workspace
- **ucstorage.tf** - Unity Catalog S3 buckets (metastore & data)
- **iam.tf** - IAM roles (cross-account, Unity Catalog, optional instance profiles)
- **vpc-endpoints.tf** - VPC endpoints (S3, STS, Kinesis) via AWS module

### Conditional Components
- **private-link.tf** - Databricks Private Link (when `enable_private_link = true`)

### Submodules
- **modules/hub-networking/** - Transit Gateway, Hub VPC, and Network Firewall (when `hub_spoke_architecture = true`)

## Usage Examples

### Minimal Configuration

```hcl
module "databricks_infra" {
  source = "./modules/aws/aws-infra"
  
  prefix = "my-databricks"
  region = "us-west-2"
  
  networking = {
    vpc_cidr           = "10.0.0.0/16"
    availability_zones = ["us-west-2a", "us-west-2b"]
    enable_nat_gateway = true
  }
  
  databricks_account_id = "414351767826"  # Databricks AWS account
  
  tags = {
    Environment = "production"
  }
}
```

### With Hub-Spoke and Network Firewall

```hcl
module "databricks_infra" {
  source = "./modules/aws/aws-infra"
  
  prefix = "my-databricks"
  region = "us-west-2"
  
  networking = {
    vpc_cidr           = "10.0.0.0/16"
    availability_zones = ["us-west-2a", "us-west-2b"]
    enable_nat_gateway = true
  }
  
  databricks_account_id = "414351767826"
  
  # Hub-Spoke Architecture with Firewall
  advanced_networking = {
    hub_spoke_architecture = true
    enable_transit_gateway = true
    hub_vpc_cidr           = "10.1.0.0/16"
  }
  
  # Network Firewall Configuration
  security = {
    enable_network_firewall = true
    
    # Allow specific domains
    # Note: AWS Network Firewall uses leading-dot format for subdomain matching
    allowed_fqdns = [
      ".cloud.databricks.com",
      ".s3.us-west-2.amazonaws.com",
      ".pypi.org",
      "files.pythonhosted.org",
      "github.com"
    ]
    
    # Allow specific network rules
    allowed_network_rules = [
      {
        protocol         = "TCP"
        source_ip        = "$HOME_NET"
        destination_ip   = "ANY"
        destination_port = "443"
      },
      {
        protocol         = "UDP"
        source_ip        = "$HOME_NET"
        destination_ip   = "ANY"
        destination_port = "53"
      }
    ]
  }
  
  tags = {
    Environment = "production"
  }
}
```

### With Private Link

```hcl
module "databricks_infra" {
  source = "./modules/aws/aws-infra"
  
  prefix = "my-databricks"
  region = "us-west-2"
  
  networking = {
    vpc_cidr           = "10.0.0.0/16"
    availability_zones = ["us-west-2a", "us-west-2b"]
    enable_nat_gateway = false  # Not needed with Private Link
  }
  
  databricks_account_id = "414351767826"
  
  # Private Link Configuration
  security = {
    enable_private_link     = true
    backend_service_name    = "com.amazonaws.vpce.us-west-2.vpce-svc-0158114c0c730c3bb"
    relay_service_name      = "com.amazonaws.vpce.us-west-2.vpce-svc-0dc0e98e4e8a7d1f9"
  }
  
  tags = {
    Environment = "production"
  }
}
```

### With Unity Catalog

```hcl
module "databricks_infra" {
  source = "./modules/aws/aws-infra"
  
  prefix = "my-databricks"
  region = "us-west-2"
  
  networking = {
    vpc_cidr           = "10.0.0.0/16"
    availability_zones = ["us-west-2a", "us-west-2b"]
    enable_nat_gateway = true
  }
  
  databricks_account_id = "414351767826"
  
  # Unity Catalog Configuration
  create_metastore_bucket     = true
  unity_catalog_account_id    = "414351767826"
  external_id                 = "12345678-1234-1234-1234-123456789abc"
  
  tags = {
    Environment = "production"
  }
}
```

> **Note**: The inputs/outputs table below is generated by [terraform-docs](https://terraform-docs.io/) via `.terraform-docs.yml`. Run `terraform-docs .` from this directory to regenerate it after variable changes.

<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_advanced_networking"></a> [advanced\_networking](#input\_advanced\_networking) | Advanced networking features | <pre>object({<br/>    # Transit Gateway<br/>    enable_transit_gateway = optional(bool, false)<br/>    hub_spoke_architecture = optional(bool, false)<br/><br/>    # Hub VPC configuration (when hub-spoke enabled)<br/>    hub_vpc_cidr = optional(string, "10.1.0.0/16")<br/><br/>    # Additional VPC attachments<br/>    additional_vpc_attachments = optional(list(object({<br/>      vpc_id     = string<br/>      vpc_cidr   = string<br/>      route_cidr = string<br/>      subnet_ids = list(string)<br/>    })), [])<br/><br/>    # Routing configuration<br/>    propagate_default_routes = optional(bool, false)<br/>    enable_dns_support       = optional(bool, true)<br/>  })</pre> | `{}` | no |
| <a name="input_create_instance_profiles"></a> [create\_instance\_profiles](#input\_create\_instance\_profiles) | Create IAM instance profiles for Databricks clusters | `bool` | `false` | no |
| <a name="input_create_metastore_bucket"></a> [create\_metastore\_bucket](#input\_create\_metastore\_bucket) | Create Unity Catalog metastore bucket | `bool` | `false` | no |
| <a name="input_cross_account_policy_type"></a> [cross\_account\_policy\_type](#input\_cross\_account\_policy\_type) | Databricks cross-account IAM policy type. Options: 'managed' (default AWS-managed policy), 'restricted' (least-privilege), 'customer-managed' (customer-managed VPC) | `string` | `"managed"` | no |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | Databricks Account ID (UUID). Found at accounts.cloud.databricks.com → top-right menu. Used to scope the cross-account IAM role trust policy to your Databricks account only. | `string` | n/a | yes |
| <a name="input_databricks_config"></a> [databricks\_config](#input\_databricks\_config) | Databricks-specific configuration for policy generation | <pre>object({<br/>    account_id = optional(string, null)<br/>    # This helps generate proper Databricks policies but doesn't create Databricks resources<br/>  })</pre> | `{}` | no |
| <a name="input_external_id"></a> [external\_id](#input\_external\_id) | External ID for Unity Catalog IAM role trust relationship. When null, a basic trust policy (no ExternalId condition) is used. Set and re-apply once available. | `string` | `null` | no |
| <a name="input_networking"></a> [networking](#input\_networking) | VPC and networking configuration | <pre>object({<br/>    vpc_cidr             = string<br/>    availability_zones   = optional(list(string), [])<br/>    enable_nat_gateway   = optional(bool, true)<br/>    private_subnet_cidrs = optional(list(string), [])<br/>    public_subnet_cidrs  = optional(list(string), [])<br/>  })</pre> | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for all AWS resources | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region for resource deployment | `string` | n/a | yes |
| <a name="input_roles_to_assume"></a> [roles\_to\_assume](#input\_roles\_to\_assume) | Additional IAM role ARNs that the cross-account role should be able to assume | `list(string)` | `[]` | no |
| <a name="input_security"></a> [security](#input\_security) | Advanced security configuration | <pre>object({<br/>    # Firewall configuration<br/>    enable_network_firewall = optional(bool, false)<br/>    allowed_fqdns = optional(list(string), [])<br/>    allowed_network_rules = optional(list(object({<br/>      protocol         = string<br/>      source_ip        = string<br/>      destination_ip   = string<br/>      destination_port = string<br/>    })), [])<br/><br/>    # Private Link configuration<br/>    enable_private_link     = optional(bool, false)<br/>    backend_service_name    = optional(string, null)<br/>    relay_service_name      = optional(string, null)<br/>  })</pre> | `{}` | no |
| <a name="input_storage_encryption"></a> [storage\_encryption](#input\_storage\_encryption) | S3 bucket encryption configuration. Use 'SSE-S3' for AWS-managed keys or 'SSE-KMS' for KMS-managed keys. | <pre>object({<br/>    type       = optional(string, "SSE-S3")<br/>    kms_key_id = optional(string, null)<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Common tags for all resources | `map(string)` | `{}` | no |
| <a name="input_unity_catalog_account_id"></a> [unity\_catalog\_account\_id](#input\_unity\_catalog\_account\_id) | Unity Catalog AWS account ID (Databricks account for Unity Catalog) | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cross_account_role_arn"></a> [cross\_account\_role\_arn](#output\_cross\_account\_role\_arn) | ARN of the cross-account IAM role for Databricks |
| <a name="output_cross_account_role_name"></a> [cross\_account\_role\_name](#output\_cross\_account\_role\_name) | Name of the cross-account IAM role |
| <a name="output_data_bucket_name"></a> [data\_bucket\_name](#output\_data\_bucket\_name) | Name of the Unity Catalog data bucket |
| <a name="output_metastore_bucket_name"></a> [metastore\_bucket\_name](#output\_metastore\_bucket\_name) | Name of the Unity Catalog metastore bucket (if created) |
| <a name="output_root_bucket_name"></a> [root\_bucket\_name](#output\_root\_bucket\_name) | Name of the root storage bucket |
| <a name="output_unity_catalog_role_arn"></a> [unity\_catalog\_role\_arn](#output\_unity\_catalog\_role\_arn) | ARN of the Unity Catalog IAM role |
| <a name="output_unity_catalog_role_name"></a> [unity\_catalog\_role\_name](#output\_unity\_catalog\_role\_name) | Name of the Unity Catalog IAM role |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the Spoke VPC |
<!-- END_TF_DOCS -->

## Network Firewall Rules

### FQDN Rules
The firewall uses domain-based filtering to allow/deny traffic based on FQDNs. Pass your allowed domains via `security.allowed_fqdns`.

> **Important**: AWS Network Firewall `rules_source_list` uses a leading-dot format (`.domain.com`) to match a domain and all its subdomains. The wildcard format (`*.domain.com`) is **not** supported and will cause an `InvalidRequestException`.

```hcl
allowed_fqdns = [
  ".cloud.databricks.com",
  ".s3.us-west-2.amazonaws.com",
  ".pypi.org",
  "files.pythonhosted.org",
  "repo1.maven.org",
  "github.com"
]
```

### Network Rules
For IP/Protocol/Port-based rules, use `security.allowed_network_rules`:

```hcl
allowed_network_rules = [
  {
    protocol         = "TCP"
    source_ip        = "$HOME_NET"
    destination_ip   = "ANY"
    destination_port = "443"
  },
  {
    protocol         = "UDP"
    source_ip        = "$HOME_NET"
    destination_ip   = "ANY"
    destination_port = "53"
  }
]
```

### Default Deny
The firewall includes a default deny rule at the lowest priority. Only explicitly allowed traffic passes through.

## Traffic Flow

### Hub-Spoke with Firewall

1. **Spoke VPC Private Subnet** → Route to Hub VPC via Transit Gateway
2. **Transit Gateway** → Forward to Hub VPC Private Subnet
3. **Hub Private Subnet** → Route to NAT Gateway
4. **NAT Gateway** → Performs SNAT
5. **Hub Public Subnet** → Route to Firewall (if enabled) or IGW
6. **Network Firewall** → Inspect traffic (FQDN, IP, Port rules)
7. **Firewall Subnet** → Route to Internet Gateway
8. **Internet Gateway** → Forward to internet

## Module Dependencies

This module uses the following official AWS Terraform modules:

- **[terraform-aws-modules/vpc/aws](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws)** (~> 5.0)
  - VPC, subnets, NAT Gateway, Internet Gateway, route tables
- **[terraform-aws-modules/vpc/aws//modules/vpc-endpoints](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws)** (~> 5.0)
  - VPC endpoints for S3, STS, Kinesis

## Provider Requirements

```hcl
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.57.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.0"
    }
  }
}
```

## Best Practices

### Security
- ✅ Use Private Link for maximum security and reduced data egress costs
- ✅ Enable Network Firewall with allowlist-based FQDN rules
- ✅ Use Unity Catalog IAM roles with least privilege
- ✅ Enable VPC endpoints for S3, STS, and Kinesis

### Networking
- ✅ Use hub-spoke architecture for centralized internet egress and inspection
- ✅ Deploy NAT Gateway for private subnet internet access
- ✅ Use multiple availability zones for high availability
- ✅ Implement proper subnet sizing for growth

### Cost Optimization
- ✅ Use single NAT Gateway (default) instead of per-AZ for dev/test
- ✅ Consider Private Link to reduce data egress costs
- ✅ Use VPC endpoints to avoid internet gateway data transfer charges

## Troubleshooting

### Common Issues

**Issue**: Terraform validation fails with "Reference to undeclared resource"
- **Solution**: Run `terraform init -upgrade` to download required modules

**Issue**: Network Firewall blocks Databricks traffic
- **Solution**: Ensure `allowed_fqdns` includes `*.cloud.databricks.com` and required AWS services

**Issue**: Unity Catalog role trust relationship fails
- **Solution**: Verify `external_id` matches your Databricks Unity Catalog configuration

**Issue**: Private Link endpoints not accessible
- **Solution**: Check security group rules allow traffic from Databricks subnets on ports 443, 5432, 8443-8451

## Support

For issues, questions, or contributions:
- Open an issue in the repository
- Refer to [Databricks AWS documentation](https://docs.databricks.com/administration-guide/cloud-configurations/aws/index.html)
- Check [AWS VPC module documentation](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws)

## License

This module is provided as-is for use with Databricks on AWS.
