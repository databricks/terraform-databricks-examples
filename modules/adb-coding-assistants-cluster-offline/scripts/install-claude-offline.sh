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

    # Validate JSON if jq is available
    if command -v jq >/dev/null 2>&1; then
        if ! jq empty "$config_file" 2>/dev/null; then
            echo "⚠ Claude settings JSON validation failed" >&2
            return 1
        fi
    fi

    # Store token hash for change detection
    if [ -n "$DATABRICKS_TOKEN" ]; then
        echo -n "$DATABRICKS_TOKEN" | sha256sum | cut -d' ' -f1 > "$HOME/.claude/.token_hash" 2>/dev/null || true
    fi

    return 0
}

# Check if token has changed and refresh if needed
_check_and_refresh_token() {
    if [ -z "$DATABRICKS_TOKEN" ] || [ -z "$DATABRICKS_HOST" ]; then
        return 0  # Skip if token not available
    fi

    local config_file="$HOME/.claude/settings.json"
    local token_hash_file="$HOME/.claude/.token_hash"

    # Calculate current token hash
    local current_hash
    current_hash=$(echo -n "$DATABRICKS_TOKEN" | sha256sum | cut -d' ' -f1 2>/dev/null || echo "")

    if [ -z "$current_hash" ]; then
        return 0  # Skip if hash calculation failed
    fi

    # Check if token has changed
    if [ -f "$token_hash_file" ]; then
        local stored_hash
        stored_hash=$(cat "$token_hash_file" 2>/dev/null || echo "")
        if [ "$current_hash" = "$stored_hash" ]; then
            return 0  # Token unchanged, no refresh needed
        fi
    fi

    # Token changed or first time - refresh config
    mkdir -p "$HOME/.claude"
    if _generate_claude_config >/dev/null 2>&1; then
        # Only show message if in interactive shell (not cron)
        if [ -t 0 ]; then
            echo "✓ Claude Code token refreshed automatically"
        fi
        return 0
    fi

    return 1
}

# Auto-generate Claude settings from environment on first login
if [ ! -f "$HOME/.claude/settings.json" ] && [ -n "$DATABRICKS_TOKEN" ] && [ -n "$DATABRICKS_HOST" ]; then
    mkdir -p "$HOME/.claude"
    if _generate_claude_config; then
        echo "✓ Claude Code settings.json created"
    fi
fi

# Auto-refresh token on shell login if it has changed
# This ensures settings.json stays in sync with DATABRICKS_TOKEN
if [ -n "$DATABRICKS_TOKEN" ] && [ -n "$DATABRICKS_HOST" ]; then
    _check_and_refresh_token
fi

# Regenerate Claude settings from current environment
claude-refresh-token() {
    if [ -z "$DATABRICKS_TOKEN" ] || [ -z "$DATABRICKS_HOST" ]; then
        echo "⚠ DATABRICKS_TOKEN and DATABRICKS_HOST must be set"
        return 1
    fi
    
    mkdir -p "$HOME/.claude"
    if _generate_claude_config; then
        echo "✓ Claude Code settings updated"
    else
        echo "⚠ Failed to update Claude settings"
        return 1
    fi
}

# Setup cron job for periodic token refresh (runs hourly)
claude-setup-token-refresh() {
    local cron_file="$HOME/.claude/token-refresh-cron"

    # Create cron wrapper script
    mkdir -p "$HOME/.claude"
    cat > "$cron_file" <<'CRON_SCRIPT'
#!/bin/bash
# Auto-generated cron script for Claude token refresh
# This script is called by cron to refresh the Claude token periodically

# Source bashrc to get functions
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc" >/dev/null 2>&1
fi

# Check and refresh token if needed
_check_and_refresh_token
CRON_SCRIPT
    chmod +x "$cron_file"

    # Check if cron job already exists
    if crontab -l 2>/dev/null | grep -q "token-refresh-cron"; then
        echo "✓ Token refresh cron job already configured"
        return 0
    fi

    # Add cron job
    (crontab -l 2>/dev/null; echo "0 * * * * $cron_file") | crontab -
    if [ $? -eq 0 ]; then
        echo "✓ Token refresh cron job configured (runs hourly)"
        echo "  To remove: crontab -e"
    else
        echo "⚠ Failed to setup cron job (may require cron service)"
        return 1
    fi
}

# Remove token refresh cron job
claude-remove-token-refresh() {
    if crontab -l 2>/dev/null | grep -q "token-refresh-cron"; then
        crontab -l 2>/dev/null | grep -v "token-refresh-cron" | crontab -
        echo "✓ Token refresh cron job removed"
    else
        echo "ℹ No token refresh cron job found"
    fi
}

