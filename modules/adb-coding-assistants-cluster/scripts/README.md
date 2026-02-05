# Claude Code CLI Installation Scripts

This directory contains installation scripts for Claude Code CLI on Databricks clusters.

## Scripts Overview

| Script | Purpose | Network Required |
|--------|---------|------------------|
| `install-claude.sh` | Full online installation with MLflow tracing | Yes |
| `install-claude-minimal.sh` | Minimal installation (Claude CLI only) | Yes |
| `vscode-setup.sh` | VS Code/Cursor Remote SSH helper | No |
| `check-network-deps.sh` | Network connectivity preflight check | Yes |

> **Note**: For offline/air-gapped installations, use the separate [`adb-coding-assistants-cluster-offline`](../adb-coding-assistants-cluster-offline/README.md) module.

## Quick Start

### Online Installation (Default)

For clusters with internet access:

```hcl
resource "databricks_cluster" "claude_cluster" {
  cluster_name            = "claude-coding-assistant"
  spark_version           = data.databricks_spark_version.latest_lts.id
  node_type_id            = "Standard_D8pds_v6"
  autotermination_minutes = 60
  num_workers             = 0

  init_scripts {
    dbfs {
      destination = "dbfs:/init-scripts/install-claude.sh"
    }
  }
}
```


## What Gets Installed

The script installs:

- ✅ **Node.js 20.x** - Required runtime for Claude CLI
- ✅ **Claude Code CLI** - AI coding assistant
- ✅ **MLflow** - For tracing Claude interactions
- ✅ **System tools** - curl, git, jq
- ✅ **Bash helpers** - Convenience functions for using Claude

## Helper Commands

After installation, these commands are available:

```bash
# Verify installation
check-claude

# Show debug info
claude-debug

# Refresh authentication
claude-refresh-token

# Token management
claude-token-status              # Check token freshness
claude-setup-token-refresh       # Enable automatic hourly refresh
claude-remove-token-refresh       # Disable automatic refresh

# Enable MLflow tracing
claude-tracing-enable

# Check tracing status
claude-tracing-status

# Disable tracing
claude-tracing-disable

# VS Code/Cursor Remote SSH helpers
claude-vscode-setup              # Show setup guide
claude-vscode-env                # Get Python virtual environment path
claude-vscode-check              # Verify VS Code/Cursor setup
claude-vscode-config             # Generate VS Code settings.json snippet
```

## VS Code/Cursor Remote SSH Setup

For remote development using VS Code or Cursor, follow these steps:

### Quick Setup

1. **Get Python interpreter path** (after SSH connection):
   ```bash
   claude-vscode-env
   # Or manually: echo $DATABRICKS_VIRTUAL_ENV
   ```

2. **Show complete setup guide**:
   ```bash
   claude-vscode-setup
   ```

3. **Generate VS Code settings**:
   ```bash
   claude-vscode-config
   ```

### Detailed Steps

#### 1. Install Remote SSH Extension

- **VS Code**: Install "Remote - SSH" extension from marketplace
- **Cursor**: Built-in Remote SSH extension (already included)

#### 2. Configure Default Extensions

Open Command Palette (`Cmd+Shift+P` / `Ctrl+Shift+P`):
- Type: `Remote-SSH: Settings`
- Or manually edit `settings.json`:

```json
{
  "remote.SSH.defaultExtensions": [
    "ms-Python.python",
    "ms-toolsai.jupyter"
  ]
}
```

#### 3. Connect to Cluster

- Command Palette → `Remote-SSH: Connect to Host`
- Enter your cluster SSH connection details

#### 4. Select Python Interpreter

After connecting:

1. Run `claude-vscode-env` to get the Python path
2. Command Palette → `Python: Select Interpreter`
3. Enter or browse to: `/databricks/python*/pythonEnv-*/bin/python`

**Important**: Always select the `pythonEnv-xxx` interpreter for full Databricks Runtime library access.

#### 5. Verify Setup

```bash
# Check setup status
claude-vscode-check

# Test in a Python file
import pyspark
import pandas
import mlflow
print("Setup successful!")
```

### Important Notes

- **IPYNB notebooks** and **`*.py` Databricks notebooks** have access to Databricks globals (`dbutils`, `spark`, etc.)
- **Regular Python `*.py` files** do NOT have access to Databricks globals
- Always select the `pythonEnv-xxx` interpreter for full Databricks Runtime library access

### Standalone Helper Script

A standalone helper script is also available:

```bash
# Show setup guide
./scripts/vscode-setup.sh --guide

# Get Python interpreter path
./scripts/vscode-setup.sh --env

# Check current setup
./scripts/vscode-setup.sh --check

# Generate settings.json
./scripts/vscode-setup.sh --settings
```

