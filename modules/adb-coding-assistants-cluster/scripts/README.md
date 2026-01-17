# Claude Code CLI Installation Scripts

This directory contains installation scripts for Claude Code CLI on Databricks clusters.

## Scripts Overview

| Script | Purpose | Network Required |
|--------|---------|------------------|
| `install-claude.sh` | Online installation (default) | ✅ Yes |

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
- ✅ **System tools** - curl, wget, git, jq
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

# Enable MLflow tracing
claude-tracing-enable

# Check tracing status
claude-tracing-status

# Disable tracing
claude-tracing-disable
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

## Internet Dependencies (Online Mode)

The online installer requires access to:

| Domain | Purpose |
|--------|---------|
| `claude.ai` | Claude CLI installer |
| `deb.nodesource.com` | Node.js repository |
| `*.ubuntu.com` | System packages |
| `pypi.org` / `files.pythonhosted.org` | Python packages |
| `registry.npmjs.org` | NPM packages |
| `${DATABRICKS_HOST}` | Databricks API endpoints |

## Firewall Configuration

If using a firewall, allow HTTPS (443) to these domains, or use the offline installation method.

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

## File Structure

```
scripts/
├── install-claude.sh              # Online installer
└── README.md                       # This file
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
