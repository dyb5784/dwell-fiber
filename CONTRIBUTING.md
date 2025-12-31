# Contributing to Dwell-Fiber

## Development Environment

### Required Tools
- Go 1.21 or later
- LLVM/Clang 16.0+
- Linux kernel headers (≥ 5.15)
- Coq 8.16 or later
- GNU Make

### Optional Tools
- kubectl for K8s deployment
- perf for performance analysis
- graphviz for visualization

## Getting Started

1. **Fork & Clone**
```bash
git clone https://github.com/YOUR_USERNAME/dwell-fiber.git
cd dwell-fiber
```

2. **Set Up Environment**
```bash
# Fix asm/types.h symlink (critical!)
chmod +x scripts/fix-asm-symlink.sh
sudo ./scripts/fix-asm-symlink.sh
```

3. **Build & Test**
```bash
make all
make verify
make test
```

## Code Style

### Go
- Use `gofmt`
- Follow [Effective Go](https://golang.org/doc/effective_go.html)
- Run `golangci-lint run` before commits

### C (eBPF)
- Follow kernel coding style
- Use `clang-format`
- Check with `sparse`

### Coq
- Follow [Coq coding guidelines](https://coq.inria.fr/refman/practical-tools/coq-coding-guidelines.html) and repository conventions in AGENTS.md
- Ensure proofs complete in < 1s
- See AGENTS.md "Coq Proof Strategies That Work Well" for proven tactics and patterns
- Run `./scripts/coq-verify-enhanced.sh` for comprehensive verification with statistics

## Pull Request Process

1. Create a feature branch
2. Update documentation
3. Add tests
4. Run CI checks locally
5. Open PR with clear description

## Documentation

- Update relevant `.md` files
- Keep ASCII diagrams up-to-date
- Document performance impacts

## Testing

```bash
# Run all tests
make test

# Run specific test
go test ./pkg/... -run TestName

# Run eBPF and Coq verification
make verify
./scripts/coq-verify-enhanced.sh  # Enhanced verification with stats

# Benchmark with performance thresholds
make bench
# See AGENTS.md "Performance Benchmarks to Maintain" for thresholds
```

## Release Process

1. Update version numbers
2. Run full test suite: `make all && make test && make verify`
3. Verify performance benchmarks (see AGENTS.md)
4. Update CHANGELOG.md with changes
5. Update AGENTS.md if adding new features that affect benchmarks or strategies
6. Create tagged release
7. For production deployments, follow AGENTS.md "Deployment Procedures for Production Systems"

## AI Agent Development

When working with Claude or other AI agents on this codebase:
- Reference [AGENTS.md](AGENTS.md) for comprehensive technical guidance
- Use MCP tools for eBPF and Coq development assistance
- Follow repository conventions documented in `.claude/instructions.md`
- Use provided Claude skills in `.claude/skills/` for Coq proof development
- Reference performance benchmarks and proof strategies from AGENTS.md

## Code of Conduct

Please follow my [Code of Conduct](CODE_OF_CONDUCT.md).