# 🤖 MCP Tools for Dwell-Fiber Development

This guide covers setting up MCP (Model Context Protocol) tools for enhanced eBPF development workflow with Claude Desktop/CLI.

## Overview

MCP tools provide Claude with specialized capabilities for kernel and formal verification development:

### eBPF Development Tools
- **`ebpf-tools`**: eBPF compilation, verification, and static analysis
- **`bpftrace`**: eBPF program debugging and runtime analysis

### Coq Formal Verification Tools
- **`coq-assistant`**: Coq proof assistant integration and proof guidance
- **`proof-validator`**: Mathematical proof checking and validation

## Prerequisites

### eBPF Tools
- **Node.js and npm**: Required for `npx` to run `ebpf-dev-tools`
- **bpftrace**: For eBPF runtime debugging and analysis
- **sudo access**: Required for privileged eBPF operations
- **jq**: For JSON processing (Linux/macOS script)

### Coq Tools
- **Node.js and npm**: Required for `coq-mcp-server`
- **Coq 9.1+**: For formal proof compilation (required for coq-assistant)
- **Coq libraries**: Reals, List, Lia, Lra, Psatz
- **Optional**: ssreflect, ssrbool for advanced tactics

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

**Complete Configuration (eBPF + Coq):**
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
    },
    "coq-assistant": {
      "command": "npx",
      "args": ["coq-mcp-server@latest"],
      "transport": "stdio"
    },
    "proof-validator": {
      "url": "https://proof-checker.mcp.io",
      "transport": "http"
    }
  }
}
```

**Coq Tools Only:**
```json
{
  "mcpServers": {
    "coq-assistant": {
      "command": "npx",
      "args": ["coq-mcp-server@latest"],
      "transport": "stdio"
    },
    "proof-validator": {
      "url": "https://proof-checker.mcp.io",
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

### eBPF Tools

```bash
# List available MCP tools
kimi mcp list

# Compile eBPF program with MCP assistance
kimi "Compile the dwell_monitor.bpf.c program and check for warnings"

# Verify eBPF bytecode
kimi "Verify the eBPF bytecode satisfies kernel safety requirements"

# Debug eBPF program
kimi "Help me trace the dwell_monitor eBPF program with bpftrace"
```

### Coq Tools

```bash
# Check Coq proof installation
kimi "Verify Coq is properly installed with all dependencies"

# Get help with proof tactics
kimi "I'm trying to prove an inequality about total_dwell. What tactics should I use?"

# Look up lemma statements
kimi "What does lemma price_nonnegative state?"

# Fix Coq compilation errors
kimi "Coq error: Unknown tactic bdestruct. How do I fix this?"

# Run comprehensive verification
kimi "Run the enhanced Coq verification script and show me statistics"
```

## Code Structure

### eBPF Programs

Located in: `bpf/`
- **`bpf/dwell_monitor.bpf.c`**: Main eBPF program tracking file dwell times
- **`bpf_dwell*.c`**: Legacy versions (V1.x-V2.x)

Key components tracked:
- File open/close events via tracepoints
- Process dwell time calculation
- Economic budgeting via ADMM controller
- Ring buffer event submission to userspace

### Coq Formal Proofs

Located in: `coq/`
- **`coq/dwell_stable.v`**: ADMM stability proofs
- **`coq/dwell_kernel_resilience.v`**: Event loss resilience with bounded patterns
- **`coq/dwell_extended.v`**: Liveness, fairness, attack resistance
- **`coq/test_resilience.v`**: Test cases and validation

Key properties proven:
- Price non-negativity and boundedness
- ADMM convergence with step size bounds (0 < α < 2)
- Bounded event loss resilience (≤10% loss rate, ≤5 burst)
- System stability under adversarial conditions

Supporting files:
- **`coq-signatures.md`**: Generated index of all lemmas and theorems
- **`.claude/skills/`**: Claude skills for proof assistance
  - `coq-lemma-fetch`: Quick lemma lookup
  - `coq-proof-tactics`: Tactic suggestions
  - `coq-bugfix`: Compilation error fixes

## Troubleshooting

### eBPF Tools

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

### Coq Tools

**coq-assistant not connecting?**
- Ensure Node.js is installed: `node --version`
- Install coq-mcp-server: `npm install -g coq-mcp-server`
- Verify Coq installation: `coqc --version`
- Check required Coq libraries are available

**proof-validator placeholder?**
- The proof-validator URL is currently a placeholder
- Replace with actual proof checking service endpoint when available
- Update in Claude config or modify `claude-mcp-config.json`

**Coq compilation errors?**
- Use enhanced verification script: `./scripts/coq-verify-enhanced.sh --verbose`
- Consult `.claude/skills/coq-bugfix/` for common error fixes
- Check lemma signatures: `coq-signatures.md`

**Claude skills not activating?**
- Verify `.claude/instructions.md` exists
- Check `.claude/skills/` directory structure
- Ensure skills have correct YAML frontmatter
- Restart Claude Desktop/CLI

**Need help?**
```bash
# Run setup with --help for options
.\scripts\setup-mcp-tools.ps1 --help          # eBPF setup
.\scripts\setup-coq-mcp-tools.ps1 --help     # Coq setup
.\scripts\coq-verify-enhanced.sh --help      # Coq verification
./scripts/setup-mcp-tools.sh --help
```

## Security Considerations

### eBPF Tools

⚠️ **Important**: The `ebpf-tools` MCP uses sudo for privileged eBPF operations. 

- Review the `ebpf-dev-tools` package before running
- Consider using a dedicated development environment
- The MCP configuration requires explicit `sudo` in the command chain

### Coq Tools

⚠️ **Note**: The `coq-assistant` and `proof-validator` tools interact with Coq proofs.

- Coq proofs are mathematical guarantees - verify tool trustworthiness
- The `coq-mcp-server` may execute Coq compilation commands
- Review proof validator service before submitting sensitive verification tasks
- Consider local verification (`coqchk`) for critical proofs

**Best Practices:**
- Use MCP tools for development assistance, not final verification
- Run `make verify` or `./scripts/coq-verify-enhanced.sh` for authoritative checks
- Keep sensitive proofs locally, use MCP tools for strategy and debugging
- Validate external proof checkers against local Coq installation

## Additional Resources

### eBPF Development
- [eBPF Documentation](docs/ebpf.md) - Dwell-Fiber eBPF architecture
- [Development Guide](CONTRIBUTING.md) - General development workflow

### Coq Formal Verification
- [Coq Installation Guide](COQ_INSTALLATION.md) - Coq setup instructions
- [Claude Skills Guide](.claude/skills/README.md) - Proof development skills
- [Verification Scripts](scripts/coq-verify-enhanced.sh) - Enhanced verification
- [Lemma Signatures](coq-signatures.md) - Proof index

### MCP Protocol
- [MCP Specification](https://modelcontextprotocol.io/) - Official protocol docs
- [claude-mcp-config.json](claude-mcp-config.json) - Reference configuration

## Related Branches

- **eBPF Tools**: `feature/mcp-ebpf-tools` - MCP tools for eBPF development
- **Coq Skills**: `feature/coq-formal-verification-skills` - Coq proof assistance
