# Dwell-Fiber: AI Agent Development Guide

**Ransomware Defense Through Proven-Stable Economic Enforcement**

---

## Project Overview

Dwell-Fiber is a sophisticated ransomware defense system that uses **ADMM optimization** (Alternating Direction Method of Multipliers) to detect and stop ransomware attacks by monitoring file access patterns. The system operates at kernel-level using eBPF with minimal performance overhead.

### Core Technology Stack

- **Language**: Go 1.23+ (userspace daemon)
- **Kernel Programming**: eBPF/C (kernel-level monitoring)
- **Formal Verification**: Coq 9.1+ (mathematical proofs)
- **Platform**: Linux (Ubuntu 25.10 recommended)
- **Metrics**: Prometheus + Web Dashboard

### Architecture Versions

- **V2.x (Production)**: Dwell-time based detection (5-second budget)
- **V3.0 (Development)**: Rate-based detection for intermittent encryption

---

## Repository Structure

```
dwell-fiber/
├── bpf/                    # eBPF kernel programs
│   ├── dwell_monitor.bpf.c # Main BPF program for file monitoring
│   └── Makefile           # BPF compilation
├── daemon/                 # Go userspace daemon
│   ├── main.go            # Entry point and CLI flags
│   ├── controller.go      # ADMM controller logic
│   ├── bpf_monitor.go     # BPF event processing
│   ├── enforcement.go     # Process throttling/killing
│   ├── metrics.go         # Prometheus metrics
│   └── test_suite.go      # Built-in test scenarios
├── pkg/                    # Go packages
│   ├── bpf/               # BPF loader utilities
│   ├── enforcement/       # Enforcement mechanisms
│   └── pricing/           # ADMM pricing algorithms
├── coq/                    # Formal verification proofs
│   ├── dwell_stable.v     # ADMM stability proof
│   ├── dwell_kernel_resilience.v  # Kernel event resilience
│   ├── dwell_extended.v   # Liveness and fairness proofs
│   └── Makefile          # Coq compilation
├── scripts/               # Setup and utility scripts
│   ├── setup-mcp-tools.ps1       # eBPF MCP setup
│   ├── setup-coq-mcp-tools.ps1   # Coq MCP setup
│   └── coq-verify-enhanced.sh    # Enhanced verification
├── docs/                  # Documentation
├── test/                  # Integration testing
└── .claude/              # Claude configuration & skills
    ├── instructions.md          # Coq conventions
    └── skills/                  # Claude skills
        ├── coq-lemma-fetch/
        ├── coq-proof-tactics/
        └── coq-bugfix/
```

---

## Build and Development Commands

### Quick Build
```bash
make all          # Build BPF + Coq + Daemon
make verify       # Verify Coq proofs
make test         # Run Go tests
make clean        # Clean all build artifacts
```

### Component-Specific Builds
```bash
make bpf          # Compile eBPF programs only
make coq          # Compile Coq proofs only
make daemon       # Build Go daemon only
```

### Running the System
```bash
# Observation mode (safe, default)
sudo ./bin/dwell-fiber-daemon --alpha=0.5 --budget=5.0

# With enforcement enabled (caution)
sudo ./bin/dwell-fiber-daemon --enable-enforcement --enable-killing

# Simulation mode (no root required)
./bin/dwell-fiber-daemon --simulate

# Test enforcement logic
./bin/dwell-fiber-daemon --test-enforcement
```

---

## Performance Benchmarks to Maintain

### System Overhead Requirements
The following performance benchmarks must be maintained across all releases:

#### Latency Benchmarks
- **Per-file operation overhead**: ≤ 100 nanoseconds
- **BPF event processing**: < 1 millisecond end-to-end
- **ADMM pricing update**: < 500 microseconds
- **Enforcement decision**: < 10 milliseconds
- **Dashboard metric refresh**: 1 second interval

#### CPU Utilization Benchmarks
- **Observation mode**: < 1% of one CPU core
- **Enforcement mode**: < 3% of one CPU core
- **BPF program execution**: < 0.1% CPU per 1000 events/sec
- **Prometheus metrics collection**: < 0.5% CPU

#### Memory Utilization Benchmarks
- **Daemon resident memory**: 12-18 MB (per metrics endpoint)
- **BPF map memory**: ≤ 10 MB total (all maps combined)
- **Per-process tracking**: ~1.5 KB per monitored process
- **Maximum supported processes**: 10,240 (limited by BPF map size)

#### Event Processing Benchmarks
- **Event ingestion rate**: > 10,000 events/second
- **Sustained workload**: Tested with 100 concurrent file operations
- **Peak burst handling**: 50,000 events without loss (test with `--test-enforcement`)
- **Controller update frequency**: Every 100ms (hardcoded in daemon)

### Performance Regression Testing
```bash
# Run performance benchmark suite
./test/performance/benchmark.sh

# Key metrics to verify:
# - Latency histogram: 95th percentile < 150ns
# - CPU profile: < 2% total in steady state
# - Memory profile: No unbounded growth
# - Event throughput: > 8,000 events/sec sustained
```

### Critical Paths to Optimize
1. **BPF ring buffer read**: Must be non-blocking, use `ringbuf_reserve` correctly
2. **Price update calculation**: Keep ADMM formula simple: `price + α × (dwell - budget)`
3. **Process lookup**: Hash table must be O(1), verify `BPF_MAP_TYPE_HASH` performance
4. **Enforcement checks**: Cache whitelist decisions, avoid repeated system calls
5. **Prometheus metrics**: Use counters, avoid gauge calculations in hot paths

---

## Coq Proof Strategies That Work Well

### Established Proof Patterns

#### 1. ADMM Price Boundedness Proofs
**Strategy**: Linear arithmetic + monotonicity
```coq
Theorem price_bounded :
  forall p d, 0 <= p -> 0 <= budget -> price p d <= max_price.
Proof.
  intros p d Hp Hbudget.
  unfold price_update.
  (* Key insight: price increases when dwell > budget, decreases otherwise *)
  destruct (Rle_dec d budget) as [Hle | Hgt].
  - (* d <= budget *)
    lra.  (* Linear real arithmetic solves *)
  - (* d > budget *)
    apply Rmax_l.  (* max(0, something) >= 0 *)
    lra.
Qed.
```
**Why this works**: The ADMM update rule has a simple structure that LRA can solve automatically.

