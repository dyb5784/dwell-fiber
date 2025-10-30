#!/usr/bin/env bash
set -euo pipefail

echo "Building artifacts"
make all

echo "Starting daemon in background (short budget for test)"
# This script assumes you run it inside a VM where sudo is available.
sudo ./bin/dwell-fiber-daemon --alpha=0.5 --budget=1.0 &
DAEMON_PID=$!
echo "Daemon PID: ${DAEMON_PID}"

echo "Running minimal workload: write, sleep, extend"
python3 - <<'PY'
import time
f='test_e2e_file.txt'
with open(f,'w') as fh:
    fh.write('start\n')
time.sleep(2)
with open(f,'a') as fh:
    fh.write('end\n')
print('Workload completed')
PY

echo "Give the daemon a second to process events"
sleep 1
echo "Stopping daemon"
sudo kill ${DAEMON_PID} || true
echo "Check system logs (e.g., /var/log/syslog) for enforcement events and metrics."
