#!/usr/bin/env bash
# Continuous tray separator script for Waybar
# This script runs continuously and outputs changes only when needed

tray_apps=(
    "blueman-applet" 
    "steam"
    "obs"
)

get_tray_state() {
    for app in "${tray_apps[@]}"; do
        if pgrep -x "$app" >/dev/null 2>&1; then
            echo "|"
            return 0
        fi
    done
    echo ""
}

# Output initial state
previous_state=$(get_tray_state)
echo "$previous_state"

# Monitor for changes
while true; do
    sleep 5  # Check every 5 seconds (adjust as needed)
    current_state=$(get_tray_state)
    
    if [[ "$current_state" != "$previous_state" ]]; then
        echo "$current_state"
        previous_state="$current_state"
    fi
done