#### 2. Event Stream Induction Proofs
**Strategy**: Structural induction with case analysis
```coq
Theorem bounded_loss_preserves_dwell_bound :
  forall (stream : event_stream) (pattern : list loss_pattern),
  valid_loss_pattern stream pattern ->
  total_dwell stream <= max_dwell ->
  total_dwell (apply_loss stream pattern) <= max_dwell.
Proof.
  intros stream pattern Hvalid Hbound.
  (* Structural induction on the stream *)
  induction stream as [| e stream' IH].
  - (* Base case: empty stream *)
    simpl. assumption.
  - (* Inductive case: event :: stream *)
    simpl. destruct pattern as [| p pattern'] eqn:Hpat.
    + (* No pattern remaining *)
      lra.
    + (* Pattern has head *)
      destruct p as [ | ] eqn:Hp.
      * (* Keep the event *)
        simpl. lra.
      * (* Drop the event *)
        apply IH. assumption.
Qed.
```
**Why this works**: Event streams are recursive data structures; induction naturally matches the stream shape.

#### 3. Convergence Proofs Using Lyapunov Functions
**Strategy**: Find suitable Lyapunov function, prove decreasing
```coq
Theorem admm_convergence :
  exists V : state -> R,
  forall s, V s >= 0 /\
  (forall s s', transition s s' -> V s' <= V s).
Proof.
  exists (fun s => (price s - optimal_price)²).
  intros s. split.
  - (* V(s) >= 0 *)
    apply pow2_ge_0.
  - (* V decreases *)
    unfold transition, price_update.
    (* Key: (p - p*)² decreases when step size α is in (0, 2) *)
    psatz R.  (* Polynomial constraint solver *)
Qed.
```
**Why this works**: ADMM on convex problems has quadratic Lyapunov functions; `psatz R` handles polynomial constraints.

#### 4. Boolean Reflection Proofs
**Strategy**: Destruct boolean operators, use equations
```coq
Theorem price_update_correct :
  forall p d,
  let new_price := price_update p d in
  (new_price >= 0) = true.
Proof.
  intros p d. unfold price_update. simpl.
  destruct (0 <=? p + alpha * (d - budget)) eqn:Hbool.
  - (* Boolean comparison true *)
    apply Rle_bool_true in Hbool. lra.
  - (* Boolean comparison false *)
    apply Rle_bool_false in Hbool. lra.
Qed.
```
**Why this works**: Boolean reflection bridges computational and logical views; exploiting the equation is powerful.

### Tactics That Consistently Work

#### Quick Reference by Goal Type

| Goal Type | Primary Tactic | Secondary Tactic | Why |
|-----------|----------------|------------------|-----|
| Inequalities (R) | `lra` | `psatz R` | Fast, automatic real arithmetic |
| Inequalities (nat/Z) | `lia` | `omega` | Integer arithmetic with Coq 9.1+ |
| List properties | `induction` | `simpl; rewrite` | Structure matches recursion |
| Event streams | `induction` | `destruct pattern` | Matches stream ADT |
| Algebraic equalities | `ring_simplify` | `field_simplify` | Ring/field normalization |
| Boolean comparisons | `bdestruct` | `destruct ... eqn:` | Exploits boolean reflection |
| Logical connectives | `split` / `intros` | `left` / `right` | Direct propositional logic |
| Quantifiers | `intros` | `exists witness` | Standard quantifier rules |

### Custom Tactics We've Found Effective

```coq
Ltac solve_dwell_inequality :=
  unfold total_dwell, price_update; simpl;
  lra.

Ltac case_analysis_bool H :=
  bdestruct H; try lra; try assumption.
```

**When to use**: 
- `solve_dwell_inequality` - When dealing with dwell time sums and price updates
- `case_analysis_bool H` - When `H` is a boolean expression affecting the proof

### Common Pitfalls to Avoid

1. **Overcomplicating**: If `lra` or `lia` works, don't manually case analyze
2. **Wrong induction principle**: Use standard structural induction for streams, not well-founded
3. **Forgetting to unfold**: Always `unfold` definitions before automation
4. **Deep nesting**: If proof has > 4 levels of bullets, consider extracting lemmas
5. **Missing imports**: Always `From Coq Require Import Lia, Lra` at top

### Successful Proof Structures

```coq
Theorem example_successful_proof : ...
Proof.
  (* 1. Introduce variables and hypotheses *)
  intros x y Hx Hy.
  
  (* 2. Unfold definitions to expose structure *)
  unfold price_update, total_dwell.
  
  (* 3. Case analysis on critical boolean conditions *)
  destruct (dwell <? budget) eqn:Hcase.
  
  (* 4. Use automation where possible *)
  - (* Case: dwell < budget *)
    simpl. lra.
  
  (* 5. Manual reasoning where automation fails *)
  - (* Case: dwell >= budget *)
    (* Provide explicit reasoning *)
    apply Rle_trans with (y := intermediate_value).
    + lra.
    + assumption.
Qed.
```

**Key insight**: Start simple (intros, unfold), use automation (lra/lia), manual steps only when needed.

---

## eBPF Debugging Techniques

### BPF Program Loading Issues

#### Problem: BPF program fails to load
**Common cause**: BPF verifier rejection

**Debugging steps**:
```bash
# 1. Check kernel logs
dmesg | grep -i bpf | tail -20

# 2. Enable BPF verifier debugging
sudo sysctl -w kernel.printk=8
cd bpf && make clean && make

# 3. Use bpf_vmlinux.h generation
# Ensure BTF is available: cat /sys/kernel/btf/vmlinux

# 4. Check specific verifier error
# Look for: "invalid mem access", "unbounded loop", etc.
```

**Common fixes**:
- **Unbounded loop**: Add explicit upper bound check
- **Invalid map access**: Verify key exists before lookup
- **Stack overflow**: Reduce local variables, use per-CPU arrays
- **Type mismatch**: Use CO-RE field accessors: `BPF_CORE_READ()`

#### Example: Fixing verifier error in dwell_monitor.bpf.c
```c
// Problematic code:
#pragma unroll
for (int i = 0; i < MAX_FILENAME; i++) {
    if (filename[i] == '\0') break;
    event->filename[i] = filename[i];
}

// Fixed code:
#pragma unroll
for (int i = 0; i < MAX_FILENAME && i < 256; i++) {
    if (i >= MAX_FILENAME) break;  // Explicit bound
    if (filename[i] == '\0') break;
    event->filename[i] = filename[i];
}
```

### Runtime BPF Debugging

#### Using bpftrace (when available)
```bash
# Monitor all BPF map operations
sudo bpftrace -e 'tracepoint:bpf:bpf_map_lookup_elem { printf("Lookup: map=%d\n", args->map_id); }'

# Trace dwell time calculations
sudo bpftrace -e 'kprobe:vfs_write { @bytes[pid] = sum(arg2); }'

# Monitor enforcement decisions
sudo bpftrace -e 'tracepoint:raw_syscalls:sys_enter_kill { printf("Kill: pid=%d\n", args->id); }'
```

#### Using bpftool (always available)
```bash
# List all BPF programs
sudo bpftool prog list

# Show map contents
sudo bpftool map dump id <map_id>

# Trace BPF program execution
sudo bpftool prog dump xlated id <prog_id>

# Monitor map stats
sudo bpftool map show id <map_id>
```

