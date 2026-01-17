# Provisioning Databricks Cluster with Claude Code CLI (Offline Installation)

This module deploys a Databricks cluster pre-configured with Claude Code CLI for AI-assisted development in **air-gapped or restricted network environments**.

## Module content

This module can be used to deploy the following:

* Unity Catalog Volume for secure init script storage
* Init script with Claude Code CLI offline installation
* Databricks cluster with automatic AI coding assistant setup  
* MLflow experiment configuration for tracing
* Helper bash functions for cluster users

## Features

- ✅ **Zero-configuration AI coding tools** on cluster startup
- ✅ **Unity Catalog Volumes** for secure script storage (Databricks recommended practice)
- ✅ **MLflow tracing** integration for Claude Code sessions
- ✅ **Flexible cluster configuration** (single-node or autoscaling)
- ✅ **Offline/air-gapped installation** - no internet access required

## Architecture

```
┌─────────────────────────────────────────────────────┐
│ Unity Catalog Volume                                 │
│ /Volumes/<catalog>/<schema>/<volume>/               │
│   └── install-claude-offline.sh                    │
└─────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────┐
│ Databricks Cluster (on startup)                     │
│                                                       │
│ 1. Executes init script from volume                 │
│ 2. Installs Node.js, Claude CLI from local packages│
│ 3. Configures bashrc with helper functions         │
│ 4. Auto-generates configs on user login            │
└─────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────┐
│ User Login                                           │
│                                                       │
│ • DATABRICKS_TOKEN available from environment       │
│ • Configs auto-generate:                            │
│   - ~/.claude/settings.json                         │
│ • Commands ready: claude                           │
└─────────────────────────────────────────────────────┘
```

## Prerequisites

- Databricks workspace with Unity Catalog enabled
- Databricks Runtime 13.3 LTS or higher (recommended for Unity Catalog volumes)
- Databricks Terraform provider >= 1.40.0
- Unity Catalog with an existing catalog and schema
- **Offline packages** prepared and uploaded to DBFS (see [Offline Installation Guide](scripts/OFFLINE-INSTALLATION.md))

## Usage

### Basic Example

```hcl
module "coding_cluster_offline" {
  source = "./modules/adb-coding-assistants-cluster-offline"

  cluster_name = "ai-dev-cluster-offline"
  catalog_name = "main"
  schema_name  = "default"
  
  # Path to offline packages (defaults to /dbfs/init-scripts/offline-packages)
  offline_packages_path = "/dbfs/init-scripts/offline-packages"
}
```

### Complete Example

```hcl
module "coding_cluster_offline" {
  source = "./modules/adb-coding-assistants-cluster-offline"

  # Cluster configuration
  cluster_name            = "ai-development-cluster-offline"
  spark_version           = "14.3.x-scala2.12"
  node_type_id            = "Standard_DS3_v2"
  autotermination_minutes = 60
  
  # Volume configuration
  catalog_name = "main"
  schema_name  = "default"
  volume_name  = "coding_assistants_offline"
  
  # Offline packages path
  offline_packages_path = "/dbfs/init-scripts/offline-packages"
  
  # MLflow configuration
  mlflow_experiment_name = "/Workspace/Shared/claude-code-tracing"
  
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

## Preparing Offline Packages

Before using this module, you must prepare offline packages:

1. **Download dependencies** (on a machine with internet access):
   ```bash
   cd modules/adb-coding-assistants-cluster-offline/scripts
   ./download-offline-dependencies.sh
   ```

2. **Upload to Databricks**:
   ```bash
   databricks fs cp -r offline-packages/ dbfs:/init-scripts/offline-packages/
   ```

3. **Configure the module** with `offline_packages_path` pointing to the uploaded location.

See [scripts/OFFLINE-INSTALLATION.md](scripts/OFFLINE-INSTALLATION.md) for detailed instructions.

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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >= 1.40.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | >= 1.40.0 |

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
| <a name="input_node_type_id"></a> [node\_type\_id](#input\_node\_type\_id) | Node type for the cluster | `string` | `"Standard_DS3_v2"` | no |
| <a name="input_num_workers"></a> [num\_workers](#input\_num\_workers) | Number of worker nodes (null for autoscaling) | `number` | `null` | no |
| <a name="input_offline_packages_path"></a> [offline\_packages\_path](#input\_offline\_packages\_path) | Path to offline packages directory (e.g., /dbfs/init-scripts/offline-packages). If not set, defaults to /dbfs/init-scripts/offline-packages | `string` | `null` | no |
| <a name="input_schema_name"></a> [schema\_name](#input\_schema\_name) | Schema name for the volume | `string` | `"default"` | no |
| <a name="input_spark_version"></a> [spark\_version](#input\_spark\_version) | Databricks Runtime version | `string` | `"14.3.x-scala2.12"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Custom tags for the cluster | `map(string)` | <pre>{<br/>  "Environment": "dev",<br/>  "Purpose": "coding-assistants-offline"<br/>}</pre> | no |
| <a name="input_volume_name"></a> [volume\_name](#input\_volume\_name) | Volume name to store init scripts | `string` | `"coding_assistants"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The ID of the created cluster |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the created cluster |
| <a name="output_cluster_url"></a> [cluster\_url](#output\_cluster\_url) | URL to access the cluster in Databricks UI |
| <a name="output_init_script_path"></a> [init\_script\_path](#output\_init\_script\_path) | Path to the init script in the volume |
| <a name="output_mlflow_experiment_name"></a> [mlflow\_experiment\_name](#output\_mlflow\_experiment\_name) | MLflow experiment name for tracing |
| <a name="output_offline_packages_path"></a> [offline\_packages\_path](#output\_offline\_packages\_path) | Path to offline packages directory |
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

### Helper Commands

The init script installs these helper commands in `~/.bashrc`:

| Command | Purpose |
|---------|---------|
| `check-claude` | Verify installation and configuration |
| `claude-debug` | Show detailed Claude CLI configuration |
| `claude-refresh-token` | Regenerate Claude settings |
| `claude-tracing-enable` | Enable MLflow tracing |
| `claude-tracing-status` | Check tracing status |
| `claude-tracing-disable` | Disable MLflow tracing |

## Troubleshooting

### Offline Packages Not Found

If the cluster fails to start with "Offline packages not found":

1. Verify packages are uploaded:
   ```bash
   databricks fs ls dbfs:/init-scripts/offline-packages/
   ```

2. Check the path in cluster environment variables:
   ```bash
   # Should match OFFLINE_PACKAGES_PATH
   echo $OFFLINE_PACKAGES_PATH
   ```

3. Ensure the path is accessible from the cluster (DBFS mount point)

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
echo $PATH | grep claude

# Verify installation
check-claude
```

## Security Considerations

### Volume Permissions

Ensure appropriate Unity Catalog permissions:

```sql
-- Grant read access to volume
GRANT READ VOLUME ON VOLUME <catalog>.<schema>.<volume> TO <principal>;
```

### Token Security

- Tokens are **never hardcoded** in configs
- Read from environment: `$DATABRICKS_TOKEN`
- Configs regenerate per session
- Settings files are user-readable only (`~/.claude/`)

## References

- [Offline Installation Guide](scripts/OFFLINE-INSTALLATION.md)
- [Databricks Init Scripts Documentation](https://docs.databricks.com/init-scripts/)
- [Unity Catalog Volumes](https://docs.databricks.com/volumes/)
- [Databricks Terraform Provider](https://registry.terraform.io/providers/databricks/databricks/latest/docs)

## License

This module is provided as-is for use with Databricks workspaces.
