#!/usr/bin/env bash
# Minimal system performance snapshot (simple, portable)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG_DIR="$REPO_ROOT/logs"
LOG_FILE="$LOG_DIR/system_monitor.log"

mkdir -p "$LOG_DIR"

TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
SEP="$(printf '=%.0s' {1..72})"

echo "$SEP" >> "$LOG_FILE"
echo "Timestamp: $TS" >> "$LOG_FILE"
echo "Uptime: $(uptime -p 2>/dev/null || echo 'N/A')" >> "$LOG_FILE"

# Load average (1m 5m 15m)
if [ -r /proc/loadavg ]; then
  awk '{print "Load averages (1m 5m 15m): " $1 " " $2 " " $3}' /proc/loadavg >> "$LOG_FILE" 2>/dev/null || true
else
  uptime | awk -F'load average:' '{print "Load averages: " $2}' >> "$LOG_FILE" 2>/dev/null || true
fi

# Memory
if command -v free >/dev/null 2>&1; then
  free -h >> "$LOG_FILE" 2>/dev/null || true
fi

# Disk usage
df -h --total | head -n 20 >> "$LOG_FILE" 2>/dev/null || true

# Top processes (by CPU)
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 20 >> "$LOG_FILE" 2>/dev/null || true

exit 0