#### Attaching to running daemon
```bash
# Find dwell-fiber daemon PID
PID=$(pgrep dwell-fiber-daemon)

# Trace BPF syscalls from daemon
strace -p $PID -e bpf

# Monitor ring buffer reads
trace-cmd record -p function_graph -g "*bpf*" -P $PID
```

### Debugging Event Flow

#### Adding BPF printks (for development only)
```c
// Add temporary debug logs
bpf_printk("DEBUG: pid=%d, fd=%d, timestamp=%llu\n",
           pid, fd, bpf_ktime_get_ns());

// Check logs
cat /sys/kernel/debug/tracing/trace_pipe | grep DEBUG
```

**Important**: Remove bpf_printk calls before production (performance impact)

#### Using the ring buffer for debugging
```c
// Create debug ring buffer
struct {
    __uint(type, BPF_MAP_TYPE_RINGBUF);
    __uint(max_entries, 256 * 1024);
} debug_events SEC(".maps");

// Submit debug events
struct debug_event *e = bpf_ringbuf_reserve(&debug_events, sizeof(*e), 0);
if (e) {
    e->pid = pid;
    e->timestamp = bpf_ktime_get_ns();
    bpf_ringbuf_submit(e, 0);
}
```

### Performance Debugging

#### Measuring BPF overhead
```bash
# Baseline measurement (BPF unloaded)
./perf_test.sh --no-bpf

# With BPF loaded
./perf_test.sh --with-bpf

# Compare latency histograms
# Acceptable: < 100ns median difference, < 150ns p95
```

#### Checking map performance
```bash
# Track map operations per second
cat /sys/kernel/debug/tracing/events/bpf_map/enable
cat /sys/kernel/debug/tracing/trace_pipe | grep bpf_map_update

# Acceptable: < 10,000 ops/sec normal, spikes to 50,000 during burst
```

#### Detecting ring buffer drops
```bash
# Monitor for lost events
# In bpf_monitor.go, log: stats.LostSamples
grep "Lost events" /var/log/syslog

# Acceptable: < 0.1% event loss under sustained load
# Investigate if: > 1% sustained loss
```

### Common BPF Debugging Workflow

```bash
# 1. Check if BPF programs are loaded
sudo bpftool prog list | grep dwell

# 2. Verify maps are populated
sudo bpftool map list | grep dwell

# 3. Check ring buffer for events
# Add temporary: cat /sys/kernel/debug/tracing/trace_pipe

# 4. Trace specific functions
# In dwell_monitor.bpf.c, identify failing tracepoint
dmesg | grep "tracepoint"

# 5. Use bpf_printk for detailed state
# Add debug prints before ringbuf_submit()
# Check: cat /sys/kernel/debug/tracing/trace_pipe

# 6. When fixed, remove debug prints and verify performance
make clean && make bpf
time ./bpf/perf_test.sh
```

### Simulator Mode Debugging
```bash
# Run in simulation (no root needed)
./bin/dwell-fiber-daemon --simulate --verbose

# Check logs for synthetic event generation
# Verify: "Simulating normal workload" messages

# Generate specific scenarios
./bin/dwell-fiber-daemon --simulate --scenario attack --duration 60s
```

---

## Deployment Procedures for Production Systems

### Pre-Deployment Checklist

#### System Requirements Verification
- [ ] **Kernel**: Linux 5.10+ (with BTF support)
- [ ] **Distribution**: Ubuntu 25.10 or RHEL 9.0+
- [ ] **Architecture**: x86_64 (ARM64 experimental)
- [ ] **Resources**: 2GB RAM, 1GB disk space free
- [ ] **BPF support**: Verify `CONFIG_BPF_SYSCALL=y` in kernel config
- [ ] **BTF support**: Check `/sys/kernel/btf/vmlinux` exists

#### Security Prerequisites
- [ ] **Capabilities**: `CAP_BPF`, `CAP_PERFMON`, `CAP_SYS_ADMIN`
- [ ] **SELinux**: Set to permissive mode or create policy
- [ ] **AppArmor**: Disable or create profile for dwell-fiber
- [ ] **Firewall**: Port 9090 allowed (dashboard access)

#### Not Currently Ready for Production
⚠️ **Critical**: The following features are still in development:
1. **V3.0 intermittent encryption detection** - Not yet implemented
2. **WIP metric integration** - Work in progress
3. **TCM (Trust Classification Module)** - Planned but not started
4. **Rate-based detection** - Design phase only

**Current Production Readiness**: V2.x dwell-time detection only

### Production Installation

#### Step 1: Install Dependencies
```bash
# Ubuntu/Debian
apt-get update
apt-get install -y libbpf-dev llvm clang build-essential
apt-get install -y coq coq-mathcomp-ssreflect

# RHEL/CentOS
dnf install -y libbpf-devel llvm clang gcc make kernel-devel
dnf install -y coq

# Verify Coq 9.1+
coqc --version
```

#### Step 2: Build from Source
```bash
git clone https://github.com/dyb5784/dwell-fiber.git
cd dwell-fiber
make all

# Verify build
ls -lh bin/dwell-fiber-daemon
ls -lh bpf/dwell_monitor.bpf.o
```

#### Step 3: Installation
```bash
sudo mkdir -p /opt/dwell-fiber/bin
sudo mkdir -p /opt/dwell-fiber/bpf
sudo mkdir -p /etc/dwell-fiber

sudo cp bin/dwell-fiber-daemon /opt/dwell-fiber/bin/
sudo cp bpf/dwell_monitor.bpf.o /opt/dwell-fiber/bpf/
sudo cp configs/production.yaml /etc/dwell-fiber/config.yaml

# Set capabilities (alternative to running as root)
sudo setcap cap_bpf,cap_perfmon,cap_sys_admin+ep /opt/dwell-fiber/bin/dwell-fiber-daemon
```

### Systemd Service Configuration

Create `/etc/systemd/system/dwell-fiber.service`:

```ini
[Unit]
Description=Dwell-Fiber Ransomware Defense
After=network.target
Before=multi-user.target

[Service]
Type=simple
User=root
ExecStart=/opt/dwell-fiber/bin/dwell-fiber-daemon \
    --config=/etc/dwell-fiber/config.yaml \
    --alpha=0.5 \
    --budget=5.0 \
    --enable-enforcement

# Security settings
NoNewPrivileges=false
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/var/log/dwell-fiber

# Restart policy
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl daemon-reload
sudo systemctl enable dwell-fiber
sudo systemctl start dwell-fiber
```

### Configuration Management

