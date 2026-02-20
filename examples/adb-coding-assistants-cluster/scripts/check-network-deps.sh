#!/bin/bash
#
# Network Dependency Checker for Claude Code Installation
#
# Verifies connectivity to all required domains before running install-claude.sh.
# Run this script to diagnose network/firewall issues in restricted environments.
#
# Usage:
#   ./check-network-deps.sh           # Standard check
#   ./check-network-deps.sh --verbose # Detailed output
#

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

CONNECT_TIMEOUT=5
VERBOSE=false

# Color codes (disabled if not a terminal)
if [[ -t 1 ]]; then
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    YELLOW='\033[0;33m'
    BOLD='\033[1m'
    NC='\033[0m' # No Color
else
    GREEN=''
    RED=''
    YELLOW=''
    BOLD=''
    NC=''
fi

# Dependencies to check: "domain|purpose|test_url"
DEPENDENCIES=(
    "claude.ai|CLI installer script|https://claude.ai/install.sh"
    "storage.googleapis.com|Claude CLI binaries|https://storage.googleapis.com/"
    "deb.nodesource.com|Node.js repo|https://deb.nodesource.com/setup_20.x"
    "archive.ubuntu.com|APT packages (x86)|http://archive.ubuntu.com/ubuntu/"
    "ports.ubuntu.com|APT packages (ARM)|http://ports.ubuntu.com/ubuntu-ports/"
    "registry.npmjs.org|NPM packages|https://registry.npmjs.org/"
    "pypi.org|Python packages|https://pypi.org/simple/mlflow/"
    "files.pythonhosted.org|Package downloads|https://files.pythonhosted.org/"
    "raw.githubusercontent.com|Databricks skills|https://raw.githubusercontent.com/databricks-solutions/ai-dev-kit/main/README.md"
)

# ============================================================================
# Functions
# ============================================================================

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Check network connectivity to all dependencies required by install-claude.sh.

Options:
  --verbose, -v    Show detailed output including HTTP status codes
  --help, -h       Show this help message

Exit codes:
  0    All dependencies reachable
  1    One or more dependencies failed
EOF
}

log_ok() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_verbose() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo "      $1"
    fi
}

check_dns() {
    local domain=$1
    if command -v host &>/dev/null; then
        host "$domain" &>/dev/null
    elif command -v nslookup &>/dev/null; then
        nslookup "$domain" &>/dev/null
    elif command -v getent &>/dev/null; then
        getent hosts "$domain" &>/dev/null
    else
        # Fall back to ping for DNS resolution
        ping -c 1 -W 2 "$domain" &>/dev/null
    fi
}

check_url() {
    local url=$1
    local http_code

    http_code=$(curl -s -o /dev/null -w "%{http_code}" \
        --connect-timeout "$CONNECT_TIMEOUT" \
        --max-time $((CONNECT_TIMEOUT * 2)) \
        -L "$url" 2>/dev/null || echo "000")

    echo "$http_code"
}

check_dependency() {
    local entry=$1
    local domain purpose test_url

    IFS='|' read -r domain purpose test_url <<< "$entry"

    # Check DNS first
    if ! check_dns "$domain"; then
        log_fail "$domain - DNS resolution failed"
        log_verbose "Purpose: $purpose"
        log_verbose "Test URL: $test_url"
        return 1
    fi

    # Check HTTP connectivity
    local http_code
    http_code=$(check_url "$test_url")

    if [[ "$http_code" =~ ^(2[0-9]{2}|3[0-9]{2})$ ]]; then
        log_ok "$domain"
        log_verbose "Purpose: $purpose"
        log_verbose "HTTP status: $http_code"
        log_verbose "Test URL: $test_url"
        return 0
    else
        case "$http_code" in
            000)
                log_fail "$domain - Connection timed out"
                ;;
            400)
                # 400 is common for API endpoints at root - domain is reachable
                log_ok "$domain"
                log_verbose "Purpose: $purpose"
                log_verbose "HTTP status: $http_code (API endpoint - root returns 400)"
                log_verbose "Test URL: $test_url"
                return 0
                ;;
            403)
                log_fail "$domain - Access forbidden (HTTP 403)"
                ;;
            404)
                # 404 means domain is reachable, just URL changed
                log_ok "$domain"
                log_verbose "Purpose: $purpose"
                log_verbose "HTTP status: $http_code (domain reachable)"
                log_verbose "Test URL: $test_url"
                return 0
                ;;
            *)
                log_fail "$domain - HTTP $http_code"
                ;;
        esac
        log_verbose "Purpose: $purpose"
        log_verbose "Test URL: $test_url"
        return 1
    fi
}

# ============================================================================
# Main
# ============================================================================

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Check for curl
if ! command -v curl &>/dev/null; then
    echo "Error: curl is required but not installed"
    exit 1
fi

echo ""
echo -e "${BOLD}=== Claude Code Network Dependency Check ===${NC}"
echo ""
echo "Checking required domains..."
echo ""

pass_count=0
fail_count=0
total=${#DEPENDENCIES[@]}

for dep in "${DEPENDENCIES[@]}"; do
    if check_dependency "$dep"; then
        ((pass_count++))
    else
        ((fail_count++))
    fi
done

echo ""
echo "----------------------------------------"
echo -e "Result: ${BOLD}${pass_count}/${total}${NC} dependencies reachable"

if [[ $fail_count -gt 0 ]]; then
    echo ""
    echo -e "${RED}FAILED: Some dependencies are not accessible${NC}"
    echo ""
    echo "Troubleshooting tips:"
    echo "  - Check firewall rules allow HTTPS (443) to the failed domains"
    echo "  - Verify proxy settings if behind a corporate proxy"
    echo "  - For air-gapped environments, use the offline installation module"
    echo ""
    exit 1
else
    echo ""
    echo -e "${GREEN}SUCCESS: All dependencies are accessible${NC}"
    echo ""
    exit 0
fi
