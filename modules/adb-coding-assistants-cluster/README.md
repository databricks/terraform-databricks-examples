# Provisioning Databricks Cluster with Claude Code CLI

This module deploys a Databricks cluster pre-configured with Claude Code CLI for AI-assisted development directly on Databricks.

## Module content

This module can be used to deploy the following:

* Unity Catalog Volume for secure init script storage
* Init script with Claude Code CLI installation
* Databricks cluster with automatic AI coding assistant setup  
* MLflow experiment configuration for tracing
* Helper bash functions for cluster users

## Features

- ✅ **Zero-configuration AI coding tools** on cluster startup
- ✅ **Unity Catalog Volumes** for secure script storage (Databricks recommended practice)
- ✅ **MLflow tracing** integration for Claude Code sessions
- ✅ **Flexible cluster configuration** (single-node or autoscaling)

> **Note**: For offline/air-gapped environments, use the separate [`adb-coding-assistants-cluster-offline`](../adb-coding-assistants-cluster-offline/README.md) module.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              LOCAL MACHINE                                       │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐               │
│  │  Local Terminal  │  │  Databricks CLI  │  │ VS Code / Cursor │               │
│  │                  │  │  (SSH Setup)     │  │ (Remote SSH Ext) │               │
│  └────────┬─────────┘  └────────┬─────────┘  └────────┬─────────┘               │
└───────────┼─────────────────────┼─────────────────────┼─────────────────────────┘
            │                     │                     │
            │    ┌────────────────┴─────────────────────┘
            │    │  3. databricks ssh setup
            ▼    ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           CONNECTION LAYER                                       │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │  SSH Tunnel  ─────────────────────────────────────────────────────────────│  │
│  │  Port Forwarding (8501 for Streamlit, etc.)                               │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────┬───────────────────────────────────────┘
                                          │ 4. VS Code connects
                                          ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           DATABRICKS WORKSPACE                                   │
│                                                                                  │
│  ┌─────────────────────────────┐      ┌─────────────────────────────────────┐   │
│  │      UNITY CATALOG          │      │      SINGLE-NODE DEV CLUSTER        │   │
│  │  ┌───────────────────────┐  │      │                                     │   │
│  │  │ Catalog               │  │      │  ┌───────────────────────────────┐  │   │
│  │  │   └── Schema          │  │      │  │  Init Script Execution        │  │   │
│  │  │        └── Volume     │──┼──────│──│  (on cluster startup)         │  │   │
│  │  │            └── init   │  │ 2.   │  └───────────────┬───────────────┘  │   │
│  │  │               script  │  │      │                  │ installs         │   │
│  │  └───────────────────────┘  │      │                  ▼                  │   │
│  │         ▲                   │      │  ┌───────────────────────────────┐  │   │
│  │         │ 1. Deploy via    │      │  │        DRIVER NODE             │  │   │
│  │         │    Terraform     │      │  │  ┌────────────┬────────────┐   │  │   │
│  └─────────┼───────────────────┘      │  │  │Claude Code │  Node.js   │   │  │   │
│            │                          │  │  │   CLI      │  Runtime   │   │  │   │
│            │                          │  │  ├────────────┼────────────┤   │  │   │
│            │                          │  │  │ Databricks │   Bash     │   │  │   │
│            │                          │  │  │   Python   │  Helpers   │   │  │   │
│            │                          │  │  ├────────────┴────────────┤   │  │   │
│            │                          │  │  │   tmux (persistent)     │   │  │   │
│            │                          │  │  └─────────────────────────┘   │  │   │
│            │                          │  └───────────────────────────────┘  │   │
│            │                          │                                     │   │
│            │                          │  ┌───────────────────────────────┐  │   │
│            │                          │  │  Workspace Storage            │  │   │
│            │                          │  │  /Workspace/Users/<email>/    │  │   │
│            │                          │  └───────────────┬───────────────┘  │   │
│            │                          │                  │ 5. git commit    │   │
│            │                          └──────────────────┼──────────────────┘   │
└────────────┼─────────────────────────────────────────────┼──────────────────────┘
             │                                             │
             │                    ┌────────────────────────┘
             │                    │
             ▼                    ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           EXTERNAL SERVICES                                      │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐               │
│  │   Claude AI API  │  │      MLflow      │  │   GitHub / Git   │               │
│  │   (Anthropic)    │  │ (Session Tracing)│  │ (Version Control)│               │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘               │
│         ▲                      ▲                      ▲                          │
│         │ 6. API calls         │ 7. Trace sessions    │                          │
│         └──────────────────────┴──────────────────────┘                          │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Workflow

1. **Terraform deploys** the Unity Catalog volume and cluster configuration
2. **Init script runs** on cluster startup, installing Claude Code CLI and tools
3. **User configures SSH** via `databricks ssh setup` command
4. **VS Code connects** via Remote SSH extension to the cluster
5. **Code is stored** in `/Workspace/Users/<email>/` and committed to Git
6. **Claude Code CLI** calls the Claude AI API for coding assistance
7. **Sessions traced** to MLflow for observability

