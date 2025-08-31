#!/usr/bin/env python3
import os
import sys
import subprocess
import time
import atexit
import signal
import fcntl
from pathlib import Path

LOCKFILE = Path("/tmp/run-updates.lock")
CACHE_DIR = Path.home() / ".cache/updates"
UPDATE_LOG = CACHE_DIR / "last-update.txt"
WAYBAR_SCRIPT = Path.home() / ".config/waybar/scripts/check-updates.sh"
NOTIFY_COOLDOWN = 3  # seconds between notifications
NOTIFY_FILE = LOCKFILE.with_suffix(".notify")

# -----------------------------
# Colors
# -----------------------------
RED = "\033[0;31m"
GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
CYAN = "\033[0;36m"
BOLD = "\033[1m"
RESET = "\033[0m"

# -----------------------------
# Headless launcher
# -----------------------------
if not os.environ.get("INSIDE_KITTY"):
    # Temporary lock to prevent multiple launches
    temp_lockfile = LOCKFILE.with_suffix(".tmp")
    temp_fd = open(temp_lockfile, "w")
    try:
        fcntl.flock(temp_fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        now = time.time()
        last_time = 0
        if NOTIFY_FILE.exists():
            try:
                last_time = float(NOTIFY_FILE.read_text().strip())
            except Exception:
                last_time = 0
        if now - last_time >= NOTIFY_COOLDOWN:
            subprocess.run([
                "notify-send",
                "Update already running",
                "Please wait for the current update to finish."
            ])
            NOTIFY_FILE.write_text(str(now))
        sys.exit(0)

    os.environ["INSIDE_KITTY"] = "1"


    wrapper_script = f'''#!/bin/bash
cd "{os.getcwd()}"
python3 "{__file__}"
exit_code=$?
if [ $exit_code -eq 2 ]; then
    read -p "Press Enter to close..."
    "{WAYBAR_SCRIPT}" force &
fi
exit $exit_code
'''
    wrapper_path = Path("/tmp/update-wrapper.sh")
    wrapper_path.write_text(wrapper_script)
    wrapper_path.chmod(0o755)

    try:
        subprocess.run([
            "kitty",
            "--class", "updates",
            "--title", "Arch Updates",
            str(wrapper_path)
        ], check=True)
    finally:
        if wrapper_path.exists():
            wrapper_path.unlink()
        fcntl.flock(temp_fd, fcntl.LOCK_UN)
        temp_fd.close()
        temp_lockfile.unlink(missing_ok=True)
    sys.exit(0)

# -----------------------------
# Now inside Kitty - acquire main lock
# -----------------------------
lock_fd = open(LOCKFILE, "w")
try:
    fcntl.flock(lock_fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
except BlockingIOError:
    subprocess.run([
        "notify-send",
        "Update already running",
        "Please wait for the current update to finish."
    ])
    sys.exit(1)

def cleanup():
    """Release lockfile on exit."""
    try:
        fcntl.flock(lock_fd, fcntl.LOCK_UN)
    except Exception:
        pass
    if LOCKFILE.exists():
        LOCKFILE.unlink()
    lock_fd.close()

atexit.register(cleanup)
signal.signal(signal.SIGTERM, lambda s, f: sys.exit(0))
signal.signal(signal.SIGINT, lambda s, f: sys.exit(0))

# -----------------------------
# Fancy title
# -----------------------------
os.system("clear")
print(f"{BOLD}{CYAN}---------------- Arch Update Manager ----------------{RESET}\n")
print(f"{YELLOW}Host:{RESET} {Path('/etc/hostname').read_text().strip()}")
print(f"{YELLOW}User:{RESET} {os.getenv('USER')}")
print(f"{YELLOW}Date:{RESET} {time.strftime('%Y-%m-%d %H:%M:%S')}\n")

# -----------------------------
# Fetch updates
# -----------------------------
print(f"{BOLD}Fetching update information...{RESET}")
sync = subprocess.run(["paru", "-Sy"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
if sync.returncode != 0:
    print(f"{RED}Failed to sync package databases{RESET}")
    sys.exit(2)

updates = subprocess.run(["paru", "-Qu"], capture_output=True, text=True)
updates_list = updates.stdout.strip().splitlines()

if not updates_list:
    print(f"{GREEN}No updates available{RESET}")
    sys.exit(2)

# -----------------------------
# Show updates
# -----------------------------
print(f"{YELLOW}Packages that need updating:{RESET}")
print("\n".join(updates_list))
print(f"\n{YELLOW}Total packages to update: {len(updates_list)}{RESET}\n")

# -----------------------------
# Ask for confirmation
# -----------------------------
response = input(f"{BOLD}Do you want to proceed with the update? (y/n):{RESET} ").strip().lower()
if response not in ("y", "yes"):
    print(f"{RED}Update cancelled{RESET}")
    sys.exit(2)

print(f"{GREEN}Proceeding with update...{RESET}")

# -----------------------------
# Ensure cache directory
# -----------------------------
CACHE_DIR.mkdir(parents=True, exist_ok=True)

# -----------------------------
# Run update with progress bar
# -----------------------------
print(f"{BOLD}Updating packages...{RESET}")

with UPDATE_LOG.open("w") as logfile:
    proc = subprocess.Popen(["paru", "-Syu", "--noconfirm"], stdout=logfile, stderr=subprocess.STDOUT)

    width = 20
    progress = 0
    while proc.poll() is None:
        filled = progress % (width + 1)
        empty = width - filled
        bar = "|" * filled + " " * empty
        print(f"\r{CYAN}[{bar}]{RESET} Updating packages", end="", flush=True)
        progress += 1
        time.sleep(0.2)

    print(f"\r{CYAN}[{'|'*width}]{RESET} Updating packages")

# -----------------------------
# After update is complete
# -----------------------------
if proc.returncode == 0:
    print(f"{GREEN}[✔] Update complete{RESET}")
else:
    print(f"{RED}[✘] Update failed. Check {UPDATE_LOG} for details{RESET}")


print(f"{GREEN}Exiting update script.{RESET}")
sys.exit(2)
