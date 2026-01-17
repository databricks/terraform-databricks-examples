#!/bin/bash
#
# Databricks Cluster Init Script - Claude Code CLI
# Installs Claude Code CLI with MLflow tracing
#
# Note: For offline/air-gapped installations, use the adb-coding-assistants-cluster-offline module instead
#

set -uo pipefail
export DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a CI=true

L="/tmp/init-script-claude.log"
log() { echo "[$(date '+%H:%M:%S')] $1" | tee -a "$L"; }
cmd_exists() { command -v "$1" >/dev/null 2>&1; }

# Install Claude Code CLI
install_claude() {
    if cmd_exists claude; then
        log "✓ Claude Code already installed"
        return 0
    fi

    log "Installing Claude Code CLI..."
    if curl -fsSL https://claude.ai/install.sh | bash &>>$L; then
        log "✓ Claude Code installation completed"
        return 0
    else
        log "⚠ Claude Code installation failed (will be available after manual install)"
        return 1
    fi
}

# Install Node.js (required for Claude Code CLI)
install_nodejs() {
    if cmd_exists node && cmd_exists npm; then
        log "✓ Node.js already installed ($(node --version))"
        return 0
    fi

    log "Installing Node.js 20.x..."
    if curl -fsSL --max-time 300 --retry 3 https://deb.nodesource.com/setup_20.x | sudo -E bash - &>>$L; then
        if sudo apt-get update -qq -y &>>$L && sudo apt-get install -y -qq nodejs &>>$L; then
            if cmd_exists node && cmd_exists npm; then
                log "✓ Node.js/npm installed successfully ($(node --version))"
                return 0
            fi
        fi
    fi

    log "⚠ Node.js installation failed (Claude Code CLI will not work)"
    return 1
}

# Add helper functions to bashrc
setup_bashrc() {
    local START_MARKER="### CLAUDE_CODE_HELPERS_START ###"
    local END_MARKER="### CLAUDE_CODE_HELPERS_END ###"

    # Backup bashrc
    [ -f "$HOME/.bashrc" ] && cp "$HOME/.bashrc" "$HOME/.bashrc.backup-$(date +%s)"

    # Remove any existing Claude sections (between markers)
    if [ -f "$HOME/.bashrc" ]; then
        if grep -q "$START_MARKER" "$HOME/.bashrc" 2>/dev/null; then
            log "Removing old bashrc helpers..."
            # Remove everything between START and END markers (inclusive)
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
# NOTE: These env vars are the PRIMARY authentication method and take precedence
# over settings.json. They are always fresh because they're set on every login.
# The settings.json file serves as a fallback for cases where env vars aren't set.
# Using ANTHROPIC_AUTH_TOKEN only (not ANTHROPIC_API_KEY) to avoid auth conflicts.
if [ -n "$DATABRICKS_TOKEN" ] && [ -n "$DATABRICKS_HOST" ]; then
    export ANTHROPIC_AUTH_TOKEN="$DATABRICKS_TOKEN"
    export ANTHROPIC_BASE_URL="${DATABRICKS_HOST}/serving-endpoints/anthropic"
    export ANTHROPIC_MODEL="databricks-claude-sonnet-4-5"
    export ANTHROPIC_CUSTOM_HEADERS="x-databricks-disable-beta-headers: true"
fi

# Internal function to generate Claude settings (single source of truth)
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

    return 0
}

# Auto-generate Claude settings from environment on first login
# NOTE: settings.json acts as a FALLBACK - env vars (set above) are the primary method.
# This is only generated if the file doesn't exist, to provide authentication when
# env vars might not be present (e.g., in some non-standard shell environments).
if [ ! -f "$HOME/.claude/settings.json" ] && [ -n "$DATABRICKS_TOKEN" ] && [ -n "$DATABRICKS_HOST" ]; then
    mkdir -p "$HOME/.claude"
    if _generate_claude_config; then
        echo "✓ Claude Code settings.json created (fallback - env vars take precedence)"
    else
        echo "⚠ Failed to generate Claude settings (run claude-refresh-token to retry)"
    fi
fi

# Auto-enable Claude tracing on login (if not already enabled)
# This ensures tracing is always active and saves to the shared workspace path
if [ -n "$DATABRICKS_TOKEN" ] && [ -n "$DATABRICKS_HOST" ] && command -v mlflow >/dev/null 2>&1; then
    # Check if tracing is already enabled (non-zero exit means not enabled)
    if ! mlflow autolog claude --status >/dev/null 2>&1; then
        # Create experiment if it doesn't exist
        python3 <<MLFLOW_AUTO_SETUP