#### Production Config Template (`/etc/dwell-fiber/config.yaml`)
```yaml
# Dwell-Fiber Production Configuration

daemon:
  # ADMM parameters
  alpha: 0.5                    # Step size (0.1 - 1.0)
  budget: 5.0                   # Dwell budget in seconds
  controller_interval: 100ms    # Update frequency

enforcement:
  # Enable enforcement (disable for observation-only)
  enable_throttling: true
  enable_killing: true
  
  # Thresholds
  throttle_threshold: 5.0       # CPU throttle when dwell > 5s
  kill_threshold: 15.0          # Kill process when dwell > 15s
  
  # Whitelist (never enforce these processes)
  protected_processes:
    - systemd
    - sshd
    - dbus-daemon
    - NetworkManager
    - Xorg
    - wayland
    - gdm
    - dwell-fiber-daemon

bpf:
  # BPF map sizes
  max_processes: 10240          # Max concurrent tracked processes
  ringbuf_size: 262144          # Ring buffer size (256KB)
  
  # Filters
  min_significant_dwell: 2.0    # Ignore events below this threshold
  noise_threshold: 0.1          # Drop events below this

metrics:
  # Prometheus endpoint
  enabled: true
  address: ":9090"
  path: "/metrics"

logging:
  level: "info"                 # debug, info, warn, error
  file: "/var/log/dwell-fiber/daemon.log"
  max_size: 100MB
  max_backups: 5
```

### Operational Runbooks

#### Scenario 1: Suspected False Positive
1. **Disable enforcement immediately**:
   ```bash
   sudo systemctl reload dwell-fiber  # Or edit config
   ```

2. **Check logs for killed process**:
   ```bash
   sudo grep "Killed process" /var/log/dwell-fiber/daemon.log
   ```

3. **Review metrics dashboard**:
   - Access http://localhost:9090
   - Check "Recently Killed Processes"
   - Verify dwell time exceeded threshold

4. **Add to whitelist if legitimate**:
   ```bash
   echo "process_name" >> /etc/dwell-fiber/protected_processes.txt
   sudo systemctl restart dwell-fiber
   ```

#### Scenario 2: Performance Degradation
1. **Check BPF overhead**:
   ```bash
   sudo bpftool prog show | grep dwell
   # Verify run_cnt is reasonable (< 1M ops/sec)
   ```

2. **Monitor ring buffer drops**:
   ```bash
   sudo grep "Lost events" /var/log/dwell-fiber/daemon.log
   # If > 100/sec, increase ringbuf_size in config
   ```

3. **Profile daemon CPU**:
   ```bash
   sudo perf top -p $(pgrep dwell-fiber-daemon)
   # Should show < 5% CPU usage
   ```

4. **Check system load**:
   ```bash
   uptime
   top -p $(pgrep dwell-fiber-daemon)
   ```

#### Scenario 3: Coq Proof Failure in Update
1. **Run verification in isolation**:
   ```bash
   cd /opt/dwell-fiber/src
   make coq
   ```

2. **Check which proof failed**:
   ```bash
   cd coq && coqc -R . DwellFiber dwell_stable.v 2>&1 | grep Error
   ```

3. **Review error type**:
   - **Type mismatch**: Check lemma statement matches implementation
   - **Unknown tactic**: Verify Coq 9.1+ and required libraries
   - **Unfinished proof**: Revert to previous working version

4. **Emergency fallback**:
   ```bash
   git checkout v1.4.2 -- coq/  # Revert to last verified version
   make coq && make daemon
   sudo systemctl restart dwell-fiber
   ```

### Monitoring and Alerting

#### Prometheus Alerts
```yaml
# Create /etc/prometheus/rules/dwell-fiber.yml
groups:
  - name: dwell-fiber
    rules:
      - alert: HighEventLossRate
        expr: rate(dwell_fiber_events_lost_total[5m]) > 0.01
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "High BPF event loss detected"
          
      - alert: ExcessiveKillRate
        expr: rate(dwell_fiber_processes_killed_total[5m]) > 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High process kill rate - possible false positives"
          
      - alert: DaemonDown
        expr: up{job="dwell-fiber"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Dwell-Fiber daemon is down"
```

### Upgrade Procedures

#### Minor Version Upgrade (e.g., 1.4.2 → 1.4.3)
```bash
# 1. Backup configuration
cp /etc/dwell-fiber/config.yaml /etc/dwell-fiber/config.yaml.bak

# 2. Download and build new version
cd /opt/dwell-fiber/src
git pull origin main
make clean && make all

# 3. Dry-run verification
./bin/dwell-fiber-daemon --simulate --verbose --duration 60s

# 4. Install and restart
sudo cp bin/dwell-fiber-daemon /opt/dwell-fiber/bin/
sudo systemctl restart dwell-fiber

# 5. Verify functionality
sleep 30
curl -s localhost:9090/metrics | grep dwell_fiber
```

#### Major Version Upgrade (e.g., 1.4.x → 1.5.x)
1. **Review release notes** for breaking changes
2. **Test in staging environment** for 1 week
3. **Verify Coq proofs** compile with new version
4. **Update configuration** for new parameters
5. **Schedule maintenance window** (5 minutes downtime)
6. **Follow minor upgrade steps** with rollback plan ready

### Rollback Procedures

#### Immediate Rollback (System Issues)
```bash
# Emergency stop
sudo systemctl stop dwell-fiber
sudo systemctl disable dwell-fiber

# Restore previous version (example)
sudo cp /opt/dwell-fiber/bin/dwell-fiber-daemon.v1.4.2 \
        /opt/dwell-fiber/bin/dwell-fiber-daemon
        
sudo systemctl start dwell-fiber
```

#### Configuration Rollback
```bash
# Restore backed up configuration
sudo cp /etc/dwell-fiber/config.yaml.bak /etc/dwell-fiber/config.yaml
sudo systemctl restart dwell-fiber
```

### Security Hardening

#### AppArmor Profile (Ubuntu)
Create `/etc/apparmor.d/dwell-fiber`:
```apparmor
#include <tunables/global>

/opt/dwell-fiber/bin/dwell-fiber-daemon {
  #include <abstractions/base>
  
  capability bpf,
  capability perfmon,
  capability sys_admin,
  
  /opt/dwell-fiber/** r,
  /var/log/dwell-fiber/ rw,
  /sys/kernel/btf/vmlinux r,
  /sys/kernel/debug/tracing/ rw,
}
```

Enable:
```bash
sudo apparmor_parser -r /etc/apparmor.d/dwell-fiber
sudo systemctl restart apparmor
```

### Known Production Limitations

**⚠️ V2.x Production Readiness Assessment:**

**Ready for Production**:
✅ Dwell-time based ransomware detection
✅ Process throttling and killing
✅ ADMM-based adaptive pricing
✅ Prometheus metrics and dashboard
✅ Comprehensive logging
✅ Protected process whitelist

