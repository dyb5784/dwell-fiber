# 🤖 MCP Tools for Dwell-Fiber Development

This guide covers setting up MCP (Model Context Protocol) tools for enhanced eBPF development workflow with Claude Desktop/CLI.

## Overview

MCP tools provide Claude with specialized capabilities for eBPF compilation, verification, and debugging:

- **`ebpf-tools`**: eBPF compilation, verification, and static analysis
- **`bpftrace`**: eBPF program debugging and runtime analysis

## Prerequisites

- **Node.js and npm**: Required for `npx` to run `ebpf-dev-tools`
- **bpftrace**: For eBPF runtime debugging and analysis
- **sudo access**: Required for privileged eBPF operations
- **jq**: For JSON processing (Linux/macOS script)

## Quick Setup

### Windows (PowerShell)

```powershell
# Run the setup script
.\scripts\setup-mcp-tools.ps1

# Or with custom options
.\scripts\setup-mcp-tools.ps1 -ConfigPath "$env:APPDATA\Claude\claude_desktop_config.json" -UseSudo
```

### Linux/macOS (Bash)

```bash
# Make script executable and run
chmod +x scripts/setup-mcp-tools.sh
./scripts/setup-mcp-tools.sh

# Or with custom options
./scripts/setup-mcp-tools.sh --config ~/.config/Claude/claude_desktop_config.json --dry-run
```

### Manual Configuration

If you prefer to configure manually, add this to your Claude configuration file:

```json
{
  "mcpServers": {
    "ebpf-tools": {
      "command": "sudo",
      "args": ["npx", "ebpf-dev-tools@latest"],
      "transport": "stdio"
    },
    "bpftrace": {
      "url": "https://bpftrace-mcp.example.com",
      "transport": "http"
    }
  }
}
```

## Configuration File Locations

- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`
- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Linux**: `~/.config/Claude/claude_desktop_config.json`

## Usage

After setup and restarting Claude:

```bash
# List available MCP tools
kimi mcp list

# Example: Compile eBPF program with MCP assistance
kimi "Compile the dwell_monitor.bpf.c program and check for warnings"

# Example: Verify eBPF bytecode
kimi "Verify the eBPF bytecode satisfies kernel safety requirements"

# Example: Debug eBPF program
kimi "Help me trace the dwell_monitor eBPF program with bpftrace"
```

## eBPF Code Structure

The eBPF programs are located in:
- **`bpf/dwell_monitor.bpf.c`**: Main eBPF program tracking file dwell times
- **`bpf_dwell*.c`**: Legacy versions (V1.x-V2.x)

Key components tracked:
- File open/close events via tracepoints
- Process dwell time calculation
- Economic budgeting via ADMM controller
- Ring buffer event submission to userspace

## Troubleshooting

**Tool not connecting?**
- Ensure Node.js is installed: `node --version`
- Check sudo access: `sudo -v`
- Verify Claude has restarted after config changes

**Permission errors?**
- eBPF requires sudo/root for kernel interaction
- The setup script uses sudo for `ebpf-dev-tools` by default

**bpftrace tool placeholder?**
- The bpftrace MCP endpoint is currently a placeholder
- Replace with actual endpoint when available:
  - Update `bpftrace.url` in your Claude config
  - Or modify `claude-mcp-config.json` in the project root

**Need help?**
```bash
# Run setup with --help for options.\scripts\setup-mcp-tools.ps1 --help
./scripts/setup-mcp-tools.sh --help
```

## Security Considerations

⚠️ **Important**: The `ebpf-tools` MCP uses sudo for privileged eBPF operations. 

- Review the `ebpf-dev-tools` package before running
- Consider using a dedicated development environment
- The MCP configuration requires explicit `sudo` in the command chain

## Additional Resources

- [eBPF Documentation](docs/ebpf.md) - Dwell-Fiber eBPF architecture
- [Development Guide](CONTRIBUTING.md) - General development workflow
- [MCP Protocol](https://modelcontextprotocol.io/) - MCP specification
