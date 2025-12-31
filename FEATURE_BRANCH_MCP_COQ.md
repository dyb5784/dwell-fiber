# Feature Branch: Coq MCP Tools Integration

## Branch: `feature/coq-formal-verification-skills` (extended)

This extension adds Coq MCP (Model Context Protocol) tools for direct proof assistant integration and mathematical proof validation.

## 🆕 Added MCP Tools

### 1. `coq-assistant` (stdio transport)
- **Command**: `npx coq-mcp-server@latest`
- **Purpose**: Direct Coq proof assistant integration
- **Capabilities**:
  - Interactive proof guidance
  - Real-time error checking
  - Tactic suggestions
  - Proof state inspection
  - Automatic fix suggestions

### 2. `proof-validator` (http transport)
- **URL**: `https://proof-checker.mcp.io`
- **Purpose**: Mathematical proof checking service
- **Note**: Placeholder URL to be updated with actual service endpoint
- **Capabilities**:
  - Independent proof verification
  - Mathematical soundness checking
  - Automated proof validation

## 📦 New Files

### Configuration
- **`claude-mcp-config.json`**: Updated with all 4 MCP tools
  - ebpf-tools (existing)
  - bpftrace (existing)
  - coq-assistant (new)
  - proof-validator (new)

- **`scripts/setup-coq-mcp-tools.ps1`**: Setup script for Coq MCP tools
  - Windows PowerShell support
  - Configuration merging
  - Dry-run mode
  - User guidance

### Documentation
- **`MCP_TOOLS.md`**: Enhanced with Coq tools sections
  - Coq-specific prerequisites
  - Complete configuration examples
  - Usage examples for Coq assistance
  - Code structure (eBPF + Coq)
  - Troubleshooting for Coq tools
  - Security considerations for both tool types
  - Related resources and branches

## 🔧 Configuration Updates

### Complete MCP Setup

**All Tools Combined:**
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

**Setup Commands:**
```bash
# Windows (PowerShell)
.\scripts\setup-mcp-tools.ps1          # eBPF tools
.\scripts\setup-coq-mcp-tools.ps1      # Coq tools

# Linux/macOS (Bash)
./scripts/setup-mcp-tools.sh            # eBPF tools
./scripts/setup-mcp-tools.sh            # Coq tools (same script)
```

## 🎯 MCP Tools vs Claude Skills

### MCP Tools (External Services)
- **coq-assistant**: Direct Coq integration via `coq-mcp-server`
  - Real-time compilation and verification
  - Interactive proof development
  - External service dependency

- **proof-validator**: Independent proof checking service
  - Mathematical validation
  - Separate verification layer
  - Placeholder pending actual service

### Claude Skills (Local Intelligence)
- **coq-lemma-fetch**: Local lemma lookup
  - Fast signature-based search
  - No external dependencies
  - Works with generated `coq-signatures.md`

- **coq-proof-tactics**: Tactic suggestions
  - Repository convention aware
  - Pattern-based recommendations
  - Contextual understanding of Dwell-Fiber proofs

- **coq-bugfix**: Error analysis and fixes
  - Common error pattern recognition
  - Repository-specific fixes
  - Prevention strategies

**Best Practice**: Use MCP tools for real-time compilation/verification, Claude skills for guidance and learning.

## 💡 Usage Scenarios

### Scenario 1: Interactive Proof Development
```
User: "Help me prove bounded_loss_preserves_dwell_bound"
→ coq-assistant: Checks current proof state
→ coq-proof-tactics: Suggests induction and simplification
→ User: Implements suggestion
→ proof-validator: (when available) Verifies final proof
```

### Scenario 2: Error Debugging
```
User: "Coq compilation failed on dwell_stable.v line 45"
→ coq-assistant: Shows exact error and location
→ coq-bugfix: Analyzes error type and suggests fixes
→ User: Applies fix
→ coq-assistant: Recompiles and confirms success
```

### Scenario 3: Lemma Exploration
```
User: "What lemmas deal with price updates?"
→ coq-lemma-fetch: Searches signatures for price-related lemmas
→ Returns: price_nonnegative, price_bounded, etc. with statements
→ User: Uses lemmas in new proof
```

### Scenario 4: Verification Pipeline
```bash
# Terminal: Enhanced verification
./scripts/coq-verify-enhanced.sh

# Claude: Analyzes results
# Shows: 29/48 proofs complete, identifies failing proofs

# User: "Help me fix the failed proofs"
# → Claude uses skills + MCP tools to guide fixes
```

## 🔐 Security Considerations

### eBPF Tools
- **sudo access**: Required for privileged kernel operations
- **Action**: Review ebpf-dev-tools package
- **Practice**: Use dedicated development environment