## Prerequisites

- Databricks workspace with Unity Catalog enabled
- Databricks Runtime 13.3 LTS or higher (recommended for Unity Catalog volumes)
- Databricks Terraform provider >= 1.40.0
- Unity Catalog with an existing catalog and schema
- **Unity Catalog metastore must have a root storage credential configured** (required for volumes)

> **Note**: If you encounter an error about missing root storage credential, you need to configure the metastore's root storage credential first. See [Databricks documentation](https://docs.databricks.com/api-explorer/workspace/metastores/update) for details.

## Usage

### Basic Example

```hcl
module "coding_cluster" {
  source = "./modules/coding-assistants-cluster"

  cluster_name = "ai-dev-cluster"
  catalog_name = "main"
  schema_name  = "default"
  
  # init_script_source_path is optional - module includes the script
}
```

### Single-Node Cluster

```hcl
module "single_node_cluster" {
  source = "./modules/coding-assistants-cluster"

  cluster_name = "ai-dev-single-node"
  catalog_name = "main"
  schema_name  = "default"
  
  cluster_mode = "SINGLE_NODE"
  num_workers  = 0
}
```

### Autoscaling Cluster

```hcl
module "autoscaling_cluster" {
  source = "./modules/coding-assistants-cluster"

  cluster_name = "ai-dev-autoscaling"
  catalog_name = "main"
  schema_name  = "default"
  
  min_workers = 2
  max_workers = 8
  
  tags = {
    Environment = "production"
    Team        = "data-science"
  }
}
```

### Complete Example

```hcl
module "coding_cluster" {
  source = "./modules/coding-assistants-cluster"

  # Cluster configuration
  cluster_name            = "ai-development-cluster"
  spark_version           = "17.3.x-cpu-ml-scala2.13"
  node_type_id            = "Standard_D8pds_v6"
  autotermination_minutes = 60
  
  # Volume configuration
  catalog_name = "main"
  schema_name  = "default"
  volume_name  = "coding_assistants"
  
  # Init script (optional - uses bundled script by default)
  # init_script_source_path = "/path/to/custom/script.sh"
  
  # MLflow configuration
  mlflow_experiment_name = "/Users/me@company.com/my-claude-traces"
  
  # Autoscaling
  min_workers = 1
  max_workers = 5
  
  # Tags
  tags = {
    Environment = "development"
    Project     = "ai-assisted-coding"
    CostCenter  = "engineering"
    ManagedBy   = "terraform"
  }
}
```

## Init Script Storage Best Practices

