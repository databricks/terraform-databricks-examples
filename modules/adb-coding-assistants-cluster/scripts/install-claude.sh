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
        log "[OK] Claude Code already installed"
        return 0
    fi

    log "Installing Claude Code CLI..."
    if curl -fsSL https://claude.ai/install.sh | bash &>>$L; then
        log "[OK] Claude Code installation completed"
        return 0
    else
        log "[WARN] Claude Code installation failed (will be available after manual install)"
        return 1
    fi
}

# Install Node.js (required for Claude Code CLI)
install_nodejs() {
    if cmd_exists node && cmd_exists npm; then
        log "[OK] Node.js already installed ($(node --version))"
        return 0
    fi

    log "Installing Node.js 20.x..."
    if curl -fsSL --max-time 300 --retry 3 https://deb.nodesource.com/setup_20.x | sudo -E bash - &>>$L; then
        if sudo apt-get update -qq -y &>>$L && sudo apt-get install -y -qq nodejs &>>$L; then
            if cmd_exists node && cmd_exists npm; then
                log "[OK] Node.js/npm installed successfully ($(node --version))"
                return 0
            fi
        fi
    fi

    log "[WARN] Node.js installation failed (Claude Code CLI will not work)"
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
    export CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1
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
            echo "[WARN] Claude settings JSON validation failed" >&2
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
            echo "[OK] Claude Code token refreshed automatically"
        fi
        return 0
    fi

    return 1
}

# Auto-generate Claude settings from environment on first login
# NOTE: settings.json acts as a FALLBACK - env vars (set above) are the primary method.
# This is only generated if the file doesn't exist, to provide authentication when
# env vars might not be present (e.g., in some non-standard shell environments).
if [ ! -f "$HOME/.claude/settings.json" ] && [ -n "$DATABRICKS_TOKEN" ] && [ -n "$DATABRICKS_HOST" ]; then
    mkdir -p "$HOME/.claude"
    if _generate_claude_config; then
        echo "[OK] Claude Code settings.json created (fallback - env vars take precedence)"
    else
        echo "[WARN] Failed to generate Claude settings (run claude-refresh-token to retry)"
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
        echo "[WARN] DATABRICKS_TOKEN and DATABRICKS_HOST must be set"
        echo "  On Databricks clusters, these should be automatically available"
        return 1
    fi

    mkdir -p "$HOME/.claude"
    if _generate_claude_config; then
        echo "[OK] Claude Code settings updated with:"
        echo "  DATABRICKS_HOST: $DATABRICKS_HOST"
        echo "  DATABRICKS_TOKEN: ${DATABRICKS_TOKEN:0:20}..."
    else
        echo "[WARN] Failed to update Claude settings"
        return 1
    fi
}

# Setup cron job for periodic token refresh (runs hourly)
claude-setup-token-refresh() {
    local cron_cmd="[ -n \"\$DATABRICKS_TOKEN\" ] && [ -n \"\$DATABRICKS_HOST\" ] && source \"\$HOME/.bashrc\" && _check_and_refresh_token >/dev/null 2>&1"
    local cron_job="0 * * * * $cron_cmd"
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
        echo "[OK] Token refresh cron job already configured"
        return 0
    fi

    # Add cron job
    (crontab -l 2>/dev/null; echo "0 * * * * $cron_file") | crontab -
    if [ $? -eq 0 ]; then
        echo "[OK] Token refresh cron job configured (runs hourly)"
        echo "  To remove: crontab -e"
    else
        echo "[WARN] Failed to setup cron job (may require cron service)"
        return 1
    fi
}

# Remove token refresh cron job
claude-remove-token-refresh() {
    if crontab -l 2>/dev/null | grep -q "token-refresh-cron"; then
        crontab -l 2>/dev/null | grep -v "token-refresh-cron" | crontab -
        echo "[OK] Token refresh cron job removed"
    else
        echo "[INFO] No token refresh cron job found"
    fi
}

