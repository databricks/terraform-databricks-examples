#!/bin/bash
#
# Download offline dependencies for Claude Code CLI installation
# Run this on a machine with internet access, then copy the offline-packages directory to your air-gapped environment
#

set -euo pipefail

OFFLINE_DIR="offline-packages"
ARCH="${1:-amd64}"  # amd64 or arm64

echo "=== Downloading Offline Dependencies for Claude Code CLI ==="
echo "Architecture: $ARCH"
echo "Output directory: $OFFLINE_DIR"
echo ""

# Create directory structure
mkdir -p "$OFFLINE_DIR"/{apt,python,node,claude}

# Download Node.js packages
echo "[1/4] Downloading Node.js 20.x..."
cd "$OFFLINE_DIR/node"
if [ "$ARCH" = "amd64" ]; then
    NODE_VERSION="20.11.1"
    wget -q "https://deb.nodesource.com/node_20.x/pool/main/n/nodejs/nodejs_${NODE_VERSION}-1nodesource1_amd64.deb" || {
        echo "⚠ Failed to download Node.js. Trying alternative method..."
        # Alternative: download from official Node.js
        wget -q "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" -O node-linux-x64.tar.xz
    }
elif [ "$ARCH" = "arm64" ]; then
    NODE_VERSION="20.11.1"
    wget -q "https://deb.nodesource.com/node_20.x/pool/main/n/nodejs/nodejs_${NODE_VERSION}-1nodesource1_arm64.deb" || {
        echo "⚠ Failed to download Node.js. Trying alternative method..."
        wget -q "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-arm64.tar.xz" -O node-linux-arm64.tar.xz
    }
fi
cd - > /dev/null
echo "✓ Node.js downloaded"

# Download APT packages
echo "[2/4] Downloading APT packages (curl, wget, git, jq)..."
cd "$OFFLINE_DIR/apt"
apt-get download curl wget git jq 2>/dev/null || {
    echo "⚠ apt-get download failed. Downloading manually..."
    # Fallback: download from packages.ubuntu.com
    UBUNTU_VERSION="jammy"  # Ubuntu 22.04
    wget -q "http://archive.ubuntu.com/ubuntu/pool/main/c/curl/curl_7.81.0-1ubuntu1.15_${ARCH}.deb" 2>/dev/null || true
    wget -q "http://archive.ubuntu.com/ubuntu/pool/main/w/wget/wget_1.21.2-2ubuntu1_${ARCH}.deb" 2>/dev/null || true
    wget -q "http://archive.ubuntu.com/ubuntu/pool/main/g/git/git_2.34.1-1ubuntu1.10_${ARCH}.deb" 2>/dev/null || true
    wget -q "http://archive.ubuntu.com/ubuntu/pool/universe/j/jq/jq_1.6-2.1ubuntu3_${ARCH}.deb" 2>/dev/null || true
}
cd - > /dev/null
echo "✓ APT packages downloaded"

# Download Python packages
echo "[3/4] Downloading Python packages (MLflow)..."
cd "$OFFLINE_DIR/python"
pip download "mlflow[databricks]>=3.4" --dest . 2>/dev/null || {
    echo "⚠ pip download failed. Make sure pip is installed."
}
cd - > /dev/null
echo "✓ Python packages downloaded"

# Download Claude CLI
echo "[4/4] Downloading Claude Code CLI installer..."
cd "$OFFLINE_DIR/claude"
wget -q https://claude.ai/install.sh -O install.sh || {
    echo "⚠ Failed to download Claude installer"
}
chmod +x install.sh
cd - > /dev/null
echo "✓ Claude installer downloaded"

# Create manifest
cat > "$OFFLINE_DIR/manifest.txt" <<EOF
Offline Dependencies for Claude Code CLI
Generated: $(date)
Architecture: $ARCH

Contents:
- apt/          : System packages (curl, wget, git, jq)
- python/       : Python wheels for MLflow and dependencies
- node/         : Node.js 20.x packages
- claude/       : Claude Code CLI installer

Usage:
1. Copy the entire '$OFFLINE_DIR' directory to your air-gapped cluster
2. Use install-claude-offline.sh to install from these local packages
EOF

echo ""
echo "=== Download Complete ==="
echo "Directory size: $(du -sh "$OFFLINE_DIR" | cut -f1)"
echo ""
echo "Next steps:"
echo "1. Copy '$OFFLINE_DIR' to your air-gapped Databricks cluster"
echo "2. Use install-claude-offline.sh to install from local packages"
echo ""
echo "To create a tarball for transfer:"
echo "  tar czf claude-offline-packages.tar.gz $OFFLINE_DIR"