**Not Ready for Production**:
❌ **Intermittent encryption detection** (LockBit 3.0+ style)
❌ **WIP metric integration** (design phase)
❌ **TCM (Trust Classification Module)** (planned)
❌ **Rate-based detection** (not implemented)
❌ **Formal verification of complete system** (60% complete)

**Recommendation**: Use V2.x for traditional ransomware (full-file encryption). V3.0 features still under active research and development.

### Disaster Recovery

#### Complete System Failure (BPF corruption)
```bash
# 1. Stop daemon
sudo systemctl stop dwell-fiber

# 2. Unload all BPF programs
sudo bpftool prog show | grep dwell | awk '{print $1}' | \
  xargs -I {} sudo bpftool prog detach {}

# 3. Remove pinned BPF maps
sudo rm -rf /sys/fs/bpf/dwell-fiber/

# 4. Restart daemon (cleans state)
sudo systemctl start dwell-fiber
```

#### Data Recovery
- **BPF maps**: Ephemeral, state lost on restart
- **Logs**: Rotate daily, stored in `/var/log/dwell-fiber/`
- **Metrics**: Prometheus persistent storage recommended
- **Configuration**: Backup `/etc/dwell-fiber/config.yaml`

### Support and Troubleshooting

#### Collect Diagnostic Data
```bash
#!/bin/bash
# Create diagnostic bundle for support

tarball="dwell-fiber-diag-$(date +%Y%m%d-%H%M%S).tar.gz"

sudo mkdir -p /tmp/dwell-diag
cd /tmp/dwell-diag

# Collect logs
sudo journalctl -u dwell-fiber --since "24 hours ago" > daemon.log 2>&1

# Collect configs
sudo cp /etc/dwell-fiber/config.yaml ./ 2>/dev/null || true

# Collect BPF info
sudo bpftool prog list > bpf-progs.txt 2>&1
sudo bpftool map list > bpf-maps.txt 2>&1

# Collect daemon metrics
curl -s localhost:9090/metrics > metrics.txt 2>/dev/null || echo "Metrics unavailable" > metrics.txt

# System info
uname -a > system-info.txt
cat /proc/version >> system-info.txt
dpkg -l | grep -E "(libbpf|llvm|clang)" > packages.txt || rpm -qa | grep -E "(libbpf|llvm|clang)" > packages.txt

# Create bundle
tar -czf $tarball *.txt *.yaml *.log 2>/dev/null

echo "Diagnostic bundle created: /tmp/dwell-diag/$tarball"
```

#### Contact Information
- **GitHub Issues**: Bug reports and feature requests
- **Maintainer Email**: Available on GitHub profile
- **Security Issues**: Follow responsible disclosure via email
- **Commercial Support**: Contact maintainer for enterprise support options

---

## Performance Benchmarks to Maintain

### System Overhead Requirements
The following performance benchmarks must be maintained across all releases:

#### Latency Benchmarks
- **Per-file operation overhead**: ≤ 100 nanoseconds
- **BPF event processing**: < 1 millisecond end-to-end
- **ADMM pricing update**: < 500 microseconds
- **Enforcement decision**: < 10 milliseconds
- **Dashboard metric refresh**: 1 second interval

#### CPU Utilization Benchmarks
- **Observation mode**: < 1% of one CPU core
- **Enforcement mode**: < 3% of one CPU core
- **BPF program execution**: < 0.1% CPU per 1000 events/sec
- **Prometheus metrics collection**: < 0.5% CPU

#### Memory Utilization Benchmarks
- **Daemon resident memory**: 12-18 MB (per metrics endpoint)
- **BPF map memory**: ≤ 10 MB total (all maps combined)
- **Per-process tracking**: ~1.5 KB per monitored process
- **Maximum supported processes**: 10,240 (limited by BPF map size)

#### Event Processing Benchmarks
- **Event ingestion rate**: > 10,000 events/second
- **Sustained workload**: Tested with 100 concurrent file operations
- **Peak burst handling**: 50,000 events without loss (test with `--test-enforcement`)
- **Controller update frequency**: Every 100ms (hardcoded in daemon)

### Performance Regression Testing
```bash
# Run performance benchmark suite
./test/performance/benchmark.sh

# Key metrics to verify:
# - Latency histogram: 95th percentile < 150ns
# - CPU profile: < 2% total in steady state
# - Memory profile: No unbounded growth
# - Event throughput: > 8,000 events/sec sustained
```

### Critical Paths to Optimize
1. **BPF ring buffer read**: Must be non-blocking, use `ringbuf_reserve` correctly
2. **Price update calculation**: Keep ADMM formula simple: `price + α × (dwell - budget)`
3. **Process lookup**: Hash table must be O(1), verify `BPF_MAP_TYPE_HASH` performance
4. **Enforcement checks**: Cache whitelist decisions, avoid repeated system calls
5. **Prometheus metrics**: Use counters, avoid gauge calculations in hot paths

---

## Coq Proof Strategies That Work Well

### Established Proof Patterns

#### 1. ADMM Price Boundedness Proofs
**Strategy**: Linear arithmetic + monotonicity
```coq
Theorem price_bounded :
  forall p d, 0 <= p -> 0 <= budget -> price p d <= max_price.
Proof.
  intros p d Hp Hbudget.
  unfold price_update.
  (* Key insight: price increases when dwell > budget, decreases otherwise *)
  destruct (Rle_dec d budget) as [Hle | Hgt].
  - (* d <= budget *)
    lra.  (* Linear real arithmetic solves *)
  - (* d > budget *)
    apply Rmax_l.  (* max(0, something) >= 0 *)
    lra.
Qed.
```
**Why this works**: The ADMM update rule has a simple structure that LRA can solve automatically.

#### 2. Event Stream Induction Proofs
**Strategy**: Structural induction with case analysis
```coq
Theorem bounded_loss_preserves_dwell_bound :
  forall (stream : event_stream) (pattern : list loss_pattern),
  valid_loss_pattern stream pattern ->
  total_dwell stream <= max_dwell ->
  total_dwell (apply_loss stream pattern) <= max_dwell.
Proof.
  intros stream pattern Hvalid Hbound.
  (* Structural induction on the stream *)
  induction stream as [| e stream' IH].
  - (* Base case: empty stream *)
    simpl. assumption.
  - (* Inductive case: event :: stream *)
    simpl. destruct pattern as [| p pattern'] eqn:Hpat.
    + (* No pattern remaining *)
      lra.
    + (* Pattern has head *)
      destruct p as [ | ] eqn:Hp.
      * (* Keep the event *)
        simpl. lra.
      * (* Drop the event *)
        apply IH. assumption.
Qed.
```
**Why this works**: Event streams are recursive data structures; induction naturally matches the stream shape.