# Check token freshness status
claude-token-status() {
    if [ -z "$DATABRICKS_TOKEN" ] || [ -z "$DATABRICKS_HOST" ]; then
        echo "[WARN] DATABRICKS_TOKEN and DATABRICKS_HOST must be set"
        return 1
    fi

    local config_file="$HOME/.claude/settings.json"
    local token_hash_file="$HOME/.claude/.token_hash"

    echo "=== Claude Token Status ==="
    echo ""

    # Check if config file exists
    if [ -f "$config_file" ]; then
        echo "[OK] Settings file: $config_file"
        local file_age
        file_age=$(stat -c %Y "$config_file" 2>/dev/null || stat -f %m "$config_file" 2>/dev/null || echo "0")
        local current_time
        current_time=$(date +%s)
        local age_hours
        age_hours=$(( (current_time - file_age) / 3600 ))
        echo "  Last updated: ${age_hours} hour(s) ago"
    else
        echo "[ERROR] Settings file: missing"
    fi

    echo ""

    # Check token hash
    if [ -f "$token_hash_file" ]; then
        local current_hash
        current_hash=$(echo -n "$DATABRICKS_TOKEN" | sha256sum | cut -d' ' -f1 2>/dev/null || echo "")
        local stored_hash
        stored_hash=$(cat "$token_hash_file" 2>/dev/null || echo "")
        if [ "$current_hash" = "$stored_hash" ] && [ -n "$current_hash" ]; then
            echo "[OK] Token: matches stored hash (up to date)"
        else
            echo "[WARN] Token: differs from stored hash (needs refresh)"
            echo "  Run: claude-refresh-token"
        fi
    else
        echo "[INFO] Token hash: not stored (will be created on next refresh)"
    fi

    echo ""

    # Check cron job
    if crontab -l 2>/dev/null | grep -q "token-refresh-cron"; then
        echo "[OK] Auto-refresh: enabled (hourly cron job)"
    else
        echo "[INFO] Auto-refresh: disabled"
        echo "  Enable with: claude-setup-token-refresh"
    fi
}

