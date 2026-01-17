#!/bin/bash
#
# VS Code/Cursor Remote SSH Setup Helper for Databricks Clusters
# This script helps configure VS Code or Cursor for remote development on Databricks clusters
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }

# Find Databricks Python virtual environment
find_python_env() {
    if [ -n "${DATABRICKS_VIRTUAL_ENV:-}" ]; then
        echo "$DATABRICKS_VIRTUAL_ENV"
        return 0
    fi
    
    # Try to find pythonEnv-* directories
    local python_envs
    python_envs=$(find /databricks/python* -maxdepth 1 -type d -name "pythonEnv-*" 2>/dev/null | head -1)
    if [ -n "$python_envs" ]; then
        echo "$python_envs"
        return 0
    fi
    
    return 1
}

# Show setup instructions
show_setup_guide() {
    echo "=========================================="
    echo "VS Code/Cursor Remote SSH Setup Guide"
    echo "=========================================="
    echo ""
    
    echo "1. Install Remote SSH Extension"
    echo "   • VS Code: Install 'Remote - SSH' extension from marketplace"
    echo "   • Cursor: Built-in Remote SSH extension (already included)"
    echo ""
    
    echo "2. Configure Default Extensions"
    echo "   Open Command Palette (Cmd+Shift+P / Ctrl+Shift+P):"
    echo "   → Type: Remote-SSH: Settings"
    echo ""
    echo "   Or manually edit settings.json:"
    echo ""
    echo "   {"
    echo "     \"remote.SSH.defaultExtensions\": ["
    echo "       \"ms-Python.python\","
    echo "       \"ms-toolsai.jupyter\""
    echo "     ]"
    echo "   }"
    echo ""
    
    echo "3. Connect to Cluster"
    echo "   • Command Palette → Remote-SSH: Connect to Host"
    echo "   • Enter your cluster SSH connection details"
    echo "   • Format: user@hostname or use SSH config entry"
    echo ""
    
    echo "4. Select Python Interpreter"
    local venv_path
    if venv_path=$(find_python_env 2>/dev/null); then
        echo "   ✓ Found Python virtual environment:"
        echo "     $venv_path"
        echo ""
        echo "   In VS Code/Cursor:"
        echo "   • Command Palette → Python: Select Interpreter"
        echo "   • Enter interpreter path:"
        echo "     $venv_path/bin/python"
        echo ""
        echo "   Or copy this path:"
        echo "   $venv_path/bin/python"
    else
        echo "   ⚠ Could not auto-detect Python virtual environment"
        echo "   Run this command to find it:"
        echo "     echo \$DATABRICKS_VIRTUAL_ENV"
        echo ""
        echo "   Then in VS Code/Cursor:"
        echo "   • Command Palette → Python: Select Interpreter"
        echo "   • Paste the path from above"
    fi
    echo ""
    
    echo "5. Important Notes"
    echo "   • IPYNB notebooks and *.py Databricks notebooks have access to"
    echo "     Databricks globals (dbutils, spark, etc.)"
    echo "   • Regular Python *.py files do NOT have access to Databricks globals"
    echo "   • Always select the pythonEnv-xxx interpreter for full Databricks"
    echo "     Runtime library access (pyspark, pandas, numpy, mlflow, etc.)"
    echo ""
    
    echo "6. Verify Setup"
    echo "   After connecting, verify Python interpreter:"
    echo "   • Command Palette → Python: Select Interpreter"
    echo "   • Should show: pythonEnv-xxx/bin/python"
    echo ""
    echo "   Test in a Python file:"
    echo "   import pyspark"
    echo "   import pandas"
    echo "   print('Setup successful!')"
}

# Generate VS Code settings.json snippet
generate_settings() {
    local venv_path
    venv_path=$(find_python_env 2>/dev/null || echo "")
    
    echo "{"
    echo "  \"remote.SSH.defaultExtensions\": ["
    echo "    \"ms-Python.python\","
    echo "    \"ms-toolsai.jupyter\""
    echo "  ]"
    if [ -n "$venv_path" ]; then
        echo ","
        echo "  \"python.defaultInterpreterPath\": \"$venv_path/bin/python\""
    fi
    echo "}"
}

# Check current setup
check_setup() {
    echo "=========================================="
    echo "VS Code/Cursor Setup Check"
    echo "=========================================="
    echo ""
    
    # Check for virtual environment
    local venv_path
    if venv_path=$(find_python_env 2>/dev/null); then
        log_success "Python Virtual Environment found:"
        echo "  $venv_path"
        
        if [ -d "$venv_path/bin" ]; then
            log_success "Virtual environment directory exists"
            if [ -f "$venv_path/bin/python" ]; then
                log_success "Python executable found"
                echo "  Python version: $($venv_path/bin/python --version 2>&1 || echo 'unknown')"
            else
                log_warning "Python executable not found"
            fi
        else
            log_warning "Virtual environment directory not found"
        fi
    else
        log_error "Python Virtual Environment not found"
        echo "  Run: echo \$DATABRICKS_VIRTUAL_ENV"
    fi
    echo ""
    
    # Check for Python
    if command -v python3 >/dev/null 2>&1; then
        log_success "Python3 available: $(which python3)"
        echo "  Version: $(python3 --version 2>&1)"
    else
        log_error "Python3 not found in PATH"
    fi
    echo ""
    
    # Check for Databricks runtime libraries
    echo "Databricks Runtime Libraries:"
    python3 <<'PYTHON_CHECK'
import sys
libraries = ['pyspark', 'pandas', 'numpy', 'mlflow']
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
    echo "Next steps:"
    echo "  • Run this script with --guide to see setup instructions"
    echo "  • Run this script with --settings to generate settings.json"
}

# Main
main() {
    case "${1:-}" in
        --guide|-g)
            show_setup_guide
            ;;
        --settings|-s)
            generate_settings
            ;;
        --check|-c)
            check_setup
            ;;
        --env|-e)
            find_python_env || {
                log_error "Could not find Python virtual environment"
                echo "Try: echo \$DATABRICKS_VIRTUAL_ENV"
                exit 1
            }
            ;;
        --help|-h|"")
            echo "VS Code/Cursor Remote SSH Setup Helper"
            echo ""
            echo "Usage: $0 [OPTION]"
            echo ""
            echo "Options:"
            echo "  --guide, -g      Show complete setup guide"
            echo "  --settings, -s   Generate VS Code settings.json snippet"
            echo "  --check, -c       Check current setup status"
            echo "  --env, -e        Show Python virtual environment path"
            echo "  --help, -h       Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 --guide       # Show setup instructions"
            echo "  $0 --env         # Get Python interpreter path"
            echo "  $0 --check       # Verify setup"
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Run '$0 --help' for usage information"
            exit 1
            ;;
    esac
}

main "$@"