### Coq Tools
- **Proof integrity**: MCP tools interact with mathematical proofs
- **coq-assistant**: May execute Coq compilation commands
- **proof-validator**: External service (when available)
- **Best practice**:
  - Use MCP for development assistance
  - Run local verification for final checks: `make verify`
  - Review external proof validators before sensitive verifications
  - Keep critical proofs local, use tools for guidance only

### General
- All MCP configurations stored in Claude config
- Credentials (if needed) managed by Claude
- No secrets in repository configurations (reference only)
- Individual developers can opt-in to specific tools

## 📊 Current Tool Status

| Tool | Status | Type | Note |
|------|--------|------|------|
| ebpf-tools | ✅ Configured | stdio | Uses sudo |
| bpftrace | ⚠️ Placeholder | http | Needs endpoint |
| coq-assistant | ✅ Configured | stdio | Requires coq-mcp-server |
| proof-validator | ⚠️ Placeholder | http | Needs endpoint |

## 🚀 Getting Started

### First-Time Setup

1. **Install prerequisites**
   ```bash
   # Check Node.js
   node --version
   
   # Check Coq
   coqc --version
   
   # Install coq-mcp-server
   npm install -g coq-mcp-server
   ```

2. **Set up MCP tools**
   ```bash
   # Windows
   .\scripts\setup-mcp-tools.ps1
   .\scripts\setup-coq-mcp-tools.ps1
   
   # Linux/macOS
   ./scripts/setup-mcp-tools.sh
   ./scripts/setup-coq-mcp-tools.sh
   ```

3. **Verify installation**
   ```bash
   kimi mcp list
   # Should show: ebpf-tools, bpftrace, coq-assistant, proof-validator
   ```

4. **Test with Coq proofs**
   ```bash
   kimi "Check Coq installation and show available lemmas"
   kimi "Compile and verify dwell_stable.v"
   ```

### Repository Configuration

**`claude-mcp-config.json`** now includes all 4 tools:
- Reference configuration at project root
- Can sync to local Claude config
- Documents tool setup for all developers

### Workflow Integration

**For eBPF Development:**
1. MCP tools: ebpf-tools, bpftrace
2. Use for: compilation, verification, debugging
3. Target: `bpf/dwell_monitor.bpf.c`

**For Coq Verification:**
1. MCP tools: coq-assistant, proof-validator
2. Claude skills: coq-lemma-fetch, coq-proof-tactics, coq-bugfix
3. Scripts: `./scripts/coq-verify-enhanced.sh`
4. Target: `coq/*.v` proofs

**Combined Workflow:**
```bash
# Set up all tools
.\scripts\setup-mcp-tools.ps1          # eBPF
.\scripts\setup-coq-mcp-tools.ps1      # Coq

# Restart Claude
# → All tools available

# Development
kimi "Help me with eBPF compilation"
kimi "Assist with Coq proof tactics"
```

## 📋 Commit Summary

**Branch**: `feature/coq-formal-verification-skills`

**Commits:**
1. `368001a` - Coq skills and enhanced verification (initial)
2. `a610cea` - Feature branch documentation
3. `d28ffc1` - Coq MCP tools configuration and docs (this extension)

**Files changed:** 11 files (+2,119 insertions)
- Added: `claude-mcp-config.json` (4 tools)
- Added: `scripts/setup-coq-mcp-tools.ps1`
- Modified: `MCP_TOOLS.md` (comprehensive updates)
- Branch now complete with eBPF + Coq tooling

## 🔗 Related Resources

- **Branch**: `feature/coq-formal-verification-skills`
- **Pull Request**: https://github.com/dyb5784/dwell-fiber/pull/new/feature/coq-formal-verification-skills
- **Coq Skills**: `.claude/skills/README.md`
- **eBPF Tools**: See `feature/mcp-ebpf-tools` branch
- **Main Docs**: [MCP_TOOLS.md](MCP_TOOLS.md)

## 🏁 Next Steps

1. **Set up local environment**
   - Run setup scripts
   - Install coq-mcp-server
   - Restart Claude

2. **Verify all tools**
   - `kimi mcp list` → should show 4 tools
   - Test eBPF compilation assistance
   - Test Coq proof guidance

3. **Complete proof development**
   - Use skills for remaining 19 proofs (40% left)
   - Apply combined MCP + skill assistance
   - Run enhanced verification regularly

4. **Update endpoints (when available)**
   - bpftrace URL
   - proof-validator URL
   - Test with actual services

5. **Integrate into workflow**
   - Document patterns that work
   - Share with team
   - Consider CI/CD integration

## ✅ Status

- ✅ All 4 MCP tools configured
- ✅ Setup scripts created (eBPF + Coq)
- ✅ Documentation comprehensive and updated
- ✅ Security considerations documented
- ✅ Branch pushed to origin
- ⏳ Waiting: Actual service endpoints for placeholder URLs

**Ready for**: Local testing and verification