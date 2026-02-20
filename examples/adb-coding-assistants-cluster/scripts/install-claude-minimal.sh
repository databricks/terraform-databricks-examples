#!/bin/bash
#
# Databricks Cluster Init Script - Claude Code CLI (Minimal Version)
# Installs Claude Code CLI with basic configuration only
#

set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

LOG_FILE="/tmp/init-script-claude.log"
log() {
    echo "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Install system dependencies
log "Installing system dependencies..."
sudo apt-get update -qq -y >> "$LOG_FILE" 2>&1
sudo apt-get install -y -qq curl git >> "$LOG_FILE" 2>&1 || log "Warning: Some packages failed to install"

# Install Node.js 20.x
if ! command -v node >/dev/null 2>&1; then
    log "Installing Node.js 20.x..."
    curl -fsSL --max-time 300 --retry 3 https://deb.nodesource.com/setup_20.x | sudo -E bash - >> "$LOG_FILE" 2>&1
    sudo apt-get install -y -qq nodejs >> "$LOG_FILE" 2>&1
    log "Node.js installed: $(node --version)"
else
    log "Node.js already installed: $(node --version)"
fi

# Install Claude Code CLI
# Note: Uses official Anthropic installer. For supply-chain verification,
# consider npm install @anthropic-ai/claude-code instead.
if ! command -v claude >/dev/null 2>&1; then
    log "Installing Claude Code CLI..."
    curl -fsSL https://claude.ai/install.sh | bash >> "$LOG_FILE" 2>&1
    log "Claude Code CLI installed"
else
    log "Claude Code CLI already installed"
fi

# Add basic configuration to bashrc
log "Configuring bashrc..."

# Remove old Claude section if it exists
if [ -f "$HOME/.bashrc" ]; then
    sed -i '/### CLAUDE_CODE_MINIMAL_START ###/,/### CLAUDE_CODE_MINIMAL_END ###/d' "$HOME/.bashrc" || true
fi

# Add Claude to PATH and set environment variables
cat >> "$HOME/.bashrc" <<'BASHRC_EOF'

### CLAUDE_CODE_MINIMAL_START ###
# Claude Code CLI - Minimal Setup
export PATH="$HOME/.claude/bin:$HOME/.local/bin:$PATH"

# Set Anthropic environment variables for Claude CLI
if [ -n "$DATABRICKS_TOKEN" ] && [ -n "$DATABRICKS_HOST" ]; then
    export ANTHROPIC_AUTH_TOKEN="$DATABRICKS_TOKEN"
    export ANTHROPIC_BASE_URL="${DATABRICKS_HOST}/serving-endpoints/anthropic"
    export ANTHROPIC_MODEL="databricks-claude-sonnet-4-5"
    export ANTHROPIC_CUSTOM_HEADERS="x-databricks-disable-beta-headers: true"
    export CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1
fi
### CLAUDE_CODE_MINIMAL_END ###
BASHRC_EOF

log "Configuration complete. Log file: $LOG_FILE"
log "After cluster starts, run: source ~/.bashrc"
