# Offline Installation Guide for Claude Code CLI

This guide explains how to install Claude Code CLI on Databricks clusters without internet access (air-gapped or firewalled environments).

## Overview

The offline installation process involves two phases:

1. **Download Phase** (on machine with internet access)
2. **Installation Phase** (on air-gapped Databricks cluster)

## Phase 1: Download Dependencies

Run this on a machine with internet access:

```bash
# Download all dependencies
bash download-offline-dependencies.sh

# Optional: specify architecture (default: amd64)
bash download-offline-dependencies.sh arm64

# Create tarball for transfer
tar czf claude-offline-packages.tar.gz offline-packages/
```

This will create an `offline-packages/` directory containing:

```
offline-packages/
├── apt/           # System packages (curl, wget, git, jq)
├── python/        # Python wheels (MLflow and dependencies)
├── node/          # Node.js 20.x
├── claude/        # Claude Code CLI installer
└── manifest.txt   # Package inventory
```

## Phase 2: Upload to Databricks

### Option A: Using DBFS

```bash
# Upload to DBFS
databricks fs cp -r offline-packages/ dbfs:/init-scripts/offline-packages/

# Or using tarball
databricks fs cp claude-offline-packages.tar.gz dbfs:/init-scripts/
```

### Option B: Using Workspace Files

```bash
# Upload via Databricks CLI
databricks workspace import-dir offline-packages/ /Workspace/Shared/init-scripts/offline-packages/
```

### Option C: Using Azure Storage (for Azure Databricks)

```bash
# Upload to storage account used by your workspace
az storage blob upload-batch \
  --account-name <storage-account> \
  --destination init-scripts \
  --source offline-packages/
```

## Phase 3: Configure Cluster Init Script

### Using DBFS Path

```hcl
resource "databricks_cluster" "claude_cluster" {
  # ... other configuration ...
  
  init_scripts {
    dbfs {
      destination = "dbfs:/init-scripts/install-claude-offline.sh"
    }
  }
  
  spark_env_vars = {
    OFFLINE_PACKAGES_PATH = "/dbfs/init-scripts/offline-packages"
  }
}
```

### Using Workspace Path

```hcl
resource "databricks_cluster" "claude_cluster" {
  # ... other configuration ...
  
  init_scripts {
    workspace {
      destination = "/Shared/init-scripts/install-claude-offline.sh"
    }
  }
  
  spark_env_vars = {
    OFFLINE_PACKAGES_PATH = "/Workspace/Shared/init-scripts/offline-packages"
  }
}
```

## Phase 4: Install on Cluster

The offline installation script will automatically run during cluster startup.

After the cluster starts, SSH into the cluster and verify:

```bash
# Reload bashrc
source ~/.bashrc

# Check installation
check-claude

# Test Claude CLI
echo "what is 1+1?" | claude --print
```

## Troubleshooting

### Missing Packages

If packages are missing from the offline bundle:

```bash
# On internet-connected machine, download specific package
cd offline-packages/python
pip download <package-name>

# Re-upload to DBFS
databricks fs cp <package>.whl dbfs:/init-scripts/offline-packages/python/
```

### Wrong Architecture

If you get "wrong architecture" errors:

```bash
# Download for correct architecture
bash download-offline-dependencies.sh arm64  # or amd64

# Re-upload packages
```

### Claude Installer Still Tries to Download

The Claude installer may still attempt internet access. To fully offline install:

1. On an internet-connected machine with same OS/architecture as cluster, install Claude
2. Copy the installed binary:
   ```bash
   # After installing Claude on test machine
   cp ~/.local/bin/claude offline-packages/claude/claude-binary
   cp -r ~/.claude offline-packages/claude/claude-config/
   ```

3. Modify `install-claude-offline.sh` to copy binary directly:
   ```bash
   # Add to install_claude_offline function:
   if [ -f "$OFFLINE_PACKAGES_PATH/claude/claude-binary" ]; then
       mkdir -p "$HOME/.local/bin"
       cp "$OFFLINE_PACKAGES_PATH/claude/claude-binary" "$HOME/.local/bin/claude"
       chmod +x "$HOME/.local/bin/claude"
       log "✓ Claude Code installed from offline binary"
       return 0
   fi
   ```

### Node.js Installation Fails

If Node.js from .deb fails due to dependencies:

```bash
# Use the tarball method instead - it's dependency-free
# The script automatically tries this as fallback
```

## Size Estimates

Approximate download sizes:

- Node.js: ~30-40 MB
- APT packages: ~5-10 MB
- Python packages (MLflow): ~50-80 MB
- Claude installer: ~1 MB
- **Total: ~100-150 MB**

## Security Considerations

For high-security environments:

1. **Verify checksums** of downloaded packages
2. **Scan packages** for vulnerabilities before upload
3. **Use internal artifact repository** (Artifactory, Nexus)
4. **Sign packages** if required by your organization
5. **Maintain version inventory** for compliance

## Alternative: Internal Mirror

For large-scale deployments, consider setting up internal mirrors:

```bash
# Example: Internal PyPI mirror
pip install --index-url https://pypi.internal.company.com/simple mlflow[databricks]

# Example: Internal NPM registry
npm config set registry https://npm.internal.company.com
```

Then modify the online installer to use internal mirrors instead of public repositories.

## Support

For issues specific to:
- **Claude CLI**: See [Claude AI Documentation](https://claude.ai/docs)
- **Databricks clusters**: Contact Databricks support
- **This script**: Open an issue in the repository
