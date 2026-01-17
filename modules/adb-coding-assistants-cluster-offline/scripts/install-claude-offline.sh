#!/bin/bash
#
# Databricks Cluster Init Script - Claude Code CLI (Offline Installation)
# Installs Claude Code CLI with MLflow tracing from local packages
#
# Prerequisites:
# - Run download-offline-dependencies.sh on a machine with internet access
# - Upload the offline-packages directory to DBFS (e.g., dbfs:/init-scripts/offline-packages/)
# - Set OFFLINE_PACKAGES_PATH to the local mount point (e.g., /dbfs/init-scripts/offline-packages)
#

set -uo pipefail
export DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a CI=true

L="/tmp/init-script-claude-offline.log"
log() { echo "[$(date '+%H:%M:%S')] $1" | tee -a "$L"; }
cmd_exists() { command -v "$1" >/dev/null 2>&1; }

# Path to offline packages (can be overridden via environment variable)
OFFLINE_PACKAGES_PATH="${OFFLINE_PACKAGES_PATH:-/dbfs/init-scripts/offline-packages}"

# Validate offline packages exist
if [ ! -d "$OFFLINE_PACKAGES_PATH" ]; then
    log "✗ ERROR: Offline packages not found at: $OFFLINE_PACKAGES_PATH"
    log "  Please upload offline-packages directory to DBFS and set OFFLINE_PACKAGES_PATH"
    exit 1
fi

log "Using offline packages from: $OFFLINE_PACKAGES_PATH"