# Check token freshness status
claude-token-status() {
    if [ -z "$DATABRICKS_TOKEN" ] || [ -z "$DATABRICKS_HOST" ]; then
        echo "⚠ DATABRICKS_TOKEN and DATABRICKS_HOST must be set"
        return 1
    fi

    local config_file="$HOME/.claude/settings.json"
    local token_hash_file="$HOME/.claude/.token_hash"

    echo "=== Claude Token Status ==="
    echo ""

    # Check if config file exists
    if [ -f "$config_file" ]; then
        echo "✓ Settings file: $config_file"
        local file_age
        file_age=$(stat -c %Y "$config_file" 2>/dev/null || stat -f %m "$config_file" 2>/dev/null || echo "0")
        local current_time
        current_time=$(date +%s)
        local age_hours
        age_hours=$(( (current_time - file_age) / 3600 ))
        echo "  Last updated: ${age_hours} hour(s) ago"
    else
        echo "✗ Settings file: missing"
    fi

    echo ""

    # Check token hash
    if [ -f "$token_hash_file" ]; then
        local current_hash
        current_hash=$(echo -n "$DATABRICKS_TOKEN" | sha256sum | cut -d' ' -f1 2>/dev/null || echo "")
        local stored_hash
        stored_hash=$(cat "$token_hash_file" 2>/dev/null || echo "")
        if [ "$current_hash" = "$stored_hash" ] && [ -n "$current_hash" ]; then
            echo "✓ Token: matches stored hash (up to date)"
        else
            echo "⚠ Token: differs from stored hash (needs refresh)"
            echo "  Run: claude-refresh-token"
        fi
    else
        echo "ℹ Token hash: not stored (will be created on next refresh)"
    fi

    echo ""

    # Check cron job
    if crontab -l 2>/dev/null | grep -q "token-refresh-cron"; then
        echo "✓ Auto-refresh: enabled (hourly cron job)"
    else
        echo "ℹ Auto-refresh: disabled"
        echo "  Enable with: claude-setup-token-refresh"
    fi
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
    echo ""
    
    # VS Code/Cursor Remote SSH info
    echo "VS Code/Cursor Remote SSH:"
    local venv_path
    venv_path=$(claude-vscode-env 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$venv_path" ]; then
        echo "  ✓ Python virtual environment: $venv_path"
        echo "  Run 'claude-vscode-setup' for setup instructions"
    else
        echo "  ℹ Run 'claude-vscode-setup' for Remote SSH setup guide"
    fi
}

claude-debug() {
    echo "=== Claude CLI Debug Info ==="
    [ -f "$HOME/.claude/settings.json" ] && cat "$HOME/.claude/settings.json" || echo "Settings missing!"
    echo ""
    env | grep -E "ANTHROPIC|DATABRICKS" || echo "No env vars"
}

# VS Code/Cursor Remote SSH helpers
claude-vscode-env() {
    # Show the Databricks virtual environment path for VS Code/Cursor
    if [ -n "$DATABRICKS_VIRTUAL_ENV" ]; then
        echo "$DATABRICKS_VIRTUAL_ENV"
    else
        # Try to find pythonEnv-* directories
        local python_envs
        python_envs=$(find /databricks/python* -maxdepth 1 -type d -name "pythonEnv-*" 2>/dev/null | head -1)
        if [ -n "$python_envs" ]; then
            echo "$python_envs"
        else
            echo "⚠ DATABRICKS_VIRTUAL_ENV not set and pythonEnv-* not found"
            echo "  Try: echo \$DATABRICKS_VIRTUAL_ENV"
            return 1
        fi
    fi
}

claude-vscode-setup() {
    echo "=== VS Code/Cursor Remote SSH Setup Guide ==="
    echo ""
    echo "1. Install Remote SSH Extension"
    echo "   - VS Code: Install 'Remote - SSH' extension"
    echo "   - Cursor: Built-in Remote SSH extension (already included)"
    echo ""
    echo "2. Configure Default Extensions"
    echo "   Open Command Palette (Cmd+Shift+P / Ctrl+Shift+P):"
    echo "   → Remote-SSH: Settings"
    echo ""
    echo "   Or edit settings.json and add:"
    echo ""
    cat <<'VSCODE_SETTINGS'
   "remote.SSH.defaultExtensions": [
     "ms-Python.python",
     "ms-toolsai.jupyter"
   ]
VSCODE_SETTINGS
    echo ""
    echo "3. Connect to Cluster"
    echo "   - Command Palette → Remote-SSH: Connect to Host"
    echo "   - Enter your cluster SSH connection details"
    echo ""
    echo "4. Select Python Interpreter"
    echo "   After connecting, run this command to get the Python path:"
    echo ""
    echo "   $ claude-vscode-env"
    echo ""
    local venv_path
    venv_path=$(claude-vscode-env 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$venv_path" ]; then
        echo "   Current virtual environment:"
        echo "   $venv_path"
        echo ""
        echo "   Then in VS Code/Cursor:"
        echo "   - Command Palette → Python: Select Interpreter"
        echo "   - Paste the path above or browse to it"
    else
        echo "   Run 'echo \$DATABRICKS_VIRTUAL_ENV' to find the path"
    fi
    echo ""
    echo "5. Important Notes"
    echo "   • IPYNB notebooks and *.py Databricks notebooks have access to"
    echo "     Databricks globals (dbutils, spark, etc.)"
    echo "   • Regular Python *.py files do NOT have access to Databricks globals"
    echo "   • Always select the pythonEnv-xxx interpreter for full Databricks"
    echo "     Runtime library access"
    echo ""
    echo "6. Verify Setup"
    echo "   Run: claude-vscode-check"
}

claude-vscode-check() {
    echo "=== VS Code/Cursor Remote SSH Setup Check ==="
    echo ""
    
    # Check for virtual environment
    local venv_path
    venv_path=$(claude-vscode-env 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$venv_path" ]; then
        echo "✓ Python Virtual Environment:"
        echo "  $venv_path"
        if [ -d "$venv_path/bin" ]; then
            echo "  ✓ Virtual environment directory exists"
            if [ -f "$venv_path/bin/python" ]; then
                echo "  ✓ Python executable found"
                echo "  Python version: $($venv_path/bin/python --version 2>&1 || echo 'unknown')"
            else
                echo "  ⚠ Python executable not found"
            fi
        else
            echo "  ⚠ Virtual environment directory not found"
        fi
    else
        echo "✗ Python Virtual Environment: Not found"
        echo "  Run: echo \$DATABRICKS_VIRTUAL_ENV"
    fi
    echo ""
    
    # Check for Python
    if command -v python3 >/dev/null 2>&1; then
        echo "✓ Python3 available: $(which python3)"
        echo "  Version: $(python3 --version 2>&1)"
    else
        echo "✗ Python3 not found in PATH"
    fi
    echo ""
    
    # Check for Databricks runtime libraries
    echo "Databricks Runtime Libraries:"
    python3 <<'PYTHON_CHECK'
import sys
libraries = ['pyspark', 'pandas', 'numpy', 'mlflow', 'databricks']
found = []
missing = []

for lib in libraries:
    try:
        __import__(lib)
        found.append(lib)
    except ImportError:
        missing.append(lib)

if found:
    print(f"  ✓ Available: {', '.join(found)}")
if missing:
    print(f"  ⚠ Missing: {', '.join(missing)}")

# Check for Databricks globals (only available in notebooks)
try:
    import dbutils
    print("  ✓ dbutils available (notebook context)")
except:
    print("  ℹ dbutils not available (normal for .py files)")
PYTHON_CHECK
    
    echo ""
    echo "VS Code/Cursor Configuration:"
    echo "  Run 'claude-vscode-setup' for setup instructions"
    echo "  Run 'claude-vscode-env' to get Python interpreter path"
}

claude-vscode-config() {
    # Generate VS Code settings.json snippet
    local venv_path
    venv_path=$(claude-vscode-env 2>/dev/null)
    
    echo "=== VS Code/Cursor settings.json Configuration ==="
    echo ""
    echo "Add this to your VS Code/Cursor settings.json:"
    echo ""
    echo "{"
    echo "  \"remote.SSH.defaultExtensions\": ["
    echo "    \"ms-Python.python\","
    echo "    \"ms-toolsai.jupyter\""
    echo "  ]"
    if [ $? -eq 0 ] && [ -n "$venv_path" ]; then
        echo ","
        echo "  \"python.defaultInterpreterPath\": \"$venv_path/bin/python\""
    fi
    echo "}"
    echo ""
    if [ $? -eq 0 ] && [ -n "$venv_path" ]; then
        echo "Python interpreter path:"
        echo "  $venv_path/bin/python"
        echo ""
        echo "To set this in VS Code/Cursor:"
        echo "  1. Command Palette → Python: Select Interpreter"
        echo "  2. Enter interpreter path: $venv_path/bin/python"
    else
        echo "To find Python interpreter path, run:"
        echo "  claude-vscode-env"
    fi
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
    # Setup automatic token refresh (optional - user can enable manually)
    log "Setting up automatic token refresh..."
    if [ -n "$DATABRICKS_TOKEN" ] && [ -n "$DATABRICKS_HOST" ]; then
        # Setup cron job for periodic refresh
        if command -v crontab >/dev/null 2>&1; then
            # Source bashrc temporarily to get the function
            source "$HOME/.bashrc" >/dev/null 2>&1 || true
            claude-setup-token-refresh >/dev/null 2>&1 || log "⚠ Cron setup skipped (may require manual setup)"
        else
            log "⚠ Cron not available - token refresh will only happen on login"
        fi
    fi

    log ""
    log "Helper commands:"
    log "  - check-claude: Verify installation"
    log "  - claude-debug: Show configuration"
    log "  - claude-refresh-token: Update settings"
    log "  - claude-token-status: Check token freshness and auto-refresh status"
    log "  - claude-setup-token-refresh: Enable hourly automatic token refresh"
    log "  - claude-remove-token-refresh: Disable automatic token refresh"
    log "  - claude-tracing-enable/disable/status: Manage tracing"
    log "  - claude-vscode-setup: Show VS Code/Cursor Remote SSH setup guide"
    log "  - claude-vscode-env: Get Python virtual environment path"
    log "  - claude-vscode-check: Verify VS Code/Cursor setup"
    log "  - claude-vscode-config: Generate VS Code settings.json snippet"
    return 0
}

main
exit 0
