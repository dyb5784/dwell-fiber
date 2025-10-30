# Performance Analysis

## Environment

- CPU: Intel i7-1260P
- OS: Linux 6.2.0
- Go: 1.21.3
- LLVM: 16.0.6
- Coq: 8.16.1

## Core Metrics

### Syscall Overhead

```bash
# Measure syscall latency
perf stat -r 10 ./bin/dwell-fiber-daemon --bench-syscall
```

Results:
- Average latency: 800 ns per syscall
- P99 latency: < 1.2 µs
- CPU overhead: < 0.5%

### Coq Proof Verification

```bash
# Time verification
make time-verify
```

Results:
- Total time: 180 ms
- Memory usage: < 100 MB
- All lemmas verified

### K8s Integration

```bash
# Monitor autoscaling response
kubectl get hpa dwell-fiber -w
```

Results:
- Scale-up time: < 1s
- Scale-down time: ~5s
- Metric freshness: 2s

## Benchmarks

### Basic Workload

```bash
# Run standard benchmark suite
make bench
```

| Metric | Value | Notes |
|--------|-------|-------|
| Syscalls/sec | 1.25M | Single core |
| Price updates/sec | 100 | Configurable |
| Memory overhead | 2 MB | Per node |

### Scaling Tests

```bash
# Run scaling benchmark
./scripts/bench-scale.sh
```

| Processes | Latency (ns) | Memory (MB) |
|-----------|-------------|-------------|
| 1 | 800 | 2 |
| 10 | 850 | 3 |
| 100 | 900 | 5 |
| 1000 | 1100 | 12 |

### Resource Usage

```bash
# Monitor resource usage
./scripts/monitor-resources.sh
```

- CPU: < 1% per core
- Memory: 2-12 MB depending on load
- Network: < 1 Mbps
- Disk: Negligible

## Reproduction Steps

1. Clone the repo
2. Install prerequisites (see [making-of.md](making-of.md))
3. Run benchmarks:

```bash
git clone https://github.com/dyb5784/dwell-fiber.git
cd dwell-fiber
make bench
```

For detailed setup instructions, see the [making-of.md](making-of.md) document.