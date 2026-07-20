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
- **Unity Catalog metastore must have a root storage credential configured** (required for volumes)
- Permission to create clusters
- (For Azure) Authenticated via `az login` or environment variables
- Databricks Runtime 14.3 LTS or higher recommended

> **Note**: If you encounter an error about missing root storage credential, you need to configure the metastore's root storage credential first. See [Databricks documentation](https://docs.databricks.com/api-explorer/workspace/metastores/update) for details.

## Post-Deployment

After the cluster starts, you can connect via SSH to use Claude Code and other development tools.

### 1. Configure SSH Tunnel

Use the Databricks CLI to set up SSH access to your new cluster:

```bash
# Authenticate if needed
databricks auth login --host https://your-workspace-url.cloud.databricks.com

# Set up SSH config (replace 'claude-dev' with your preferred alias)
databricks ssh setup --name claude-dev
# Select your cluster from the list when prompted
```

This creates an entry in your `~/.ssh/config` file.

### 2. Connect via VSCode or Cursor

1.  Install the **Remote - SSH** extension in VSCode or Cursor.
2.  Open the Command Palette (`Cmd+Shift+P` / `Ctrl+Shift+P`).
3.  Select **Remote-SSH: Connect to Host**.
4.  Choose `claude-dev` (or the alias you created).
5.  Select **Linux** as the platform.
6.  Once connected, open your persistent workspace folder: `/Workspace/Users/<your-email>/`.

> **Important: Work Storage Location**
> ⚠️ **DO NOT use Databricks Repos (`/Repos/...`) for active development work.** Repos folders can be unreliable for persistent storage and may lose uncommitted changes during cluster restarts or sync operations.
>
> ✅ **Use `/Workspace/Users/<your-email>/` instead.** This location provides reliable persistent storage. You can use regular git commands to manage version control (see "Using Git in /Workspace" section below).

### 3. Launch Claude Code

Open the terminal in your remote VSCode/Cursor session and run:

```bash
# 1. Load environment variables and helpers
source ~/.bashrc

# 2. Enable MLflow tracing (optional but recommended)
claude-tracing-enable

# 3. Start Claude Code
claude
```

**First-time setup tips:**
-   Claude will ask for file permissions; use `Shift+Tab` to auto-allow edits in the current directory.
-   If you need to refresh credentials, run `claude-refresh-token`.

### 4. Remote Web App Development (Port Forwarding)

VSCode and Cursor automatically forward ports. For example, to run a Streamlit app:

1.  Create `app.py`:
    ```python
    import streamlit as st
    st.title("Databricks Remote App")
    st.write("Running on cluster!")
    ```
2.  Run it:
    ```bash
    streamlit run app.py --server.port 8501
    ```
3.  Click "Open in Browser" in the popup notification to view it at `localhost:8501`.

### 5. Using the Databricks Python Interpreter

You don't need to configure a virtual environment. Databricks manages it for you.

1.  In the remote terminal, find the python path:
    ```bash
    echo $DATABRICKS_VIRTUAL_ENV
    # Output example: /local_disk0/.ephemeral_nfs/envs/pythonEnv-xxxx/bin/python
    ```
2.  In VSCode/Cursor, open the Command Palette and select **Python: Select Interpreter**.
3.  Paste the path from above.

### 6. Persistent Sessions with tmux

To keep your agent running even if you disconnect:

```bash
# Start a new session
tmux new -s claude-session

# Detach (Ctrl+B, then D)
# Reattach later
tmux attach -t claude-session
```

This allows you to leave long-running tasks (like "Build a data pipeline") executing on the cluster while you are offline.

### 7. Using Git in /Workspace

Since `/Workspace` doesn't have native Repos integration, use standard git commands:

```bash
# Navigate to your workspace directory
cd /Workspace/Users/<your-email>/

# Option 1: Clone an existing repository
git clone https://github.com/your-org/your-repo.git
cd your-repo

# Option 2: Initialize a new repository
mkdir my-project && cd my-project
git init
git remote add origin https://github.com/your-org/your-repo.git

# Configure git (first time only)
git config user.name "Your Name"
git config user.email "your.email@company.com"

# Regular git workflow
git add .
git commit -m "Your commit message"
git push origin main
```

**Git Authentication Options:**

1. **Personal Access Token (PAT)** - Recommended:
   ```bash
   # GitHub: Create at https://github.com/settings/tokens
   # Use token as password when prompted
   git clone https://github.com/your-org/repo.git
   ```

2. **SSH Keys**:
   ```bash
   # Generate SSH key on the cluster
   ssh-keygen -t ed25519 -C "your.email@company.com"

   # Add to GitHub: Copy output and add at https://github.com/settings/keys
   cat ~/.ssh/id_ed25519.pub

   # Clone using SSH
   git clone git@github.com:your-org/repo.git
   ```

3. **Git Credential Manager**:
   ```bash
   # Store credentials to avoid repeated prompts
   git config --global credential.helper store
   ```

## Helper Commands

### Claude CLI Commands

| Command | Purpose |
|---------|---------|
| `check-claude` | Verify Claude CLI installation and configuration |
| `claude-debug` | Show detailed Claude configuration |
| `claude-refresh-token` | Regenerate Claude settings from environment |
| `claude-token-status` | Check token freshness and auto-refresh status |
| `claude-tracing-enable` | Enable MLflow tracing for Claude sessions |
| `claude-tracing-status` | Check tracing status |
| `claude-tracing-disable` | Disable tracing |

### Git Workspace Commands

| Command | Purpose |
|---------|---------|
| `git-workspace-init` | Interactive setup for git in /Workspace (clone or init) |
| `git-workspace-check` | Verify location and check for uncommitted/unpushed changes |
| `git-workspace-setup-auth` | Configure git authentication (PAT, SSH, or credential helper) |

These helpers warn you if working in `/Repos` and ensure your work is backed up in git.

### VS Code/Cursor Remote Commands

| Command | Purpose |
|---------|---------|
| `claude-vscode-setup` | Show Remote SSH setup instructions |
| `claude-vscode-env` | Get Python interpreter path for IDE |
| `claude-vscode-check` | Verify Remote SSH configuration |
| `claude-vscode-config` | Generate settings.json snippet |

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