claude-tracing-enable() {
    if [ -z "$DATABRICKS_TOKEN" ] || [ -z "$DATABRICKS_HOST" ]; then
        echo "[WARN] DATABRICKS_TOKEN and DATABRICKS_HOST must be set"
        echo "  On Databricks clusters, these should be automatically available"
        return 1
    fi

    if ! command -v mlflow >/dev/null 2>&1; then
        echo "[WARN] MLflow is not installed"
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
        print("[OK] Created MLflow experiment: $MLFLOW_EXPERIMENT_NAME")
    else:
        print("[OK] Using existing MLflow experiment: $MLFLOW_EXPERIMENT_NAME")
except Exception as e:
    print(f"[WARN] Could not setup experiment: {e}")
MLFLOW_SETUP

    # Enable autologging
    mlflow autolog claude "${1:-.}" -u databricks -n "$MLFLOW_EXPERIMENT_NAME"
    echo "[OK] Claude Code MLflow tracing enabled"
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
    echo "$PATH" | tr ':' '\n' | grep -E "(claude|local/bin)" || echo "  [WARN] No Claude paths found in PATH"
    echo ""

    # Check Claude
    if command -v claude >/dev/null 2>&1; then
        echo "[OK] Claude Code CLI: $(which claude)"
        claude --version 2>&1 | head -1 || echo "  (version check failed)"
    else
        echo "[ERROR] Claude Code CLI: not found"
        [ -f "$HOME/.claude/bin/claude" ] && echo "  Binary exists at: $HOME/.claude/bin/claude"
        [ -f "$HOME/.local/bin/claude" ] && echo "  Binary exists at: $HOME/.local/bin/claude"
    fi
    echo ""

    # Check configs
    echo "Configuration files:"
    if [ -f "$HOME/.claude/settings.json" ]; then
        echo "  [OK] Claude settings: $HOME/.claude/settings.json"
        echo "    Preview: $(head -3 $HOME/.claude/settings.json | tail -1)"
    else
        echo "  [ERROR] Claude settings: missing"
    fi
    echo ""

    # Check environment
    echo "Environment variables:"
    [ -n "$DATABRICKS_HOST" ] && echo "  [OK] DATABRICKS_HOST: ${DATABRICKS_HOST}" || echo "  [ERROR] DATABRICKS_HOST: not set"
    [ -n "$DATABRICKS_TOKEN" ] && echo "  [OK] DATABRICKS_TOKEN: ${DATABRICKS_TOKEN:0:20}..." || echo "  [ERROR] DATABRICKS_TOKEN: not set"
    [ -n "$ANTHROPIC_API_KEY" ] && echo "  [OK] ANTHROPIC_API_KEY: ${ANTHROPIC_API_KEY:0:20}..." || echo "  [ERROR] ANTHROPIC_API_KEY: not set"
    [ -n "$ANTHROPIC_AUTH_TOKEN" ] && echo "  [OK] ANTHROPIC_AUTH_TOKEN: ${ANTHROPIC_AUTH_TOKEN:0:20}..." || echo "  [ERROR] ANTHROPIC_AUTH_TOKEN: not set"
    [ -n "$ANTHROPIC_BASE_URL" ] && echo "  [OK] ANTHROPIC_BASE_URL: ${ANTHROPIC_BASE_URL}" || echo "  [ERROR] ANTHROPIC_BASE_URL: not set"
    [ -n "$ANTHROPIC_MODEL" ] && echo "  [OK] ANTHROPIC_MODEL: ${ANTHROPIC_MODEL}" || echo "  [ERROR] ANTHROPIC_MODEL: not set"
    [ -n "$ANTHROPIC_CUSTOM_HEADERS" ] && echo "  [OK] ANTHROPIC_CUSTOM_HEADERS: ${ANTHROPIC_CUSTOM_HEADERS}" || echo "  [ERROR] ANTHROPIC_CUSTOM_HEADERS: not set"
    echo ""

    # Check MLflow
    if command -v mlflow >/dev/null 2>&1; then
        echo "[OK] MLflow: $(mlflow --version 2>&1)"
    else
        echo "[ERROR] MLflow: not found"
    fi
    echo ""

    # Test Claude authentication
    echo "Testing Claude CLI authentication:"
    if command -v claude >/dev/null 2>&1; then
        if [ -n "$ANTHROPIC_API_KEY" ] || [ -n "$ANTHROPIC_AUTH_TOKEN" ]; then
            echo "  [OK] Authentication configured via environment variables"
            echo "  Test with: echo 'what is 1+1?' | claude --print"
        else
            echo "  [WARN] ANTHROPIC_API_KEY/ANTHROPIC_AUTH_TOKEN not set"
            echo "  Run: source ~/.bashrc"
        fi
    fi
    echo ""

    # VS Code/Cursor Remote SSH info
    echo "VS Code/Cursor Remote SSH:"
    local venv_path
    venv_path=$(claude-vscode-env 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$venv_path" ]; then
        echo "  [OK] Python virtual environment: $venv_path"
        echo "  Run 'claude-vscode-setup' for setup instructions"
    else
        echo "  [INFO] Run 'claude-vscode-setup' for Remote SSH setup guide"
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
            echo "[WARN] DATABRICKS_VIRTUAL_ENV not set and pythonEnv-* not found"
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
    echo "   -> Remote-SSH: Settings"
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
    echo "   - Command Palette -> Remote-SSH: Connect to Host"
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
        echo "   - Command Palette -> Python: Select Interpreter"
        echo "   - Paste the path above or browse to it"
    else
        echo "   Run 'echo \$DATABRICKS_VIRTUAL_ENV' to find the path"
    fi
    echo ""
    echo "5. Important Notes"
    echo "   * IPYNB notebooks and *.py Databricks notebooks have access to"
    echo "     Databricks globals (dbutils, spark, etc.)"
    echo "   * Regular Python *.py files do NOT have access to Databricks globals"
    echo "   * Always select the pythonEnv-xxx interpreter for full Databricks"
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
        echo "[OK] Python Virtual Environment:"
        echo "  $venv_path"
        if [ -d "$venv_path/bin" ]; then
            echo "  [OK] Virtual environment directory exists"
            if [ -f "$venv_path/bin/python" ]; then
                echo "  [OK] Python executable found"
                echo "  Python version: $($venv_path/bin/python --version 2>&1 || echo 'unknown')"
            else
                echo "  [WARN] Python executable not found"
            fi
        else
            echo "  [WARN] Virtual environment directory not found"
        fi
    else
        echo "[ERROR] Python Virtual Environment: Not found"
        echo "  Run: echo \$DATABRICKS_VIRTUAL_ENV"
    fi
    echo ""
    
    # Check for Python
    if command -v python3 >/dev/null 2>&1; then
        echo "[OK] Python3 available: $(which python3)"
        echo "  Version: $(python3 --version 2>&1)"
    else
        echo "[ERROR] Python3 not found in PATH"
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
    print(f"  [OK] Available: {', '.join(found)}")
if missing:
    print(f"  [WARN] Missing: {', '.join(missing)}")

# Check for Databricks globals (only available in notebooks)
try:
    import dbutils
    print("  [OK] dbutils available (notebook context)")
except:
    print("  [INFO] dbutils not available (normal for .py files)")
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
        echo "  1. Command Palette -> Python: Select Interpreter"
        echo "  2. Enter interpreter path: $venv_path/bin/python"
    else
        echo "To find Python interpreter path, run:"
        echo "  claude-vscode-env"
    fi
}
### CLAUDE_CODE_HELPERS_END ###
EOF

    sed -i "s|WS_PH|$W|g; s|EXP_PH|$E|g" "$HOME/.bashrc"
    log "[OK] Bashrc helpers added"
    log "  Experiment: $E"
}