import mlflow
mlflow.set_tracking_uri("databricks")
try:
    exp = mlflow.get_experiment_by_name("EXP_PH")
    if not exp:
        mlflow.create_experiment("EXP_PH")
except Exception:
    pass  # Silently continue if experiment creation fails
MLFLOW_AUTO_SETUP

        # Determine workspace directory - prefer /Workspace if it exists, otherwise use current directory
        WORKSPACE_DIR="."
        if [ -d "/Workspace" ]; then
            WORKSPACE_DIR="/Workspace"
        elif [ -d "$HOME/Workspace" ]; then
            WORKSPACE_DIR="$HOME/Workspace"
        fi

        # Enable autologging in the workspace directory
        (cd "$WORKSPACE_DIR" && mlflow autolog claude "." -u databricks -n "EXP_PH" >/dev/null 2>&1) && \
            echo "✓ Claude Code MLflow tracing auto-enabled in $WORKSPACE_DIR (experiment: EXP_PH)"
    fi
fi

# Regenerate Claude settings from current environment
claude-refresh-token() {
    if [ -z "$DATABRICKS_TOKEN" ] || [ -z "$DATABRICKS_HOST" ]; then
        echo "⚠ DATABRICKS_TOKEN and DATABRICKS_HOST must be set"
        echo "  On Databricks clusters, these should be automatically available"
        return 1
    fi

    mkdir -p "$HOME/.claude"
    _generate_claude_config
    echo "✓ Claude Code settings updated with:"
    echo "  DATABRICKS_HOST: $DATABRICKS_HOST"
    echo "  DATABRICKS_TOKEN: \${DATABRICKS_TOKEN:0:20}..."
}

claude-tracing-enable() {
    if [ -z "$DATABRICKS_TOKEN" ] || [ -z "$DATABRICKS_HOST" ]; then
        echo "⚠ DATABRICKS_TOKEN and DATABRICKS_HOST must be set"
        echo "  On Databricks clusters, these should be automatically available"
        return 1
    fi

    if ! command -v mlflow >/dev/null 2>&1; then
        echo "⚠ MLflow is not installed"
        return 1
    fi

    # Create experiment if it doesn't exist
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

    # Enable autologging
    mlflow autolog claude "${1:-.}" -u databricks -n "$MLFLOW_EXPERIMENT_NAME"
    echo "✓ Claude Code MLflow tracing enabled"
}

claude-tracing-status() {
    mlflow autolog claude --status
}

claude-tracing-disable() {
    mlflow autolog claude --disable
}