# Install Node.js from local package
install_nodejs_offline() {
    if cmd_exists node && cmd_exists npm; then
        log "✓ Node.js already installed ($(node --version))"
        return 0
    fi

    log "Installing Node.js from offline packages..."
    
    # Try .deb package first
    if ls "$OFFLINE_PACKAGES_PATH"/node/*.deb 1> /dev/null 2>&1; then
        if sudo dpkg -i "$OFFLINE_PACKAGES_PATH"/node/*.deb &>>$L; then
            log "✓ Node.js installed from .deb package"
            return 0
        fi
    fi
    
    # Try .tar.xz package
    if ls "$OFFLINE_PACKAGES_PATH"/node/*.tar.xz 1> /dev/null 2>&1; then
        local NODE_TAR=$(ls "$OFFLINE_PACKAGES_PATH"/node/*.tar.xz | head -1)
        sudo tar -xJf "$NODE_TAR" -C /usr/local --strip-components=1 &>>$L
        if cmd_exists node && cmd_exists npm; then
            log "✓ Node.js installed from tarball"
            return 0
        fi
    fi

    log "⚠ Node.js installation failed"
    return 1
}

# Install Claude Code CLI from local installer
install_claude_offline() {
    if cmd_exists claude; then
        log "✓ Claude Code already installed"
        return 0
    fi

    log "Installing Claude Code CLI from offline package..."
    
    if [ -f "$OFFLINE_PACKAGES_PATH/claude/install.sh" ]; then
        # Run the installer - it may still try to download, but at least we have it locally
        if bash "$OFFLINE_PACKAGES_PATH/claude/install.sh" &>>$L; then
            log "✓ Claude Code installation completed"
            return 0
        fi
    fi
    
    log "⚠ Claude Code installation failed"
    return 1
}

# Install APT packages from local cache
install_apt_packages_offline() {
    log "Installing system dependencies from offline packages..."
    
    if [ -d "$OFFLINE_PACKAGES_PATH/apt" ] && [ "$(ls -A $OFFLINE_PACKAGES_PATH/apt)" ]; then
        # Install dependencies first to avoid dpkg errors
        if sudo dpkg -i "$OFFLINE_PACKAGES_PATH"/apt/*.deb &>>$L; then
            log "✓ System dependencies installed from offline packages"
            return 0
        else
            # Try to fix broken dependencies
            sudo apt-get install -f -y &>>$L || true
            log "⚠ Some packages may have failed to install"
        fi
    else
        log "⚠ No APT packages found in offline directory"
    fi
    
    return 0
}

# Install Python packages from local wheels
install_python_packages_offline() {
    log "Installing MLflow from offline packages..."
    
    if [ -d "$OFFLINE_PACKAGES_PATH/python" ] && [ "$(ls -A $OFFLINE_PACKAGES_PATH/python)" ]; then
        if pip install --no-index --find-links="$OFFLINE_PACKAGES_PATH/python" "mlflow[databricks]" &>>$L; then
            log "✓ MLflow installed from offline packages"
            return 0
        else
            log "⚠ MLflow installation failed"
        fi
    else
        log "⚠ No Python packages found in offline directory"
    fi
    
    return 1
}

# Add helper functions to bashrc (same as online version)
setup_bashrc() {
    local START_MARKER="### CLAUDE_CODE_HELPERS_START ###"
    local END_MARKER="### CLAUDE_CODE_HELPERS_END ###"
    
    # Backup bashrc
    [ -f "$HOME/.bashrc" ] && cp "$HOME/.bashrc" "$HOME/.bashrc.backup-$(date +%s)"
    
    # Remove any existing Claude sections (between markers)
    if [ -f "$HOME/.bashrc" ]; then
        if grep -q "$START_MARKER" "$HOME/.bashrc" 2>/dev/null; then
            log "Removing old bashrc helpers..."
            sed -i "/$START_MARKER/,/$END_MARKER/d" "$HOME/.bashrc"
        fi
    fi
    
    W="${DATABRICKS_HOST}"
    E="${MLFLOW_EXPERIMENT_NAME:-/Workspace/Shared/claude-code-tracing}"
    
    log "Adding helpers to bashrc..."
    
    cat >> "$HOME/.bashrc" <<'EOF'

### CLAUDE_CODE_HELPERS_START ###
# Claude Code CLI Setup (auto-generated - do not edit manually)
export PATH="$HOME/.claude/bin:$HOME/.local/bin:$PATH"

# Claude Code MLflow tracing helpers
export DATABRICKS_HOST="${DATABRICKS_HOST:-WS_PH}"
export MLFLOW_EXPERIMENT_NAME="${MLFLOW_EXPERIMENT_NAME:-EXP_PH}"

# Set Anthropic environment variables for Claude CLI
if [ -n "$DATABRICKS_TOKEN" ] && [ -n "$DATABRICKS_HOST" ]; then
    export ANTHROPIC_AUTH_TOKEN="$DATABRICKS_TOKEN"
    export ANTHROPIC_BASE_URL="${DATABRICKS_HOST}/serving-endpoints/anthropic"
    export ANTHROPIC_MODEL="databricks-claude-sonnet-4-5"
    export ANTHROPIC_CUSTOM_HEADERS="x-databricks-disable-beta-headers: true"
fi

# Internal function to generate Claude settings
_generate_claude_config() {
    local config_file="$HOME/.claude/settings.json"

    cat > "$config_file" <<CLAUDE_CONFIG
{
  "env": {
    "ANTHROPIC_MODEL": "databricks-claude-sonnet-4-5",
    "ANTHROPIC_BASE_URL": "${DATABRICKS_HOST}/serving-endpoints/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "${DATABRICKS_TOKEN}",
    "ANTHROPIC_CUSTOM_HEADERS": "x-databricks-disable-beta-headers: true"
  }
}
CLAUDE_CONFIG
    return 0
}

# Auto-generate Claude settings from environment on first login
if [ ! -f "$HOME/.claude/settings.json" ] && [ -n "$DATABRICKS_TOKEN" ] && [ -n "$DATABRICKS_HOST" ]; then
    mkdir -p "$HOME/.claude"
    if _generate_claude_config; then
        echo "✓ Claude Code settings.json created"
    fi
fi

# Regenerate Claude settings from current environment
claude-refresh-token() {
    if [ -z "$DATABRICKS_TOKEN" ] || [ -z "$DATABRICKS_HOST" ]; then
        echo "⚠ DATABRICKS_TOKEN and DATABRICKS_HOST must be set"
        return 1
    fi
    
    mkdir -p "$HOME/.claude"
    _generate_claude_config
    echo "✓ Claude Code settings updated"
}

claude-tracing-enable() {
    if [ -z "$DATABRICKS_TOKEN" ] || [ -z "$DATABRICKS_HOST" ]; then
        echo "⚠ DATABRICKS_TOKEN and DATABRICKS_HOST must be set"
        return 1
    fi
    
    if ! command -v mlflow >/dev/null 2>&1; then
        echo "⚠ MLflow is not installed"
        return 1
    fi
    
    python3 <<MLFLOW_SETUP
import mlflow
mlflow.set_tracking_uri("databricks")
try:
    exp = mlflow.get_experiment_by_name("$MLFLOW_EXPERIMENT_NAME")
    if not exp:
        mlflow.create_experiment("$MLFLOW_EXPERIMENT_NAME")
        print("✓ Created MLflow experiment: $MLFLOW_EXPERIMENT_NAME")
    else:
        print("✓ Using existing MLflow experiment: $MLFLOW_EXPERIMENT_NAME")
except Exception as e:
    print(f"⚠ Could not setup experiment: {e}")
MLFLOW_SETUP
    
    mlflow autolog claude "\${1:-.}" -u databricks -n "$MLFLOW_EXPERIMENT_NAME"
    echo "✓ Claude Code MLflow tracing enabled"
}

claude-tracing-status() {
    mlflow autolog claude --status
}

claude-tracing-disable() {
    mlflow autolog claude --disable
}

check-claude() {
    echo "=== Claude Code CLI Installation Status ==="
    echo ""
    if command -v claude >/dev/null 2>&1; then
        echo "✓ Claude Code CLI: $(which claude)"
    else
        echo "✗ Claude Code CLI: not found"
    fi
    echo ""
    [ -f "$HOME/.claude/settings.json" ] && echo "✓ Settings configured" || echo "✗ Settings missing"
    [ -n "$ANTHROPIC_AUTH_TOKEN" ] && echo "✓ Authentication configured" || echo "✗ Authentication not set"
}

claude-debug() {
    echo "=== Claude CLI Debug Info ==="
    [ -f "$HOME/.claude/settings.json" ] && cat "$HOME/.claude/settings.json" || echo "Settings missing!"
    echo ""
    env | grep -E "ANTHROPIC|DATABRICKS" || echo "No env vars"
}
### CLAUDE_CODE_HELPERS_END ###
EOF
    
    sed -i "s|WS_PH|$W|g; s|EXP_PH|$E|g" "$HOME/.bashrc"
    log "✓ Bashrc helpers added"
}

# Main installation
main() {
    log "Starting offline installation..."
    log "Offline packages: $OFFLINE_PACKAGES_PATH"
    
    # Install from offline packages
    install_apt_packages_offline
    install_python_packages_offline
    install_nodejs_offline
    install_claude_offline

    # Configure
    if setup_bashrc; then
        log "✓ Bashrc configuration completed"
    fi

    log ""
    log "=== Installation Summary ==="
    log "Installation complete. Full log: $L"
    log ""
    log "Next steps (on cluster login):"
    log "  1. Run: source ~/.bashrc"
    log "  2. Verify: check-claude"
    log "  3. Use: claude command"
    log ""
    log "Helper commands:"
    log "  - check-claude: Verify installation"
    log "  - claude-debug: Show configuration"
    log "  - claude-refresh-token: Update settings"
    log "  - claude-tracing-enable/disable/status: Manage tracing"
    return 0
}

main
exit 0