# Install Databricks skills for Claude Code
install_databricks_skills() {
    local skills_dir="$HOME/.claude/skills"
    local repo_url="https://raw.githubusercontent.com/databricks-solutions/ai-dev-kit/main/databricks-skills"
    
    # Core skills to install (curated list for most common use cases)
    local core_skills=(
        "databricks-config"
        "databricks-python-sdk"
        "databricks-unity-catalog"
        "databricks-jobs"
        "asset-bundles"
        "databricks-app-python"
        "model-serving"
        "mlflow-evaluation"
        "aibi-dashboards"
        "spark-declarative-pipelines"
    )
    
    log "Installing Databricks skills for Claude Code..."
    
    # Create skills directory
    mkdir -p "$skills_dir"
    
    local installed=0
    local failed=0
    
    for skill in "${core_skills[@]}"; do
        local skill_dir="$skills_dir/$skill"
        
        # Skip if already exists
        if [ -d "$skill_dir" ] && [ -f "$skill_dir/SKILL.md" ]; then
            log "  [INFO] Skill '$skill' already installed"
            installed=$((installed + 1))
            continue
        fi
        
        # Create skill directory
        mkdir -p "$skill_dir"
        
        # Download SKILL.md (required)
        if curl -sSL -f "${repo_url}/${skill}/SKILL.md" -o "$skill_dir/SKILL.md" 2>>$L; then
            log "  [OK] Installed skill: $skill"
            installed=$((installed + 1))
        else
            log "  [WARN] Failed to download skill: $skill"
            rm -rf "$skill_dir"
            failed=$((failed + 1))
        fi
    done
    
    if [ $installed -gt 0 ]; then
        log "[OK] Databricks skills installed: $installed skills"
        [ $failed -gt 0 ] && log "[WARN] Failed to install: $failed skills"
        return 0
    else
        log "[WARN] No Databricks skills installed"
        return 1
    fi
}

# Main installation
main() {
    log "Starting installation..."

    # Install system dependencies (curl, git, jq - commonly used by Claude Code)
    log "Installing system dependencies..."
    if sudo apt-get update -qq -y &>>$L; then
        if sudo apt-get install -y -qq curl git jq &>>$L; then
            log "[OK] System dependencies installed (curl, git, jq)"
        else
            log "[WARN] Some system dependencies failed to install"
        fi
    else
        log "[WARN] apt-get update failed"
    fi

    # Install MLflow with Databricks support
    log "Installing MLflow with Databricks support..."
    if pip install --quiet --upgrade "mlflow[databricks]>=3.4" &>>$L; then
        log "[OK] MLflow installed successfully"
    else
        log "[WARN] MLflow installation failed (tracing features will not work)"
    fi

    # Install tools (continue even if some fail)
    install_nodejs || log "[WARN] Node.js installation skipped or failed"
    install_claude || log "[WARN] Claude Code installation skipped or failed"

    # Install Databricks skills for Claude Code
    install_databricks_skills || log "[WARN] Databricks skills installation incomplete"

    # Configure tools
    if setup_bashrc; then
        log "[OK] Bashrc configuration completed"
    else
        log "[WARN] Bashrc configuration failed"
    fi

    log ""
    log "=== Installation Summary ==="
    log "Installation complete. Full log: $L"
    log ""
    log "Installed components:"
    log "  - Claude Code CLI"
    log "  - Node.js runtime"
    log "  - MLflow with Databricks support"
    log "  - Databricks skills (patterns and best practices)"
    log ""
    log "Next steps (on cluster login):"
    log "  1. Run: source ~/.bashrc"
    log "  2. Verify: check-claude"
    log "  3. Use: claude command"
    log ""
    log "Databricks skills installed in: ~/.claude/skills/"
    log "Skills available: databricks-config, python-sdk, unity-catalog,"
    log "  jobs, asset-bundles, apps, model-serving, mlflow, dashboards, pipelines"
    log ""
    log "Helper commands:"
    log "  - check-claude: Verify installation status"
    log "  - claude-debug: Show Claude CLI configuration details"
    log "  - claude-refresh-token: Regenerate Claude settings"
    log "  - claude-token-status: Check token freshness and auto-refresh status"
    log "  - claude-setup-token-refresh: Enable hourly automatic token refresh (optional)"
    log "  - claude-remove-token-refresh: Disable automatic token refresh"
    log "  - claude-tracing-enable/disable/status: Manage MLflow tracing"
    log "  - claude-vscode-setup: Show VS Code/Cursor Remote SSH setup guide"
    log "  - claude-vscode-env: Get Python virtual environment path"
    log "  - claude-vscode-check: Verify VS Code/Cursor setup"
    log "  - claude-vscode-config: Generate VS Code settings.json snippet"
    return 0
}

main
exit 0