## Usage Examples

```bash
# Interactive mode
claude

# One-shot query
echo "Write a Python function to reverse a string" | claude --print

# From file
claude < prompt.txt

# With streaming
claude --stream < task.md
```

## Internet dependencies (online mode)

The online installer requires access to:

| Domain | Purpose |
|--------|---------|
| `claude.ai` | Claude CLI installer script |
| `storage.googleapis.com` | Claude CLI binaries (GCS bucket) |
| `deb.nodesource.com` | Node.js repository |
| `archive.ubuntu.com` | APT packages (x86_64) |
| `ports.ubuntu.com` | APT packages (ARM64) |
| `registry.npmjs.org` | NPM packages |
| `pypi.org` | Python package index |
| `files.pythonhosted.org` | Python package downloads |
| `raw.githubusercontent.com` | Databricks skills |
| `${DATABRICKS_HOST}` | Databricks API endpoints |

> **Tip**: Run `./scripts/check-network-deps.sh` to verify all dependencies are accessible before installation.

## Firewall configuration

If using a firewall, allow HTTPS (443) and HTTP (80) to these domains, or use the offline installation method.

## Environment Variables

### Standard Variables (Set automatically by Databricks)

- `DATABRICKS_HOST` - Workspace URL
- `DATABRICKS_TOKEN` - Authentication token

### Optional Configuration

- `MLFLOW_EXPERIMENT_NAME` - Custom experiment name (default: `/Workspace/Shared/claude-code-tracing`)

## Architecture Support

The installer supports:

- ✅ **amd64** (x86_64) - Default
- ✅ **arm64** (aarch64) - Auto-detected

## Network dependency checker

Before installation, you can verify that all required domains are accessible using the network dependency checker:

```bash
# Standard check
./scripts/check-network-deps.sh

# Detailed output with HTTP status codes
./scripts/check-network-deps.sh --verbose
```

Example output:
```
=== Claude Code Network Dependency Check ===

Checking required domains...

[OK] claude.ai
[OK] storage.googleapis.com
[OK] deb.nodesource.com
[OK] archive.ubuntu.com
[OK] ports.ubuntu.com
[OK] registry.npmjs.org
[OK] pypi.org
[OK] files.pythonhosted.org
[OK] raw.githubusercontent.com

----------------------------------------
Result: 9/9 dependencies reachable

SUCCESS: All dependencies are accessible
```

If any dependencies fail, the script provides troubleshooting guidance:
```
[OK] claude.ai
[FAIL] deb.nodesource.com - Connection timed out
...
Result: 8/9 dependencies reachable

FAILED: Some dependencies are not accessible

Troubleshooting tips:
  - Check firewall rules allow HTTPS (443) to the failed domains
  - Verify proxy settings if behind a corporate proxy
  - For air-gapped environments, use the offline installation module
```

## Troubleshooting

### Installation fails during cluster startup

Check the init script logs:
```bash
cat /tmp/init-script-claude.log
```

### Claude command not found

Reload bashrc:
```bash
source ~/.bashrc
```

### Authentication errors

Refresh token:
```bash
claude-refresh-token
```

### Installation works but Claude fails

Check configuration:
```bash
check-claude
claude-debug
```

## File structure

```
scripts/
├── install-claude.sh              # Full online installer with MLflow
├── install-claude-minimal.sh      # Minimal installer (Claude CLI only)
├── vscode-setup.sh                # VS Code/Cursor Remote SSH helper
├── check-network-deps.sh          # Network dependency checker
└── README.md                      # This file
```

> **Offline Installation**: See the [`adb-coding-assistants-cluster-offline`](../adb-coding-assistants-cluster-offline/README.md) module for offline/air-gapped installation support.

## Version Compatibility

- **Databricks Runtime**: 13.0+ LTS recommended
- **Python**: 3.9+ (included in DBR)
- **Node.js**: 20.x (installed by script)
- **MLflow**: 3.4+ (installed by script)

## Security Notes

### Authentication
- Uses Databricks personal access tokens (auto-configured)
- Tokens are ephemeral and cluster-scoped
- No long-lived credentials stored

### Network Security
- All traffic uses HTTPS
- Authentication via `ANTHROPIC_AUTH_TOKEN` environment variable
- Custom headers for Databricks integration


## Support

- **Claude CLI Issues**: [Claude AI Documentation](https://claude.ai/docs)
- **Databricks Issues**: Contact Databricks Support
- **Script Issues**: Open issue in repository

## License

See repository LICENSE file.
