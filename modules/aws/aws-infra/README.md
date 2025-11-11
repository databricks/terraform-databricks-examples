# AWS Infrastructure Module for Databricks

A comprehensive, production-ready AWS infrastructure module that provides all necessary resources for Databricks workloads using official AWS Terraform modules and best practices.

## Overview

This module creates a complete AWS infrastructure foundation optimized for Databricks, featuring:

- **🔧 Simplified Configuration**: Uses official `terraform-aws-modules/vpc` for networking
- **🔒 Secure Storage**: S3 buckets with encryption for workspace and Unity Catalog
- **👤 IAM Integration**: Cross-account and Unity Catalog roles with Databricks-generated policies
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
- **networking.tf** - VPC, subnets, security groups, NAT gateway (via AWS VPC module)
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
    allowed_fqdns = [
      "*.cloud.databricks.com",
      "*.s3.us-west-2.amazonaws.com",
      "pypi.org",
      "*.pypi.org",
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

## Inputs

### Core Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `prefix` | Prefix for all AWS resources | `string` | - | yes |
| `region` | AWS region for resource deployment | `string` | - | yes |
| `tags` | Common tags for all resources | `map(string)` | `{}` | no |

### Networking Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `networking.vpc_cidr` | VPC CIDR block | `string` | - | yes |
| `networking.availability_zones` | List of availability zones | `list(string)` | `[]` (auto-detect) | no |
| `networking.enable_nat_gateway` | Enable NAT Gateway for private subnets | `bool` | `true` | no |
| `networking.private_subnet_cidrs` | Custom private subnet CIDRs | `list(string)` | `[]` (auto-calculated) | no |
| `networking.public_subnet_cidrs` | Custom public subnet CIDRs | `list(string)` | `[]` (auto-calculated) | no |

### Storage Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `create_metastore_bucket` | Create Unity Catalog metastore bucket | `bool` | `false` | no |

### IAM Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `create_instance_profiles` | Create IAM instance profiles for Databricks clusters | `bool` | `false` | no |
| `databricks_account_id` | Databricks AWS account ID for cross-account role | `string` | `null` | yes |
| `external_id` | External ID for Unity Catalog role trust relationship | `string` | `null` | no |
| `unity_catalog_account_id` | Unity Catalog AWS account ID | `string` | `null` | no |
| `roles_to_assume` | Additional IAM role ARNs for cross-account role to assume | `list(string)` | `[]` | no |

### Security Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `security.enable_network_firewall` | Enable Network Firewall | `bool` | `false` | no |
| `security.allowed_fqdns` | List of FQDNs to allow through firewall | `list(string)` | `[]` | no |
| `security.allowed_network_rules` | List of network rules (IP, protocol, port) | `list(object)` | `[]` | no |
| `security.enable_private_link` | Enable Databricks Private Link | `bool` | `false` | no |
| `security.backend_service_name` | Backend Private Link service name | `string` | `null` | no |
| `security.relay_service_name` | Relay Private Link service name | `string` | `null` | no |

### Advanced Networking Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `advanced_networking.enable_transit_gateway` | Enable Transit Gateway | `bool` | `false` | no |
| `advanced_networking.hub_spoke_architecture` | Enable hub-spoke architecture | `bool` | `false` | no |
| `advanced_networking.hub_vpc_cidr` | CIDR block for hub VPC | `string` | `null` | conditional |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | ID of the Spoke VPC |
| `root_bucket_name` | Name of the root storage bucket |
| `metastore_bucket_name` | Name of the Unity Catalog metastore bucket (if created) |
| `data_bucket_name` | Name of the Unity Catalog data bucket |
| `cross_account_role_arn` | ARN of the cross-account IAM role for Databricks |
| `cross_account_role_name` | Name of the cross-account IAM role |
| `unity_catalog_role_arn` | ARN of the Unity Catalog IAM role |
| `unity_catalog_role_name` | Name of the Unity Catalog IAM role |

## Network Firewall Rules

### FQDN Rules
The firewall uses domain-based filtering to allow/deny traffic based on FQDNs. Pass your allowed domains via `security.allowed_fqdns`:

```hcl
allowed_fqdns = [
  "*.cloud.databricks.com",
  "*.s3.us-west-2.amazonaws.com",
  "pypi.org",
  "*.pypi.org",
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
