#!/bin/bash

################################################################################
# Setup MCP Tools for Dwell-Fiber eBPF Development
################################################################################
#
# Configures MCP (Model Context Protocol) tools for eBPF compilation,
# verification, and debugging with Claude Desktop/CLI.
#
# This script adds the following MCP tools:
# - ebpf-tools: eBPF compilation and verification (stdio transport)
# - bpftrace: eBPF program analysis and debugging (http transport)
#
# Note: The bpftrace MCP server URL is a placeholder and should be updated
# with the actual endpoint when available.
#
# Usage:
#   ./scripts/setup-mcp-tools.sh [options]
#
# Options:
#   -c, --config PATH    Path to Claude configuration file
#   -n, --no-sudo        Don't use sudo for eBPF operations
#   -d, --dry-run        Show what would be done without making changes
#   -h, --help           Show this help message
#
################################################################################

set -euo pipefail

# Default values
USE_SUDO=true
DRY_RUN=false
CONFIG_PATH=""

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${GRAY}$1${NC}"
}

log_success() {
    echo -e "${GREEN}$1${NC}"
}

log_warning() {
    echo -e "${YELLOW}$1${NC}"
}

log_error() {
    echo -e "${RED}$1${NC}"
}

log_cyan() {
    echo -e "${CYAN}$1${NC}"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--config)
            CONFIG_PATH="$2"
            shift 2
            ;;
        -n|--no-sudo)
            USE_SUDO=false
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            sed -n '2,30p' "$0" | sed 's/^# //'
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Determine default config path if not specified
if [[ -z "$CONFIG_PATH" ]]; then
    if [[ -n "${APPDATA:-}" ]]; then
        # Windows
        CONFIG_PATH="$APPDATA/Claude/claude_desktop_config.json"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        CONFIG_PATH="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
    else
        # Linux and others
        CONFIG_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/Claude/claude_desktop_config.json"
    fi
fi

# Check for required commands
check_requirements() {
    local missing=()
    
    if ! command -v jq &> /dev/null; then
        missing+=("jq")
    fi
    
    if ! command -v npx &> /dev/null; then
        missing+=("npm/npx (Node.js)")
    fi
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing[*]}"
        log_info "Please install them before running this script."
        log_info "  jq: https://stedolan.github.io/jq/download/"
        log_info "  Node.js: https://nodejs.org/"
        exit 1
    fi
}

# Create MCP configuration JSON
create_mcp_config() {
    local cmd_args
    if [[ "$USE_SUDO" == "true" ]]; then
        cmd_args='["npx", "ebpf-dev-tools@latest"]'
    else
        cmd_args='["ebpf-dev-tools@latest"]'
    fi
    
    cat <<EOF
{
  "mcpServers": {
    "ebpf-tools": {
      "command": $( [[ "$USE_SUDO" == "true" ]] && echo '"sudo"' || echo '"npx"' ),
      "args": $cmd_args,
      "transport": "stdio"
    },
    "bpftrace": {
      "url": "https://bpftrace-mcp.example.com",
      "transport": "http"
    }
  }
}
EOF
}

# Main execution
main() {
    log_cyan "Setting up MCP tools for Dwell-Fiber eBPF development..."
    log_info "Configuration file: $CONFIG_PATH"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_warning "\n[Dry Run] Would add the following MCP configuration:"
        create_mcp_config | jq .
        log_warning "\n[Dry Run] No changes made. Run without --dry-run to apply changes."
        exit 0
    fi
    
    # Check requirements
    check_requirements
    
    # Create config directory if it doesn't exist
    local config_dir
    config_dir=$(dirname "$CONFIG_PATH")
    
    if [[ ! -d "$config_dir" ]]; then
        log_success "Creating configuration directory: $config_dir"
        mkdir -p "$config_dir"
    fi
    
    # Load existing config or create base structure
    local temp_file
    temp_file=$(mktemp)
    
    if [[ -f "$CONFIG_PATH" ]]; then
        log_info "Loading existing configuration..."
        if jq empty "$CONFIG_PATH" &> /dev/null; then
            cp "$CONFIG_PATH" "$temp_file"
        else
            log_warning "Invalid JSON in existing config. Creating backup."
            cp "$CONFIG_PATH" "$CONFIG_PATH.backup"
            echo "{}" > "$temp_file"
        fi
    else
        log_success "Creating new configuration file..."
        echo "{}" > "$temp_file"
    fi
    
    # Merge MCP configuration
    log_info "Merging MCP server configurations..."
    
    if [[ "$USE_SUDO" == "true" ]]; then
        cmd="sudo"
        args='["npx", "ebpf-dev-tools@latest"]'
    else
        cmd="npx"
        args='["ebpf-dev-tools@latest"]'
    fi
    
    # Add or update mcpServers.ebpf-tools
    jq --arg cmd "$cmd" --argjson args "$args" \
       '.mcpServers.ebpf-tools = {"command": $cmd, "args": $args, "transport": "stdio"}' \
       "$temp_file" > "${temp_file}.tmp" && mv "${temp_file}.tmp" "$temp_file"
    
    # Add or update mcpServers.bpftrace
    jq '.mcpServers.bpftrace = {"url": "https://bpftrace-mcp.example.com", "transport": "http"}' \
       "$temp_file" > "${temp_file}.tmp" && mv "${temp_file}.tmp" "$temp_file"
    
    # Save final configuration
    log_info "Saving configuration to $CONFIG_PATH..."
    mv "$temp_file" "$CONFIG_PATH"
    
    log_success "\n✓ MCP tools setup complete!"
    
    log_cyan "\nNext steps:"
    log_info "1. Install prerequisites (if not already installed):"
    log_info "   - Node.js and npm (for npx)"
    log_info "   - bpftrace (for eBPF debugging)"
    log_info "   - sudo access (for privileged eBPF operations)"
    log_info "2. Restart Claude Desktop/CLI"
    if command -v kimi &> /dev/null; then
        log_info "3. Verify tools are working with: kimi mcp list"
    fi
    
    log_warning "\nNote: The bpftrace MCP URL is a placeholder."
    log_warning "Update config.json with the actual endpoint when available."
}

main
