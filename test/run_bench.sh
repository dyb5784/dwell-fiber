#!/usr/bin/env bash
set -euo pipefail
if [ -z "${1-}" ]; then
  ITERS=100000
else
  ITERS=$1
fi
mkdir -p test
cc -O2 -o test/syscall_bench test/syscall_bench.c
echo "Running syscall benchmark: iterations=${ITERS}"
./test/syscall_bench ${ITERS}
