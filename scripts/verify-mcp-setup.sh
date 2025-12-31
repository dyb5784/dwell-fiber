#!/bin/bash

################################################################################
# Verify MCP Tools Setup for Dwell-Fiber eBPF Development
################################################################################

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
GRAY='\033[0;37m'
CYAN='\033[0;36m'
NC='\033[0m'

CONFIG_PATH="${1:-${APPDATA:-${HOME}/.config}/Claude/claude_desktop_config.json}"

echo -e "${CYAN}MCP Setup Verification for Dwell-Fiber${NC}"
echo "======================================"
echo ""

# Check configuration file
echo -e "${CYAN}1. Configuration File:${NC}"
if [[ -f "$CONFIG_PATH" ]]; then
    echo -e "${GREEN}   ✓ Found: $CONFIG_PATH${NC}"
    if jq empty "$CONFIG_PATH" &> /dev/null; then
        echo -e "${GREEN}   ✓ Valid JSON${NC}"
        
        servers=$(jq -r '.mcpServers | keys[]' "$CONFIG_PATH" 2>/dev/null | wc -l)
        if [[ $servers -gt 0 ]]; then
            echo -e "${GREEN}   ✓ MCP servers configured:${NC}"
            jq -r '.mcpServers | to_entries[] | "     - \(.key): \(.value.transport) transport"' "$CONFIG_PATH" 2>/dev/null
        else
            echo -e "${RED}   ✗ No MCP servers found${NC}"
        fi
    else
        echo -e "${RED}   ✗ Invalid JSON${NC}"
    fi
else
    echo -e "${RED}   ✗ Not found: $CONFIG_PATH${NC}"
fi
echo ""

# Check prerequisites
echo -e "${CYAN}2. Prerequisites:${NC}"

# Check Node.js/npx
if command -v npx >/dev/null 2>&1; then
    npx_path=$(which npx)
    echo -e "${GREEN}   ✓ npx found: $npx_path${NC}"
    
    if node --version >/dev/null 2>&1; then
        node_ver=$(node --version)
        echo -e "${GREEN}   ✓ Node.js version: $node_ver${NC}"
    else
        echo -e "${YELLOW}   ⚠ Node.js: Installed but version check failed${NC}"
    fi
else
    echo -e "${RED}   ✗ npx not found - Install Node.js from https://nodejs.org${NC}"
fi

# Check sudo
if command -v sudo >/dev/null 2>&1; then
    sudo_path=$(which sudo)
    echo -e "${GREEN}   ✓ sudo found: $sudo_path${NC}"
else
    echo -e "${YELLOW}   ⚠ sudo not found - May need root access for eBPF${NC}"
fi

# Check bpftrace
if command -v bpftrace >/dev/null 2>&1; then
    bpftrace_path=$(which bpftrace)
    echo -e "${GREEN}   ✓ bpftrace found: $bpftrace_path${NC}"
else
    echo -e "${YELLOW}   ⚠ bpftrace not found - Optional, for eBPF debugging only${NC}"
fi
echo ""

# Check eBPF program
echo -e "${CYAN}3. eBPF Program:${NC}"
if [[ -f "bpf/dwell_monitor.bpf.c" ]]; then
    echo -e "${GREEN}   ✓ Main eBPF program found: bpf/dwell_monitor.bpf.c${NC}"
    
    if grep -q 'SEC("tracepoint' bpf/dwell_monitor.bpf.c; then
        echo -e "${GREEN}   ✓ Uses tracepoints for kernel instrumentation${NC}"
    fi
    if grep -q 'SEC("kprobe' bpf/dwell_monitor.bpf.c; then
        echo -e "${GREEN}   ✓ Uses kprobes for kernel function hooking${NC}"
    fi
else
    echo -e "${RED}   ✗ eBPF program not found: bpf/dwell_monitor.bpf.c${NC}"
fi
echo ""

# Summary
echo -e "${CYAN}4. Summary:${NC}"
echo ""

echo -en "   Configuration: "
if [[ -f "$CONFIG_PATH" ]]; then
    echo -e "${GREEN}✓ Ready${NC}"
else
    echo -e "${RED}✗ Missing${NC}"
fi

echo -en "   Prerequisites: "
if command -v npx >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Core tools installed${NC}"
else
    echo -e "${RED}✗ Missing Node.js${NC}"
fi

echo -en "   bpftrace tool: "
if command -v bpftrace >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Available${NC}"
else
    echo -e "${YELLOW}⚠ Optional (not installed)${NC}"
fi

echo ""
echo "================"
echo ""

echo -e "${CYAN}Next Steps:${NC}"
echo -e "${GRAY}1. Restart Claude Desktop/CLI to load the MCP tools${NC}"
echo -e "${GRAY}2. Verify tools work: kimi mcp list${NC}"
echo -e "${GRAY}3. If bpftrace needed, install from: https://bpftrace.org${NC}"
echo ""
echo -e "${CYAN}Testing commands:${NC}"
echo -e "${GRAY}   kimi 'Compile the eBPF program in bpf/dwell_monitor.bpf.c'${NC}"
echo -e "${GRAY}   kimi 'Verify eBPF bytecode passes kernel safety checks'${NC}"
echo -e "${GRAY}   kimi 'Help debug the dwell_tracker map logic'${NC}"