#### 3. Convergence Proofs Using Lyapunov Functions
**Strategy**: Find suitable Lyapunov function, prove decreasing
```coq
Theorem admm_convergence :
  exists V : state -> R,
  forall s, V s >= 0 /\
  (forall s s', transition s s' -> V s' <= V s).
Proof.
  exists (fun s => (price s - optimal_price)²).
  intros s. split.
  - (* V(s) >= 0 *)
    apply pow2_ge_0.
  - (* V decreases *)
    unfold transition, price_update.
    (* Key: (p - p*)² decreases when step size α is in (0, 2) *)
    psatz R.  (* Polynomial constraint solver *)
Qed.
```
**Why this works**: ADMM on convex problems has quadratic Lyapunov functions; `psatz R` handles polynomial constraints.

#### 4. Boolean Reflection Proofs
**Strategy**: Destruct boolean operators, use equations
```coq
Theorem price_update_correct :
  forall p d,
  let new_price := price_update p d in
  (new_price >= 0) = true.
Proof.
  intros p d. unfold price_update. simpl.
  destruct (0 <=? p + alpha * (d - budget)) eqn:Hbool.
  - (* Boolean comparison true *)
    apply Rle_bool_true in Hbool. lra.
  - (* Boolean comparison false *)
    apply Rle_bool_false in Hbool. lra.
Qed.
```
**Why this works**: Boolean reflection bridges computational and logical views; exploiting the equation is powerful.

### Tactics That Consistently Work

#### Quick Reference by Goal Type

| Goal Type | Primary Tactic | Secondary Tactic | Why |
|-----------|----------------|------------------|-----|
| Inequalities (R) | `lra` | `psatz R` | Fast, automatic real arithmetic |
| Inequalities (nat/Z) | `lia` | `omega` | Integer arithmetic with Coq 9.1+ |
| List properties | `induction` | `simpl; rewrite` | Structure matches recursion |
| Event streams | `induction` | `destruct pattern` | Matches stream ADT |
| Algebraic equalities | `ring_simplify` | `field_simplify` | Ring/field normalization |
| Boolean comparisons | `bdestruct` | `destruct ... eqn:` | Exploits boolean reflection |
| Logical connectives | `split` / `intros` | `left` / `right` | Direct propositional logic |
| Quantifiers | `intros` | `exists witness` | Standard quantifier rules |

### Custom Tactics We've Found Effective

```coq
Ltac solve_dwell_inequality :=
  unfold total_dwell, price_update; simpl;
  lra.

Ltac case_analysis_bool H :=
  bdestruct H; try lra; try assumption.
```

**When to use**: 
- `solve_dwell_inequality` - When dealing with dwell time sums and price updates
- `case_analysis_bool H` - When `H` is a boolean expression affecting the proof

### Common Pitfalls to Avoid

1. **Overcomplicating**: If `lra` or `lia` works, don't manually case analyze
2. **Wrong induction principle**: Use standard structural induction for streams, not well-founded
3. **Forgetting to unfold**: Always `unfold` definitions before automation
4. **Deep nesting**: If proof has > 4 levels of bullets, consider extracting lemmas
5. **Missing imports**: Always `From Coq Require Import Lia, Lra` at top

### Successful Proof Structures

```coq
Theorem example_successful_proof : ...
Proof.
  (* 1. Introduce variables and hypotheses *)
  intros x y Hx Hy.
  
  (* 2. Unfold definitions to expose structure *)
  unfold price_update, total_dwell.
  
  (* 3. Case analysis on critical boolean conditions *)
  destruct (dwell <? budget) eqn:Hcase.
  
  (* 4. Use automation where possible *)
  - (* Case: dwell < budget *)
    simpl. lra.
  
  (* 5. Manual reasoning where automation fails *)
  - (* Case: dwell >= budget *)
    (* Provide explicit reasoning *)
    apply Rle_trans with (y := intermediate_value).
    + lra.
    + assumption.
Qed.
```

**Key insight**: Start simple (intros, unfold), use automation (lra/lia), manual steps only when needed.

---

## eBPF Debugging Techniques

### BPF Program Loading Issues

#### Problem: BPF program fails to load
**Common cause**: BPF verifier rejection

**Debugging steps**:
```bash
# 1. Check kernel logs
dmesg | grep -i bpf | tail -20

# 2. Enable BPF verifier debugging
sudo sysctl -w kernel.printk=8
cd bpf && make clean && make

# 3. Use bpf_vmlinux.h generation
# Ensure BTF is available: cat /sys/kernel/btf/vmlinux

# 4. Check specific verifier error
# Look for: "invalid mem access", "unbounded loop", etc.
```

**Common fixes**:
- **Unbounded loop**: Add explicit upper bound check
- **Invalid map access**: Verify key exists before lookup
- **Stack overflow**: Reduce local variables, use per-CPU arrays
- **Type mismatch**: Use CO-RE field accessors: `BPF_CORE_READ()`

#### Example: Fixing verifier error in dwell_monitor.bpf.c
```c
// Problematic code:
#pragma unroll
for (int i = 0; i < MAX_FILENAME; i++) {
    if (filename[i] == '\\0') break;
    event->filename[i] = filename[i];
}

// Fixed code:
#pragma unroll
for (int i = 0; i < MAX_FILENAME && i < 256; i++) {
    if (i >= MAX_FILENAME) break;  // Explicit bound
    if (filename[i] == '\\0') break;
    event->filename[i] = filename[i];
}
```

### Runtime BPF Debugging

#### Using bpftrace (when available)
```bash
# Monitor all BPF map operations
sudo bpftrace -e 'tracepoint:bpf:bpf_map_lookup_elem { printf("Lookup: map=%d\\n", args->map_id); }'

# Trace dwell time calculations
sudo bpftrace -e 'kprobe:vfs_write { @bytes[pid] = sum(arg2); }'

# Monitor enforcement decisions
sudo bpftrace -e 'tracepoint:raw_syscalls:sys_enter_kill { printf("Kill: pid=%d\\n", args->id); }'
```

#### Using bpftool (always available)
```bash
# List all BPF programs
sudo bpftool prog list

# Show map contents
sudo bpftool map dump id <map_id>

# Trace BPF program execution
sudo bpftool prog dump xlated id <prog_id>

# Monitor map stats
sudo bpftool map show id <map_id>
```

#### Attaching to running daemon
```bash
# Find dwell-fiber daemon PID
PID=$(pgrep dwell-fiber-daemon)

# Trace BPF syscalls from daemon
strace -p $PID -e bpf

# Monitor ring buffer reads
trace-cmd record -p function_graph -g "*bpf*" -P $PID
```

### Debugging Event Flow

#### Adding BPF printks (for development only)
```c
// Add temporary debug logs
bpf_printk("DEBUG: pid=%d, fd=%d, timestamp=%llu\\n",
           pid, fd, bpf_ktime_get_ns());

// Check logs
cat /sys/kernel/debug/tracing/trace_pipe | grep DEBUG
```

