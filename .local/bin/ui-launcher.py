#!/usr/bin/env python3
"""
ui-launcher: Simple exclusive UI app launcher for Hyprland
Usage: ui-launcher.py <app-name>
"""
import sys
import os
import subprocess
import time
import threading
import shlex
import signal

TIMEOUT = 60
STATEFILE = "/tmp/ui-launcher-state"

# Define apps
UI_APPS = {
    "rofi": f"{os.path.expanduser('~')}/.config/rofi/scripts/launcher.sh",
    "rofi-powermenu": f"{os.path.expanduser('~')}/.config/rofi/scripts/powermenu.sh",
    "rofi-screenshot": f"{os.path.expanduser('~')}/.config/rofi/scripts/screenshot.sh",
    "clipse": ["kitty", "--class", "clipse", "-e", "clipse"],
    "floating-selector": ["kitty", "--class=floating-selector", "-e", "bash", "-c", f"{os.path.expanduser('~')}/.local/bin/quick-edit"],
    "waypaper": "waypaper"
}

HYPRLAND_APPS = {
    "clipse": "clipse",
    "floating-selector": "floating-selector",
    "waypaper": "waypaper"
}

def is_running(pid: int) -> bool:
    try:
        os.kill(pid, 0)
        return True
    except (OSError, ProcessLookupError):
        return False

def kill_process_tree(pid):
    if not is_running(pid):
        return
    try:
        # Get children with timeout
        result = subprocess.run(['pgrep', '-P', str(pid)],
                                capture_output=True, text=True, timeout=1.0)
        children = result.stdout.strip().split('\n') if result.stdout.strip() else []
        for child in children:
            if child and child.isdigit():
                kill_process_tree(int(child))
        
        # Try SIGTERM first, then SIGKILL if needed
        os.kill(pid, signal.SIGTERM)
        time.sleep(0.02)  # Brief pause to allow graceful shutdown
        if is_running(pid):
            os.kill(pid, signal.SIGKILL)
    except (subprocess.TimeoutExpired, Exception):
        # If anything hangs or fails, force kill
        try:
            os.kill(pid, signal.SIGKILL)
        except:
            pass

def kill_hyprland_window(class_name):
    try:
        subprocess.run(['hyprctl', 'dispatch', 'signalwindow', f'class:{class_name},9'],
                       stderr=subprocess.DEVNULL, timeout=1.0)
    except (subprocess.TimeoutExpired, Exception):
        pass

def cleanup_stale_state():
    """Remove state file if process is already dead"""
    if not os.path.exists(STATEFILE):
        return
    try:
        with open(STATEFILE, 'r') as f:
            data = f.read().strip()
        if not data:
            os.unlink(STATEFILE)
            return
        if ',' in data:
            prev_pid, prev_app = data.split(',', 1)
            prev_pid = int(prev_pid)
        else:
            prev_pid = int(data)
        
        # If process is dead, clean up state
        if not is_running(prev_pid):
            os.unlink(STATEFILE)
    except (ValueError, FileNotFoundError):
        try:
            os.unlink(STATEFILE)
        except:
            pass

def kill_previous(app_name):
    cleanup_stale_state()
    if not os.path.exists(STATEFILE):
        return
    try:
        with open(STATEFILE, 'r') as f:
            data = f.read().strip()
            if ',' in data:
                prev_pid, prev_app = data.split(',', 1)
                prev_pid = int(prev_pid)
            else:
                prev_pid = int(data)
                prev_app = None

        if is_running(prev_pid):
            if prev_app and prev_app in HYPRLAND_APPS:
                kill_hyprland_window(HYPRLAND_APPS[prev_app])
            kill_process_tree(prev_pid)

        os.unlink(STATEFILE)
        time.sleep(0.05)  # small buffer for Hyprland
    except Exception:
        try:
            os.unlink(STATEFILE)
        except:
            pass

def launch(command):
    if isinstance(command, str):
        return subprocess.Popen(shlex.split(command))
    return subprocess.Popen(command)

def auto_kill_timer(pid, app_name):
    time.sleep(TIMEOUT)
    try:
        if os.path.exists(STATEFILE):
            with open(STATEFILE, 'r') as f:
                data = f.read().strip()
                if ',' in data:
                    current_pid, current_app = data.split(',', 1)
                    current_pid = int(current_pid)
                else:
                    current_pid = int(data)
                    current_app = None

            if current_pid == pid:
                if app_name in HYPRLAND_APPS:
                    kill_hyprland_window(HYPRLAND_APPS[app_name])
                kill_process_tree(pid)
                try:
                    os.unlink(STATEFILE)
                except:
                    pass
    except Exception:
        pass

def main():
    if len(sys.argv) != 2 or sys.argv[1] not in UI_APPS:
        print(f"Usage: {sys.argv[0]} <app-name>")
        print(f"Available: {', '.join(UI_APPS.keys())}")
        sys.exit(1)

    app = sys.argv[1]
    command = UI_APPS[app]

    # Toggle behavior: kill if same app running
    if os.path.exists(STATEFILE):
        try:
            with open(STATEFILE, 'r') as f:
                data = f.read().strip()
                if ',' in data:
                    prev_pid, prev_app = data.split(',', 1)
                    prev_pid = int(prev_pid)
                    if prev_app == app and is_running(prev_pid):
                        kill_previous(app)
                        return
        except Exception:
            pass

    kill_previous(app)  # kill other apps if needed
    process = launch(command)
    pid = process.pid

    # Atomic write to state file
    temp_statefile = f"{STATEFILE}.tmp"
    try:
        with open(temp_statefile, 'w') as f:
            f.write(f"{pid},{app}")
        os.rename(temp_statefile, STATEFILE)
    except Exception:
        # Fallback to direct write
        with open(STATEFILE, 'w') as f:
            f.write(f"{pid},{app}")

    timer_thread = threading.Thread(target=auto_kill_timer, args=(pid, app))
    timer_thread.daemon = True  # Don't block exit
    timer_thread.start()

    try:
        # Wait for process to finish or be killed
        process.wait()
    except KeyboardInterrupt:
        if app in HYPRLAND_APPS:
            kill_hyprland_window(HYPRLAND_APPS[app])
        kill_process_tree(pid)
        if os.path.exists(STATEFILE):
            try:
                os.unlink(STATEFILE)
            except:
                pass

if __name__ == "__main__":
    main()
