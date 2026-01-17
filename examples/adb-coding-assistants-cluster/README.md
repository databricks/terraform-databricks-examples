# Provisioning Databricks Cluster with Claude Code CLI

This example uses the [adb-coding-assistants-cluster](../../modules/adb-coding-assistants-cluster) module.

This template provides an example deployment of a Databricks cluster pre-configured with Claude Code CLI for AI-assisted development directly on the cluster.

## What Gets Deployed

* Unity Catalog Volume for init script storage  
* Databricks cluster with Claude Code CLI auto-installed on startup
* MLflow experiment for tracing Claude Code sessions
* Bash helper functions for easy usage

##  How to use

> **Note**  
> A detailed module README with full configuration options can be found in [modules/adb-coding-assistants-cluster](../../modules/adb-coding-assistants-cluster)

1. Reference this module using one of the different [module source types](https://developer.hashicorp.com/terraform/language/modules/sources)
2. Copy `terraform.tfvars.example` to `terraform.tfvars`
3. Update `terraform.tfvars` with your values:
   - `databricks_resource_id`: Your Azure Databricks workspace resource ID
   - `cluster_name`: Name for your cluster
   - `catalog_name`: Unity Catalog name to use
4. (Optional) Customize cluster configuration in `terraform.tfvars` (node type, autoscaling, etc.)
5. (Optional) Configure your [remote backend](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm)
6. Run `terraform init` to initialize terraform and get provider ready
7. Run `terraform plan` to review the resources that will be created
8. Run `terraform apply` to create the resources

## Prerequisites

- Databricks workspace with Unity Catalog enabled
- Unity Catalog with an existing catalog and schema
- Permission to create clusters
- (For Azure) Authenticated via `az login` or environment variables
- Databricks Runtime 14.3 LTS or higher recommended

## Post-Deployment

After the cluster starts, SSH or connect via notebook and run:

```bash
# Reload bashrc to get helper commands
source ~/.bashrc

# Verify installation
check-claude

# Start using Claude
claude "Write a Python function to analyze customer churn"

# Enable MLflow tracing (optional)
claude-tracing-enable
```

## Helper Commands

| Command | Purpose |
|---------|---------|
| `check-claude` | Verify Claude CLI installation and configuration |
| `claude-debug` | Show detailed Claude configuration |
| `claude-refresh-token` | Regenerate Claude settings from environment |
| `claude-tracing-enable` | Enable MLflow tracing for Claude sessions |
| `claude-tracing-status` | Check tracing status |
| `claude-tracing-disable` | Disable tracing |

## Offline Installation

For air-gapped or restricted network environments, use the separate offline module: [`adb-coding-assistants-cluster-offline`](../../modules/adb-coding-assistants-cluster-offline/README.md). See the [Offline Installation Guide](../../modules/adb-coding-assistants-cluster-offline/scripts/OFFLINE-INSTALLATION.md) for detailed instructions.

## Configuration Examples

### Single-Node Development Cluster

```hcl
cluster_mode = "SINGLE_NODE"
num_workers  = 0
node_type_id = "Standard_D8pds_v6"
```

### Autoscaling Production Cluster

```hcl
cluster_mode = "STANDARD"
num_workers  = null  # Enable autoscaling
min_workers  = 2
max_workers  = 8
node_type_id = "Standard_D8pds_v6"
```

## Authentication

This example uses Databricks unified authentication. Authentication can be provided via:

1. **Azure CLI** (recommended for local development):
   ```bash
   az login
   terraform apply
   ```

2. **Environment Variables** (recommended for CI/CD):
   ```bash
   export DATABRICKS_HOST="https://adb-xxx.azuredatabricks.net"
   export DATABRICKS_TOKEN="dapi..."
   terraform apply
   ```

3. **Configuration Profile**:
   ```bash
   export DATABRICKS_CONFIG_PROFILE="my-profile"
   terraform apply
   ```

For more details on authentication, see the [Databricks unified authentication documentation](https://docs.databricks.com/dev-tools/auth/unified-auth.html).

## Troubleshooting

### Init Script Fails

Check cluster event logs in the Databricks UI under **Compute** → **Your Cluster** → **Event Log**.

Common issues:
- Network connectivity to download packages
- Unity Catalog volume permissions
- Insufficient cluster permissions

### Claude Not Found After Login

```bash
# Reload bashrc
source ~/.bashrc

# Verify PATH
check-claude
```

### Authentication Issues

```bash
# Check environment variables
check-claude

# Regenerate configuration
claude-refresh-token
```

## Additional Resources

- [Module Documentation](../../modules/adb-coding-assistants-cluster/README.md)
- [Offline Module Documentation](../../modules/adb-coding-assistants-cluster-offline/README.md)
- [Offline Installation Guide](../../modules/adb-coding-assistants-cluster-offline/scripts/OFFLINE-INSTALLATION.md)
- [Scripts Documentation](../../modules/adb-coding-assistants-cluster/scripts/README.md)
- [Databricks Init Scripts Documentation](https://docs.databricks.com/clusters/init-scripts.html)
- [Unity Catalog Volumes Documentation](https://docs.databricks.com/data-governance/unity-catalog/volumes.html)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.31.0 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >=1.81.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.57.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_claude_cluster"></a> [claude\_cluster](#module\_claude\_cluster) | ../../modules/adb-coding-assistants-cluster | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_databricks_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/databricks_workspace) | data source |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_catalog_name"></a> [catalog\_name](#input\_catalog\_name) | Unity Catalog name for the volume | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the Databricks cluster | `string` | n/a | yes |
| <a name="input_databricks_resource_id"></a> [databricks\_resource\_id](#input\_databricks\_resource\_id) | The Azure resource ID for the Databricks workspace. Format: /subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.Databricks/workspaces/{workspace-name} | `string` | n/a | yes |
| <a name="input_autotermination_minutes"></a> [autotermination\_minutes](#input\_autotermination\_minutes) | Minutes of inactivity before cluster auto-terminates | `number` | `30` | no |
| <a name="input_cluster_mode"></a> [cluster\_mode](#input\_cluster\_mode) | Cluster mode: STANDARD or SINGLE\_NODE | `string` | `"STANDARD"` | no |
| <a name="input_init_script_source_path"></a> [init\_script\_source\_path](#input\_init\_script\_source\_path) | Local path to the init script | `string` | `null` | no |
| <a name="input_max_workers"></a> [max\_workers](#input\_max\_workers) | Maximum number of workers for autoscaling | `number` | `3` | no |
| <a name="input_min_workers"></a> [min\_workers](#input\_min\_workers) | Minimum number of workers for autoscaling | `number` | `1` | no |
| <a name="input_mlflow_experiment_name"></a> [mlflow\_experiment\_name](#input\_mlflow\_experiment\_name) | MLflow experiment name for Claude Code tracing | `string` | `"/Workspace/Shared/claude-code-tracing"` | no |
| <a name="input_node_type_id"></a> [node\_type\_id](#input\_node\_type\_id) | Node type for the cluster. Default is Standard_D8pds_v6 (modern, premium SSD + local NVMe). If unavailable in your region, consider Standard_DS13_v2 as fallback. | `string` | `"Standard_D8pds_v6"` | no |
| <a name="input_num_workers"></a> [num\_workers](#input\_num\_workers) | Number of worker nodes (null for autoscaling) | `number` | `null` | no |
| <a name="input_schema_name"></a> [schema\_name](#input\_schema\_name) | Schema name for the volume | `string` | `"default"` | no |
| <a name="input_spark_version"></a> [spark\_version](#input\_spark\_version) | Databricks Runtime version | `string` | `"17.3.x-cpu-ml-scala2.13"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Custom tags for the cluster | `map(string)` | <pre>{<br/>  "Environment": "dev",<br/>  "Purpose": "coding-assistants"<br/>}</pre> | no |
| <a name="input_volume_name"></a> [volume\_name](#input\_volume\_name) | Volume name to store init scripts | `string` | `"coding_assistants"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The ID of the created cluster |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the created cluster |
| <a name="output_cluster_url"></a> [cluster\_url](#output\_cluster\_url) | URL to access the cluster in Databricks UI |
| <a name="output_init_script_path"></a> [init\_script\_path](#output\_init\_script\_path) | Path to the init script in the volume |
| <a name="output_mlflow_experiment_name"></a> [mlflow\_experiment\_name](#output\_mlflow\_experiment\_name) | MLflow experiment name for tracing |
| <a name="output_setup_instructions"></a> [setup\_instructions](#output\_setup\_instructions) | Instructions for using the cluster |
| <a name="output_volume_full_name"></a> [volume\_full\_name](#output\_volume\_full\_name) | Full name of the volume |
| <a name="output_volume_path"></a> [volume\_path](#output\_volume\_path) | Path to the volume containing init scripts |
<!-- END_TF_DOCS -->
