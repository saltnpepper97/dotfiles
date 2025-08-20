#!/usr/bin/env python3
"""
ui-launcher: Simple exclusive UI app launcher for Hyprland
Usage: ui-launcher.py <app-name>
"""
import sys
import os
import subprocess
import time
import json
import threading

TIMEOUT = 45
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

# Define which apps need Hyprland window management
HYPRLAND_APPS = {
    "clipse": "clipse",
    "floating-selector": "floating-selector", 
    "waypaper": "waypaper"
}

def kill_process_tree(pid):
    """Kill a process and all its children"""
    try:
        result = subprocess.run(['pgrep', '-P', str(pid)],
                                capture_output=True, text=True)
        children = result.stdout.strip().split('\n') if result.stdout.strip() else []
        for child in children:
            if child:
                kill_process_tree(int(child))
        subprocess.run(['kill', str(pid)], stderr=subprocess.DEVNULL)
    except:
        pass

def kill_by_name(name):
    """Kill processes by name"""
    try:
        subprocess.run(['pkill', '-x', name], stderr=subprocess.DEVNULL)
    except:
        pass

def kill_hyprland_window(class_name):
    """Kill Hyprland window by class name"""
    try:
        subprocess.run(['hyprctl', 'dispatch', 'signalwindow', f'class:{class_name},9'], 
                      stderr=subprocess.DEVNULL)
    except:
        pass

def kill_previous(app_name):
    """Kill previous instance only of the same app"""
    # Kill old PID from statefile
    if os.path.exists(STATEFILE):
        try:
            with open(STATEFILE, 'r') as f:
                data = f.read().strip()
                if ',' in data:
                    prev_pid, prev_app = data.split(',', 1)
                    prev_pid = int(prev_pid)
                else:
                    prev_pid = int(data)
                    prev_app = None
                
                # Use appropriate kill method based on app type
                if prev_app and prev_app in HYPRLAND_APPS:
                    kill_hyprland_window(HYPRLAND_APPS[prev_app])
                kill_process_tree(prev_pid)
            os.unlink(STATEFILE)
        except:
            pass
    
    # Kill named processes for apps that need it
    if app_name == "rofi":
        kill_by_name("rofi")
    elif app_name == "waypaper":
        kill_by_name("waypaper")
        kill_hyprland_window("waypaper")
    elif app_name in HYPRLAND_APPS:
        kill_hyprland_window(HYPRLAND_APPS[app_name])
    
    # For clipse and floating-selector, we don't auto-kill — prevent immediate termination
    time.sleep(0.2)

def auto_kill_timer(pid, app_name):
    """Auto-kill the process after timeout"""
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
                # Use appropriate kill method based on app type
                if app_name in HYPRLAND_APPS:
                    kill_hyprland_window(HYPRLAND_APPS[app_name])
                kill_process_tree(pid)
                os.unlink(STATEFILE)
    except:
        pass

def main():
    if len(sys.argv) != 2 or sys.argv[1] not in UI_APPS:
        print(f"Usage: {sys.argv[0]} <app-name>")
        print(f"Available: {', '.join(UI_APPS.keys())}")
        sys.exit(1)
    
    app = sys.argv[1]
    command = UI_APPS[app]
    
    # Kill previous app if needed
    kill_previous(app)
    
    # Launch the app
    if isinstance(command, str):
        process = subprocess.Popen(command, shell=True)
    else:
        process = subprocess.Popen(command)
    
    pid = process.pid
    
    # Save the PID and app name
    with open(STATEFILE, 'w') as f:
        f.write(f"{pid},{app}")
    
    # Start auto-kill timer (non-daemon so script stays alive)
    timer_thread = threading.Thread(target=auto_kill_timer, args=(pid, app))
    timer_thread.start()
    
    # Keep the script alive until the timer finishes or process ends
    try:
        timer_thread.join()
    except KeyboardInterrupt:
        # Clean up on Ctrl+C
        if app in HYPRLAND_APPS:
            kill_hyprland_window(HYPRLAND_APPS[app])
        kill_process_tree(pid)
        if os.path.exists(STATEFILE):
            os.unlink(STATEFILE)

if __name__ == "__main__":
    main()
