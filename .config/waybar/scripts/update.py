#!/usr/bin/env python3
import os
import sys
import subprocess
import time
import atexit
import signal
import fcntl
import re
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

    # Simplified wrapper - just run the Python script
    wrapper_script = f'''#!/bin/bash
cd "{os.getcwd()}"
python3 "{__file__}"
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
# Progress bar function
# -----------------------------
def update_progress_bar(current, total, bar_width=35):
    """Display a progress bar with current/total packages."""
    if total == 0:
        filled = 0
    else:
        filled = int(bar_width * current / total)
    
    empty = bar_width - filled
    bar = "|" * filled + " " * empty
    percentage = int(100 * current / total) if total > 0 else 0
    
    print(f"\r{CYAN}[{bar}]{RESET} ({current}/{total}) {percentage}%", end="", flush=True)

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
    input("Press Enter to close...")
    sys.exit(1)

updates = subprocess.run(["paru", "-Qu"], capture_output=True, text=True)
updates_list = updates.stdout.strip().splitlines()

if not updates_list:
    print(f"{GREEN}No updates available{RESET}")
    input("Press Enter to close...")
    sys.exit(0)

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
    input("Press Enter to close...")
    sys.exit(0)

print(f"{GREEN}Proceeding with update...{RESET}")

# -----------------------------
# Ensure cache directory
# -----------------------------
CACHE_DIR.mkdir(parents=True, exist_ok=True)

# -----------------------------
# Run update with real progress tracking
# -----------------------------
print(f"{BOLD}Updating packages...{RESET}")

total_packages = len(updates_list)
completed_packages = 0

# Pattern to match package installation/upgrade messages
install_patterns = [
    re.compile(r"installing (\S+)"),
    re.compile(r"upgrading (\S+)"),
    re.compile(r"reinstalling (\S+)"),
    re.compile(r"\[(\d+)/(\d+)\]"),  # Sometimes paru shows [x/y] progress
]

update_progress_bar(completed_packages, total_packages)

proc = subprocess.Popen(
    ["paru", "-Syu", "--noconfirm"],
    stdout=subprocess.PIPE,
    stderr=subprocess.STDOUT,
    universal_newlines=True,
    bufsize=1
)

# Log file for debugging
with UPDATE_LOG.open("w") as logfile:
    while True:
        if proc.stdout is None:
            break
        output = proc.stdout.readline()
        if output == '' and proc.poll() is not None:
            break
        
        if output:
            # Write to log
            logfile.write(output)
            logfile.flush()
            
            # Check for progress indicators
            line = output.strip().lower()
            
            # Look for package installation/upgrade messages
            for pattern in install_patterns:
                if pattern.search(line):
                    # Check if this is a [x/y] pattern which gives us exact progress
                    match = re.search(r"\[(\d+)/(\d+)\]", line)
                    if match:
                        current = int(match.group(1))
                        total = int(match.group(2))
                        if total == total_packages:  # Make sure it matches our expected total
                            completed_packages = current
                        else:
                            # Estimate based on the pattern
                            completed_packages = min(completed_packages + 1, total_packages)
                    else:
                        # Increment for other installation messages
                        completed_packages = min(completed_packages + 1, total_packages)
                    
                    update_progress_bar(completed_packages, total_packages)
                    break
            
            # Also look for other progress indicators
            if any(keyword in line for keyword in ['downloading', 'checking', 'resolving']):
                # Small progress for preparatory steps
                if completed_packages == 0:
                    update_progress_bar(0, total_packages)

# Ensure we show 100% completion
update_progress_bar(total_packages, total_packages)
print()  # New line after progress bar

# -----------------------------
# Handle update completion
# -----------------------------
update_performed = False

if proc.returncode == 0:
    print(f"{GREEN}[✔] Update complete{RESET}")
    update_performed = True
else:
    print(f"{RED}[✘] Update failed. Check {UPDATE_LOG} for details{RESET}")

# Always ask user to press Enter before closing
print(f"\n{BOLD}Press Enter to close...{RESET}")
input()

# If updates were performed successfully, run waybar script with force flag
if update_performed:
    print(f"{CYAN}Refreshing waybar...{RESET}")
    try:
        subprocess.run([str(WAYBAR_SCRIPT), "force"], check=False)
    except Exception as e:
        print(f"{YELLOW}Warning: Could not refresh waybar: {e}{RESET}")

print(f"{GREEN}Exiting update script.{RESET}")
sys.exit(0)
