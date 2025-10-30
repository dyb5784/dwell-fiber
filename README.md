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

```
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
```

## Quick Start

### Prerequisites (Ubuntu 24.04)

```bash
# Fix asm/types.h symlink issue (critical!)
sudo ln -sf /usr/include/x86_64-linux-gnu/asm /usr/include/asm

# Install dependencies
sudo apt-get update
sudo apt-get install -y \
    clang llvm libbpf-dev linux-headers-$(uname -r) \
    golang-go coq make
```

### Build

```bash
make all          # Build everything
make verify       # Verify Coq proofs (may take a short while)
```

### Run

```bash
sudo ./bin/dwell-fiber-daemon --alpha=0.5 --budget=5.0
```

## Mathematical Guarantees

The system is proven to:
- ✅ Converge to optimal pricing in finite time
- ✅ Maintain dwell time ≤ 5 seconds
- ✅ Never diverge or oscillate indefinitely
- ✅ Work for any step size 0 < α < 2

See [docs/stability-proof.md](docs/stability-proof.md) for details.

## Repository Structure

```
dwell-fiber/
├── bpf/              # eBPF programs (C)
├── coq/              # Formal proofs
├── daemon/           # Main daemon (Go)
├── pkg/              # Reusable packages
├── scripts/          # Helper scripts
└── test/             # Tests
```

## Development

```bash
# Run tests
make test

# CI verification (fast)
make ci

# Clean build artifacts
make clean
```

### Windows / WSL

If you're on Windows, we recommend using Windows Subsystem for Linux (WSL) to build and run Dwell-Fiber. The project assumes a Linux toolchain (clang, make, kernel headers) and uses shell scripts and Makefiles.

Quick WSL steps:

```powershell
# Install WSL and Ubuntu (if not already installed)
wsl --install -d ubuntu:24.04

# In WSL (Ubuntu) shell, clone and build
git clone https://github.com/dyb5784/dwell-fiber.git
cd dwell-fiber
chmod +x scripts/fix-asm-symlink.sh
./scripts/fix-asm-symlink.sh
make all
```

If you prefer to stay in PowerShell, open a WSL shell using `wsl` and run the Linux commands there.

## License

MIT License - See [LICENSE](LICENSE)

## Citation

If you use Dwell-Fiber in research, please cite:

```bibtex
@software{dwell_fiber_2025,
  title = {Dwell-Fiber: Formally-Verified Ransomware Defense},
  author = {Daniyel Yaacov Bilar},
  year = {2025},
  url = {https://github.com/dyb5784/dwell-fiber}
}
```

## Acknowledgments

 I drew on optimization-decomposition ideas for network architectures (notably Doyle & Chiang, 2007) and the broader NUM literature, and integrated them with formal verification techniques. My personal Universal Decomposition Canon (a private thoughtbase of distilled heuristics) influenced the project's decomposition heuristics and sigil library used for sigil remapping.

 Key influences:
- Doyle & Chiang (2007) — "Layering as optimization decomposition" (see docs/overview.md)
Key influences:
- Doyle & Chiang (2007) — "Layering as optimization decomposition" (see docs/overview.md)