According to [Databricks documentation](https://docs.databricks.com/aws/en/init-scripts/):

> **Databricks Runtime 13.3 LTS and above with Unity Catalog**  
> Store init scripts in Unity Catalog volumes.

### Why Unity Catalog Volumes?

1. **Governance**: Full Unity Catalog ACL support
2. **Security**: Identity-based access control
3. **Portability**: Works across AWS, Azure, and GCP
4. **Versioning**: Easy to manage and update scripts
5. **No DBFS**: Recommended alternative to legacy DBFS storage

### Init Script Identity

- **Single-user access mode**: Uses assigned principal's identity
- **Standard access mode**: Uses cluster owner's identity
- **Volume access**: Governed by Unity Catalog permissions

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >= 1.40.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | 1.102.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [databricks_cluster.coding_assistants](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/cluster) | resource |
| [databricks_file.init_script](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/file) | resource |
| [databricks_volume.init_scripts](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/volume) | resource |
| [databricks_current_user.me](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/current_user) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_catalog_name"></a> [catalog\_name](#input\_catalog\_name) | Unity Catalog name for the volume | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the Databricks cluster | `string` | n/a | yes |
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
| <a name="output_volume_full_name"></a> [volume\_full\_name](#output\_volume\_full\_name) | Full name of the volume |
| <a name="output_volume_path"></a> [volume\_path](#output\_volume\_path) | Path to the volume containing init scripts |
<!-- END_TF_DOCS -->

## Post-Deployment Usage

### On the Cluster

After the cluster starts, users can:

```bash
# Check installation status
check-claude

# Debug Claude configuration
claude-debug

# Use Claude Code
claude "Analyze the customer churn data"

# Enable MLflow tracing
claude-tracing-enable

# Check tracing status
claude-tracing-status
```

### Persistent Work Storage

**IMPORTANT: Do not use Databricks Repos (`/Repos/...`) for active development work.**

Databricks Repos folders can be unreliable for persistent storage and may lose uncommitted changes during cluster restarts or sync operations. Instead:

✅ **Use `/Workspace/Users/<email>/` for all development work**

This location provides reliable persistent storage across cluster restarts. Use the provided git helpers to manage version control:

```bash
# Navigate to your workspace
cd /Workspace/Users/$(whoami)/

# Set up git (interactive helper)
git-workspace-init

# Check git status and location
git-workspace-check

# Configure git authentication
git-workspace-setup-auth
```

The git helpers will:
- Warn if you're working in `/Repos` (unreliable location)
- Help you clone existing repos or initialize new ones
- Check for uncommitted or unpushed changes
- Guide you through authentication setup (PAT, SSH, or credential helper)

### Helper Commands

The init script installs these helper commands in `~/.bashrc`:

#### Claude CLI Commands

| Command | Purpose |
|---------|---------|
| `check-claude` | Verify installation and configuration |
| `claude-debug` | Show detailed Claude CLI configuration |
| `claude-refresh-token` | Regenerate Claude settings |
| `claude-token-status` | Check token freshness and auto-refresh status |
| `claude-tracing-enable` | Enable MLflow tracing |
| `claude-tracing-status` | Check tracing status |
| `claude-tracing-disable` | Disable MLflow tracing |

#### Git Workspace Commands

| Command | Purpose |
|---------|---------|
| `git-workspace-init` | Interactive git setup in /Workspace (clone or init) |
| `git-workspace-check` | Check location and uncommitted/unpushed changes |
| `git-workspace-setup-auth` | Configure git authentication (PAT/SSH/credential helper) |

#### VS Code/Cursor Remote Commands

| Command | Purpose |
|---------|---------|
| `claude-vscode-setup` | Show Remote SSH setup guide |
| `claude-vscode-env` | Get Python interpreter path |
| `claude-vscode-check` | Verify Remote SSH configuration |
| `claude-vscode-config` | Generate settings.json snippet |

## Cluster Access Modes

### Single-User Access Mode

```hcl
# Automatically configured by the module
data_security_mode = "SINGLE_USER"
single_user_name   = data.databricks_current_user.me.user_name
```

### Standard Access Mode

For standard access mode, you must:
1. Set up an allowlist for init scripts
2. Grant permissions to the volume

See [Allowlist documentation](https://docs.databricks.com/data-governance/unity-catalog/manage-privileges/allowlist).

## Troubleshooting

### Init Script Fails

Check cluster logs:
```bash
# Enable cluster log delivery in cluster config
# Then view: /cluster-logs/<cluster-id>/init_scripts/
```

### Commands Not Found

```bash
# Reload bashrc
source ~/.bashrc

# Check PATH
echo $PATH | grep -E "(claude)"

# Verify installation
check-coding-assistants
```

### Authentication Issues

```bash
# Check environment variables
claude-debug

# Verify token is set
echo $DATABRICKS_TOKEN

# Regenerate configs
claude-refresh-token
claude-refresh-token
```

### Script Size Limit

Init scripts must be < 64KB. If exceeded:
- Break into multiple scripts
- Remove unnecessary comments
- Compress/optimize script

## Security Considerations

### Volume Permissions

Ensure appropriate Unity Catalog permissions:

```sql
-- Grant read access to volume
GRANT READ VOLUME ON VOLUME <catalog>.<schema>.<volume> TO <principal>;

-- For standard access mode, add to allowlist
-- (Requires admin access)
```

### Token Security

- Tokens are **never hardcoded** in configs
- Read from environment: `$DATABRICKS_TOKEN`
- Configs regenerate per session
- Settings files are user-readable only (`~/.claude/`)

## Maintenance

### Updating the Init Script

1. Update the local init script file
2. Run `terraform apply` to upload new version
3. Restart clusters to apply changes

```bash
terraform apply -target=module.coding_cluster.databricks_file.init_script
```

### Updating Cluster Configuration

```bash
# Update variables in your config
# Then apply
terraform apply

# Restart cluster for changes to take effect
```

## Cost Optimization

- Use `autotermination_minutes` to automatically shut down idle clusters
- Use single-node mode for development: `cluster_mode = "SINGLE_NODE"`
- Enable autoscaling to scale down during low usage
- Consider spot instances (if supported by your cloud provider)

## Limitations

- Init scripts must be < 64KB
- Init script failures cause cluster launch to fail
- Requires Databricks Runtime 13.3 LTS+ for Unity Catalog volumes
- Standard access mode requires admin-configured allowlist

## References

- [Databricks Init Scripts Documentation](https://docs.databricks.com/init-scripts/)
- [Unity Catalog Volumes](https://docs.databricks.com/volumes/)
- [Databricks Terraform Provider](https://registry.terraform.io/providers/databricks/databricks/latest/docs)
- [Cluster Configuration](https://docs.databricks.com/compute/configure)

## License

This module is provided as-is for use with Databricks workspaces.

## Contributing

To contribute improvements to this module:
1. Test changes in an isolated Databricks workspace
2. Run `terraform validate` and `terraform fmt`
3. Update documentation for any new variables or outputs
4. Submit pull request with clear description of changes

## Support

For issues related to:
- **Module**: Open an issue in this repository
- **Init Script**: See the init script documentation
- **Databricks Platform**: Contact Databricks support
- **Claude**: Contact Anthropic support
