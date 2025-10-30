#!/bin/bash
# Fix the missing asm/types.h symlink issue on Ubuntu 24.04

set -e

echo "=== Fixing asm/types.h symlink issue ==="

if [ -L /usr/include/asm ]; then
    echo "✓ Symlink already exists"
    ls -la /usr/include/asm
    exit 0
fi

if [ -d /usr/include/asm ]; then
    echo "✗ /usr/include/asm exists but is a directory, not a symlink"
    echo "  This needs manual intervention. Please remove it first:"
    echo "  sudo rm -rf /usr/include/asm"
    exit 1
fi

echo "Creating symlink: /usr/include/asm -> /usr/include/x86_64-linux-gnu/asm"
sudo ln -sf /usr/include/x86_64-linux-gnu/asm /usr/include/asm

echo "✓ Symlink created successfully"
ls -la /usr/include/asm
echo ""
echo "You can now compile BPF programs."

