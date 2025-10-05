#!/usr/bin/env python3
"""Monitor Docker containers and append status entries to logs/docker_monitor.log

Usage: run this script periodically (cron or systemd timer). It will create
the `logs` directory at the repo root if it does not exist and append a timestamped
snapshot of docker container statuses.
"""
from __future__ import annotations

import os
import subprocess
import datetime
#!/usr/bin/env python3
"""Monitor Docker containers and append status entries to logs/docker_monitor.log

Usage: run this script periodically (cron or systemd timer). It will create
the `logs` directory at the repo root if it does not exist and append a timestamped
snapshot of docker container statuses.
"""
from __future__ import annotations

import os
import subprocess
import datetime
import sys


def get_base_dir() -> str:
    # scripts/monitor_docker.py -> repo root is one level up
    return os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))


def ensure_logs_dir(base: str) -> str:
    logs_dir = os.path.join(base, "logs")
    os.makedirs(logs_dir, exist_ok=True)
    return logs_dir


def query_docker() -> tuple[bool, str]:
    """Return (ok, output). ok==True if docker command succeeded."""
    try:
        # use docker ps to list all containers with ID, name and status
        result = subprocess.run(
            ["docker", "ps", "-a", "--format", "{{.ID}}||{{.Names}}||{{.Status}}"],
            capture_output=True,
            text=True,
            check=False,
        )
    except FileNotFoundError:
        return False, "docker executable not found"

    if result.returncode != 0:
        # capture stderr if available
        err = result.stderr.strip() or "docker ps failed"
        return False, err

    return True, result.stdout.strip()


def write_log(log_path: str, ok: bool, output: str) -> None:
    now = datetime.datetime.utcnow().replace(microsecond=0).isoformat() + "Z"
    sep = "=" * 72
    with open(log_path, "a", encoding="utf-8") as f:
        f.write(f"{sep}\n")
        f.write(f"Timestamp: {now}\n")
        if not ok:
            f.write("ERROR: Docker query failed\n")
            f.write(output + "\n")
            return

        if not output:
            f.write("No containers found. (docker ps returned empty)\n")
            return

        # each line: ID||Name||Status
        for line in output.splitlines():
            parts = line.split("||")
            if len(parts) >= 3:
                cid, name, status = parts[0], parts[1], parts[2]
                f.write(f"{cid}\t{name}\t{status}\n")
            else:
                f.write(line + "\n")


def main() -> int:
    base = get_base_dir()
    logs_dir = ensure_logs_dir(base)
    log_path = os.path.join(logs_dir, "docker_monitor.log")

    ok, output = query_docker()
    try:
        write_log(log_path, ok, output)
    except Exception as e:
        # if logging fails, print to stderr for visibility and exit non-zero
        print(f"Failed to write log: {e}", file=sys.stderr)
        return 2

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