# Diagnostic helper
check-claude() {
    echo "=== Claude Code CLI Installation Status ==="
    echo ""

    # Check PATH
    echo "PATH includes:"
    echo "$PATH" | tr ':' '\n' | grep -E "(claude|local/bin)" || echo "  ⚠ No Claude paths found in PATH"
    echo ""

    # Check Claude
    if command -v claude >/dev/null 2>&1; then
        echo "✓ Claude Code CLI: $(which claude)"
        claude --version 2>&1 | head -1 || echo "  (version check failed)"
    else
        echo "✗ Claude Code CLI: not found"
        [ -f "$HOME/.claude/bin/claude" ] && echo "  Binary exists at: $HOME/.claude/bin/claude"
        [ -f "$HOME/.local/bin/claude" ] && echo "  Binary exists at: $HOME/.local/bin/claude"
    fi
    echo ""

    # Check configs
    echo "Configuration files:"
    if [ -f "$HOME/.claude/settings.json" ]; then
        echo "  ✓ Claude settings: $HOME/.claude/settings.json"
        echo "    Preview: $(head -3 $HOME/.claude/settings.json | tail -1)"
    else
        echo "  ✗ Claude settings: missing"
    fi
    echo ""

    # Check environment
    echo "Environment variables:"
    [ -n "$DATABRICKS_HOST" ] && echo "  ✓ DATABRICKS_HOST: ${DATABRICKS_HOST}" || echo "  ✗ DATABRICKS_HOST: not set"
    [ -n "$DATABRICKS_TOKEN" ] && echo "  ✓ DATABRICKS_TOKEN: ${DATABRICKS_TOKEN:0:20}..." || echo "  ✗ DATABRICKS_TOKEN: not set"
    [ -n "$ANTHROPIC_API_KEY" ] && echo "  ✓ ANTHROPIC_API_KEY: ${ANTHROPIC_API_KEY:0:20}..." || echo "  ✗ ANTHROPIC_API_KEY: not set"
    [ -n "$ANTHROPIC_AUTH_TOKEN" ] && echo "  ✓ ANTHROPIC_AUTH_TOKEN: ${ANTHROPIC_AUTH_TOKEN:0:20}..." || echo "  ✗ ANTHROPIC_AUTH_TOKEN: not set"
    [ -n "$ANTHROPIC_BASE_URL" ] && echo "  ✓ ANTHROPIC_BASE_URL: ${ANTHROPIC_BASE_URL}" || echo "  ✗ ANTHROPIC_BASE_URL: not set"
    [ -n "$ANTHROPIC_MODEL" ] && echo "  ✓ ANTHROPIC_MODEL: ${ANTHROPIC_MODEL}" || echo "  ✗ ANTHROPIC_MODEL: not set"
    [ -n "$ANTHROPIC_CUSTOM_HEADERS" ] && echo "  ✓ ANTHROPIC_CUSTOM_HEADERS: ${ANTHROPIC_CUSTOM_HEADERS}" || echo "  ✗ ANTHROPIC_CUSTOM_HEADERS: not set"
    echo ""

    # Check MLflow
    if command -v mlflow >/dev/null 2>&1; then
        echo "✓ MLflow: $(mlflow --version 2>&1)"
    else
        echo "✗ MLflow: not found"
    fi
    echo ""

    # Test Claude authentication
    echo "Testing Claude CLI authentication:"
    if command -v claude >/dev/null 2>&1; then
        if [ -n "$ANTHROPIC_API_KEY" ] || [ -n "$ANTHROPIC_AUTH_TOKEN" ]; then
            echo "  ✓ Authentication configured via environment variables"
            echo "  Test with: echo 'what is 1+1?' | claude --print"
        else
            echo "  ⚠ ANTHROPIC_API_KEY/ANTHROPIC_AUTH_TOKEN not set"
            echo "  Run: source ~/.bashrc"
        fi
    fi
    echo ""

    echo "Run 'source ~/.bashrc' if commands are still not found"
}

claude-debug() {
    echo "=== Claude CLI Debug Info ==="
    echo ""
    echo "Settings file:"
    [ -f "$HOME/.claude/settings.json" ] && cat "$HOME/.claude/settings.json" || echo "  Missing!"
    echo ""
    echo "Environment:"
    env | grep -E "ANTHROPIC|DATABRICKS" || echo "  No relevant env vars"
    echo ""
    echo "Claude config directory:"
    ls -la "$HOME/.claude/" 2>/dev/null || echo "  Directory doesn't exist"
}
### CLAUDE_CODE_HELPERS_END ###
EOF

    sed -i "s|WS_PH|$W|g; s|EXP_PH|$E|g" "$HOME/.bashrc"
    log "✓ Bashrc helpers added"
    log "  Experiment: $E"
}

# Main installation
main() {
    log "Starting installation..."

    # Install system dependencies (curl, git, jq - commonly used by Claude Code)
    log "Installing system dependencies..."
    if sudo apt-get update -qq -y &>>$L; then
        if sudo apt-get install -y -qq curl git jq &>>$L; then
            log "✓ System dependencies installed (curl, git, jq)"
        else
            log "⚠ Some system dependencies failed to install"
        fi
    else
        log "⚠ apt-get update failed"
    fi

    # Install MLflow with Databricks support
    log "Installing MLflow with Databricks support..."
    if pip install --quiet --upgrade "mlflow[databricks]>=3.4" &>>$L; then
        log "✓ MLflow installed successfully"
    else
        log "⚠ MLflow installation failed (tracing features will not work)"
    fi

    # Install tools (continue even if some fail)
    install_nodejs || log "⚠ Node.js installation skipped or failed"
    install_claude || log "⚠ Claude Code installation skipped or failed"

    # Configure tools
    if setup_bashrc; then
        log "✓ Bashrc configuration completed"
    else
        log "⚠ Bashrc configuration failed"
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
    log "  - check-claude: Verify installation status"
    log "  - claude-debug: Show Claude CLI configuration details"
    log "  - claude-refresh-token: Regenerate Claude settings"
    log "  - claude-tracing-enable/disable/status: Manage MLflow tracing"
    return 0
}

main
exit 0