**Important**: Remove bpf_printk calls before production (performance impact)

#### Using the ring buffer for debugging
```c
// Create debug ring buffer
struct {
    __uint(type, BPF_MAP_TYPE_RINGBUF);
    __uint(max_entries, 256 * 1024);
} debug_events SEC(".maps");

// Submit debug events
struct debug_event *e = bpf_ringbuf_reserve(&debug_events, sizeof(*e), 0);
if (e) {
    e->pid = pid;
    e->timestamp = bpf_ktime_get_ns();
    bpf_ringbuf_submit(e, 0);
}
```

### Performance Debugging

#### Measuring BPF overhead
```bash
# Baseline measurement (BPF unloaded)
./perf_test.sh --no-bpf

# With BPF loaded
./perf_test.sh --with-bpf

# Compare latency histograms
# Acceptable: < 100ns median difference, < 150ns p95
```

#### Checking map performance
```bash
# Track map operations per second
cat /sys/kernel/debug/tracing/events/bpf_map/enable
cat /sys/kernel/debug/tracing/trace_pipe | grep bpf_map_update

# Acceptable: < 10,000 ops/sec normal, spikes to 50,000 during burst
```

#### Detecting ring buffer drops
```bash
# Monitor for lost events
# In bpf_monitor.go, log: stats.LostSamples
grep "Lost events" /var/log/dwell-fiber/daemon.log

# Acceptable: < 0.1% event loss under sustained load
# Investigate if: > 1% sustained loss
```

### Common BPF Debugging Workflow

```bash
# 1. Check if BPF programs are loaded
sudo bpftool prog list | grep dwell

# 2. Verify maps are populated
sudo bpftool map list | grep dwell

# 3. Check ring buffer for events
# Add temporary: cat /sys/kernel/debug/tracing/trace_pipe

# 4. Trace specific functions
# In dwell_monitor.bpf.c, identify failing tracepoint
dmesg | grep "tracepoint"

# 5. Use bpf_printk for detailed state
# Add debug prints before ringbuf_submit()
# Check: cat /sys/kernel/debug/tracing/trace_pipe

# 6. When fixed, remove debug prints and verify performance
make clean && make bpf
time ./bpf/perf_test.sh
```

### Simulator Mode Debugging
```bash
# Run in simulation (no root needed)
./bin/dwell-fiber-daemon --simulate --verbose

# Check logs for synthetic event generation
# Verify: "Simulating normal workload" messages

# Generate specific scenarios
./bin/dwell-fiber-daemon --simulate --scenario attack --duration 60s
```

---

## Deployment Procedures for Production Systems

### Pre-Deployment Checklist

#### System Requirements Verification
- [ ] **Kernel**: Linux 5.10+ (with BTF support)
- [ ] **Distribution**: Ubuntu 25.10 or RHEL 9.0+
- [ ] **Architecture**: x86_64 (ARM64 experimental)
- [ ] **Resources**: 2GB RAM, 1GB disk space free
- [ ] **BPF support**: Verify `CONFIG_BPF_SYSCALL=y` in kernel config
- [ ] **BTF support**: Check `/sys/kernel/btf/vmlinux` exists

#### Security Prerequisites
- [ ] **Capabilities**: `CAP_BPF`, `CAP_PERFMON`, `CAP_SYS_ADMIN`
- [ ] **SELinux**: Set to permissive mode or create policy
- [ ] **AppArmor**: Disable or create profile for dwell-fiber
- [ ] **Firewall**: Port 9090 allowed (dashboard access)

#### Not Currently Ready for Production
⚠️ **Critical**: The following features are still in development:
1. **V3.0 intermittent encryption detection** - Not yet implemented
2. **WIP metric integration** - Work in progress
3. **TCM (Trust Classification Module)** - Planned but not started
4. **Rate-based detection** - Design phase only

**Current Production Readiness**: V2.x dwell-time detection only

### Production Installation

#### Step 1: Install Dependencies
```bash
# Ubuntu/Debian
apt-get update
apt-get install -y libbpf-dev llvm clang build-essential
apt-get install -y coq coq-mathcomp-ssreflect
# Verify Coq 9.1+
coqc --version
```

#### Step 2: Build from Source
```bash
git clone https://github.com/dyb5784/dwell-fiber.git
cd dwell-fiber
make all
# Verify build
ls -lh bin/dwell-fiber-daemon
ls -lh bpf/dwell_monitor.bpf.o
```

#### Step 3: Installation
```bash
sudo mkdir -p /opt/dwell-fiber/bin
sudo mkdir -p /opt/dwell-fiber/bpf
sudo mkdir -p /etc/dwell-fiber

sudo cp bin/dwell-fiber-daemon /opt/dwell-fiber/bin/
sudo cp bpf/dwell_monitor.bpf.o /opt/dwell-fiber/bpf/
sudo cp configs/production.yaml /etc/dwell-fiber/config.yaml

# Set capabilities (alternative to running as root)
sudo setcap cap_bpf,cap_perfmon,cap_sys_admin+ep /opt/dwell-fiber/bin/dwell-fiber-daemon
```

### Systemd Service Configuration

Create `/etc/systemd/system/dwell-fiber.service`:

```ini
[Unit]
Description=Dwell-Fiber Ransomware Defense
After=network.target
Before=multi-user.target

[Service]
Type=simple
User=root
ExecStart=/opt/dwell-fiber/bin/dwell-fiber-daemon \
    --config=/etc/dwell-fiber/config.yaml \
    --alpha=0.5 \
    --budget=5.0 \
    --enable-enforcement

# Security settings
NoNewPrivileges=false
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/var/log/dwell-fiber

# Restart policy
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl daemon-reload
sudo systemctl enable dwell-fiber
sudo systemctl start dwell-fiber
```

### Configuration Management

#### Production Config Template (`/etc/dwell-fiber/config.yaml`)
```yaml
# Dwell-Fiber Production Configuration

daemon:
  # ADMM parameters
  alpha: 0.5                    # Step size (0.1 - 1.0)
  budget: 5.0                   # Dwell budget in seconds
  controller_interval: 100ms    # Update frequency

enforcement:
  # Enable enforcement (disable for observation-only)
  enable_throttling: true
  enable_killing: true
  
  # Thresholds
  throttle_threshold: 5.0       # CPU throttle when dwell > 5s
  kill_threshold: 15.0          # Kill process when dwell > 15s
  
  # Whitelist (never enforce these processes)
  protected_processes:
    - systemd
    - sshd
    - dbus-daemon
    - NetworkManager
    - Xorg
    - wayland
    - gdm
    - dwell-fiber-daemon

bpf:
  # BPF map sizes
  max_processes: 10240          # Max concurrent tracked processes
  ringbuf_size: 262144          # Ring buffer size (256KB)
  
  # Filters
  min_significant_dwell: 2.0    # Ignore events below this
  noise_threshold: 0.1          # Drop events below this

metrics:
  # Prometheus endpoint
  enabled: true
  address: ":9090"
  path: "/metrics"

logging:
  level: "info"                 # debug, info, warn, error
  file: "/var/log/dwell-fiber/daemon.log"
  max_size: 100MB
  max_backups: 5
```

