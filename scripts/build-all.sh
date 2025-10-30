#!/bin/bash
set -e

echo "=== Building Dwell-Fiber ==="

# Check if asm symlink is fixed
if [ ! -L /usr/include/asm ]; then
    echo "ERROR: /usr/include/asm symlink not found"
    echo "Run: ./scripts/fix-asm-symlink.sh"
    exit 1
fi

# Build BPF
echo "Building BPF programs..."
make -C bpf

# Build Coq proofs
echo "Compiling Coq proofs..."
make -C coq

# Build Go daemon
echo "Building Go daemon..."
mkdir -p bin
cd daemon && go build -o ../bin/dwell-fiber-daemon .

echo "✓ Build complete!"
echo ""
echo "Binaries:"
echo "  ./bin/dwell-fiber-daemon"
echo ""
echo "To run:"
echo "  sudo ./bin/dwell-fiber-daemon --alpha=0.5 --budget=5.0"
