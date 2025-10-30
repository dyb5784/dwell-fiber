TESTING and Validation Plan (alpha → beta)

This document describes a small, focused plan to verify that Dwell-Fiber builds and behaves correctly on a Linux test environment (VirtualBox/Ubuntu or WSL) and to move from an alpha pre-release to a beta once verification passes.

Goals
- Build and run the daemon and eBPF programs on Ubuntu 24.04
- Verify Coq proofs compile and the stability checks run
- Validate basic end-to-end behavior on a small test workload
- Measure (repeatable) performance and document results

Quick environment (VirtualBox / Ubuntu 24.04)
1. Create or boot an Ubuntu 24.04 VM (recommended: 2 CPUs, 4GB RAM)
2. Install build dependencies:

```bash
sudo apt-get update
sudo apt-get install -y clang llvm libbpf-dev linux-headers-$(uname -r) golang-go coq make git
```

3. Clone and prepare the repository:

```bash
git clone https://github.com/dyb5784/dwell-fiber.git
cd dwell-fiber
chmod +x scripts/fix-asm-symlink.sh
sudo ./scripts/fix-asm-symlink.sh
```

Build & basic checks
1. Build all artifacts:

```bash
make all
```

2. Verify Coq proofs (may take some time):

```bash
make verify
```

3. Run the daemon (test mode) and check logs:

```bash
sudo ./bin/dwell-fiber-daemon --alpha=0.5 --budget=5.0
# In another terminal: tail -f /var/log/syslog  # or the project logs if configured
```

Minimal end-to-end test
- Start a short script that opens and writes to a file, then sleeps beyond the configured budget and observe that enforcement triggers (throttle/kill/metric emission).
- Verify Prometheus metrics (if enabled) show `dwell_seconds_current` and dual price metrics.

Performance & measurement
- Use `perf stat` or simple time measurements to capture syscall overhead for a controlled microbenchmark. Run each measurement multiple times and report median + IQR.

Stability & regression checks
- Re-run `make verify` after any code changes that affect the Coq proofs.
- Add a small unit/integration test under `test/` reproducing the minimal end-to-end script above.

Release criteria for beta
- Successful build and run on Ubuntu 24.04 VM with all high-level components exercising enforcement.
- Coq proofs verify on the target machine.
- Minimal tests (unit + integration) pass in CI or locally.
- Documented performance measurements and how they were produced.

How to report results
- Create an issue titled "alpha test results" and paste logs, commands, and measurement outputs.
- If tests fail, attach a small reproducer and the output of `uname -a`, `go version`, `clang --version`.

Notes
- This is a short checklist to get you started. Expand the tests and add CI jobs once the VM tests are reliable.
