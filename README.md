# Dwell-Fiber

**Ransomware Defense Through Proven-Stable Economic Enforcement**

## Overview

Dwell-Fiber is a formally-verified eBPF-based system that prevents ransomware by enforcing file access budgets through economic pricing mechanisms. The system includes mathematical proofs of stability written in Coq.

## Key Features

- 🛡️ **Real-time Protection**: eBPF-based monitoring of file dwell times
- 📊 **Economic Enforcement**: ADMM-based pricing that adapts to process behavior
- ✅ **Formally Verified**: Coq proofs guarantee system stability
- 🚀 **Low Overhead**: Sub-millisecond latency impact
- 📈 **Observable**: Built-in Prometheus metrics

## Architecture

\\\
┌─────────────┐
│   eBPF      │  Monitor file dwell times
│  Kernel     │  (per-process tracking)
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Daemon     │  Price updates (ADMM)
│  (Go)       │  α = 0.5, budget = 5s
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Enforcement │  Throttle/kill processes
│   Engine    │  when dwell > budget
└─────────────┘

        Proven Stable
           (Coq)
\\\

## Quick Start

### Prerequisites (Ubuntu 24.04)

\\\ash
# Fix asm/types.h symlink issue (critical!)
sudo ln -sf /usr/include/x86_64-linux-gnu/asm /usr/include/asm

# Install dependencies
sudo apt-get update
sudo apt-get install -y \\
    clang llvm libbpf-dev linux-headers-\ \\
    golang-go coq make
\\\

### Build

\\\ash
make all          # Build everything
make verify       # Verify Coq proofs (180ms)
\\\

### Run

\\\ash
sudo ./bin/dwell-fiber-daemon --alpha=0.5 --budget=5.0
\\\

## Mathematical Guarantees

The system is proven to:
- ✅ Converge to optimal pricing in finite time
- ✅ Maintain dwell time ≤ 5 seconds
- ✅ Never diverge or oscillate indefinitely
- ✅ Work for any step size 0 < α < 2

See [docs/stability-proof.md](docs/stability-proof.md) for details.

## Repository Structure

\\\
dwell-fiber/
├── bpf/              # eBPF programs (C)
├── coq/              # Formal proofs
├── daemon/           # Main daemon (Go)
├── pkg/              # Reusable packages
├── scripts/          # Helper scripts
└── test/             # Tests
\\\

## Development

\\\ash
# Run tests
make test

# CI verification (runs in <1 second)
make ci

# Clean build artifacts
make clean
\\\

## License

MIT License - See [LICENSE](LICENSE)

## Citation

If you use Dwell-Fiber in research, please cite:

\\\ibtex
@software{dwell_fiber_2025,
  title = {Dwell-Fiber: Formally-Verified Ransomware Defense},
  author = {dyb5784},
  year = {2025},
  url = {https://github.com/dyb5784/dwell-fiber}
}
\\\

## Acknowledgments

Based on ADMM optimization theory and formal verification principles.