### Not Currently Ready for Production

**Critical**: The following features are still in development:
1. **V3.0 intermittent encryption detection** - Not yet implemented (design phase)
2. **WIP metric integration** - Work in progress (Coq proofs incomplete)
3. **TCM (Trust Classification Module)** - Planned but not started
4. **Rate-based detection** - Design phase only

**Current Production Readiness**: V2.x dwell-time detection only

### Operational Runbooks

#### Scenario 1: Suspected False Positive
1. **Disable enforcement immediately**:
   ```bash
   sudo systemctl reload dwell-fiber  # Or edit config
   ```

2. **Check logs for killed process**:
   ```bash
   sudo grep "Killed process" /var/log/dwell-fiber/daemon.log
   ```

3. **Review metrics dashboard**:
   - Access http://localhost:9090
   - Check "Recently Killed Processes"
   - Verify dwell time exceeded threshold

4. **Add to whitelist if legitimate**:
   ```bash
   echo "process_name" >> /etc/dwell-fiber/protected_processes.txt
   sudo systemctl restart dwell-fiber
   ```

### Monitoring and Alerting

#### Prometheus Alerts
```yaml
# Create /etc/prometheus/rules/dwell-fiber.yml
groups:
  - name: dwell-fiber
    rules:
      - alert: HighEventLossRate
        expr: rate(dwell_fiber_events_lost_total[5m]) > 0.01
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "High BPF event loss detected"
          
      - alert: ExcessiveKillRate
        expr: rate(dwell_fiber_processes_killed_total[5m]) > 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High process kill rate - possible false positives"
```

### Upgrade Procedures

#### Minor Version Upgrade (e.g., 1.4.2 → 1.4.3)
```bash
# 1. Backup configuration
cp /etc/dwell-fiber/config.yaml /etc/dwell-fiber/config.yaml.bak

# 2. Download and build new version
cd /opt/dwell-fiber/src
git pull origin main
make clean && make all

# 3. Dry-run verification
./bin/dwell-fiber-daemon --simulate --verbose --duration 60s

# 4. Install and restart
sudo cp bin/dwell-fiber-daemon /opt/dwell-fiber/bin/
sudo systemctl restart dwell-fiber

# 5. Verify functionality
sleep 30
curl -s localhost:9090/metrics | grep dwell_fiber
```

### Rollback Procedures

#### Immediate Rollback (System Issues)
```bash
# Emergency stop
sudo systemctl stop dwell-fiber
sudo systemctl disable dwell-fiber

# Restore previous version (example)
sudo cp /opt/dwell-fiber/bin/dwell-fiber-daemon.v1.4.2 \
        /opt/dwell-fiber/bin/dwell-fiber-daemon
        
sudo systemctl start dwell-fiber
```

### Security Hardening

#### AppArmor Profile (Ubuntu)
Create `/etc/apparmor.d/dwell-fiber`:
```apparmor
#include <tunables/global>

/opt/dwell-fiber/bin/dwell-fiber-daemon {
  #include <abstractions/base>
  
  capability bpf,
  capability perfmon,
  capability sys_admin,
  
  /opt/dwell-fiber/** r,
  /var/log/dwell-fiber/ rw,
  /sys/kernel/btf/vmlinux r,
  /sys/kernel/debug/tracing/ rw,
}
```

Enable:
```bash
sudo apparmor_parser -r /etc/apparmor.d/dwell-fiber
sudo systemctl restart apparmor
```

### Known Production Limitations

**⚠️ V2.x Production Readiness Assessment:**

**Ready for Production**:
✅ Dwell-time based ransomware detection
✅ Process throttling and killing
✅ ADMM-based adaptive pricing
✅ Prometheus metrics and dashboard
✅ Comprehensive logging
✅ Protected process whitelist

**Not Ready for Production**:
❌ **Intermittent encryption detection** (LockBit 3.0+ style)
❌ **WIP metric integration** (Coq proofs incomplete, 60% done)
❌ **TCM (Trust Classification Module)** (planned, not started)
❌ **Rate-based detection** (design phase only)
❌ **Complete formal verification** (29/48 proofs, 60%)

**Recommendation**: Use V2.x for traditional ransomware (full-file encryption). V3.0 features still under active research and development.

### Support and Troubleshooting

#### Collect Diagnostic Data
```bash
#!/bin/bash
# Create diagnostic bundle for support

tarball="dwell-fiber-diag-$(date +%Y%m%d-%H%M%S).tar.gz"

sudo mkdir -p /tmp/dwell-diag
cd /tmp/dwell-diag

# Collect logs
sudo journalctl -u dwell-fiber --since "24 hours ago" > daemon.log 2>&1

# Collect configs
sudo cp /etc/dwell-fiber/config.yaml ./ 2>/dev/null || true

# Collect BPF info
sudo bpftool prog list > bpf-progs.txt 2>&1
sudo bpftool map list > bpf-maps.txt 2>&1

# Collect daemon metrics
curl -s localhost:9090/metrics > metrics.txt 2>/dev/null || echo "Metrics unavailable" > metrics.txt

# System info
uname -a > system-info.txt
cat /proc/version >> system-info.txt
dpkg -l | grep -E "(libbpf|llvm|clang)" > packages.txt || rpm -qa | grep -E "(libbpf|llvm|clang)" > packages.txt

# Create bundle
tar -czf $tarball *.txt *.yaml *.log 2>/dev/null

echo "Diagnostic bundle created: /tmp/dwell-diag/$tarball"
```

--- 

## Additional Resources

### Documentation
- [Installation Guide](docs/installation.md)
- [V2 Architecture](docs/v2-architecture.md)
- [V3 Roadmap](docs/v3-roadmap.md)
- [Coq Status](docs/coq_status.md)
- [Testing Guide](TESTING.md)
- [MCP Tools Guide](MCP_TOOLS.md)
- [Coq Skills Guide](.claude/skills/README.md)

### Academic References
- Doyle & Chiang (2007) - "Layering as optimization decomposition"
- Boyd et al. (2010) - ADMM optimization
- Dave Aitel (2016) - Dwell Time concept

### Community
- **Issues**: GitHub Issues for bug reports
- **Discussions**: Coming soon
- **Email**: See GitHub profile for maintainer contact

---

**Remember**: This is a defense-in-depth tool, not a replacement for comprehensive security solutions. Always test thoroughly in your environment before production deployment.