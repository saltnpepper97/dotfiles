#!/bin/bash

# Hyprland dynamic window floating script
# This script listens to socket2 events and floats child windows dynamically

# Find the correct socket path
if [[ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
    # Try /run/user first (common with dbus-run-session), then /tmp
    if [[ -S "/run/user/$(id -u)/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" ]]; then
        HYPR_SOCKET="/run/user/$(id -u)/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
    elif [[ -S "/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" ]]; then
        HYPR_SOCKET="/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
    fi
else
    # Fallback: find any socket2.sock file
    HYPR_SOCKET=$(find /run/user/$(id -u)/hypr /tmp/hypr -name "*.socket2.sock" 2>/dev/null | head -1)
fi

# Function to get window info by address
get_window_info() {
    local address="$1"
    # Remove 0x prefix if present and add it back
    address=$(echo "$address" | sed 's/^0x//')
    hyprctl clients -j | jq -r ".[] | select(.address == \"0x$address\")"
}

# Function to check if window should be floated
should_float_window() {
    local window_info="$1"
    local class=$(echo "$window_info" | jq -r '.class')
    local title=$(echo "$window_info" | jq -r '.title')
    local initial_title=$(echo "$window_info" | jq -r '.initialTitle')
    
    case "$class" in
        "blender")
            # Don't float if title contains "Blender" (main window)
            if [[ "$title" == *"Blender"* ]]; then
                echo "DEBUG: Blender main window (contains 'Blender') - Title: '$title', Initial: '$initial_title'"
                return 1
            else
                echo "DEBUG: Blender child window detected - Title: '$title', Initial: '$initial_title'"
                return 0
            fi
            ;;
    esac
    
    return 1
}

# Main event handler
handle_event() {
    local event="$1"
    
    case "$event" in
        openwindow*)
            # Extract window address from event: "openwindow>>ADDRESS,WORKSPACENAME,CLASS,TITLE"
            local window_address=$(echo "$event" | cut -d'>' -f3 | cut -d',' -f1)
            
            # Small delay to let window fully initialize
            # Minimal delay - just enough for window to exist
            sleep 0.01
            
            # Get window information
            local window_info=$(get_window_info "$window_address")
            
            if [[ -n "$window_info" ]]; then
                local class=$(echo "$window_info" | jq -r '.class')
                local title=$(echo "$window_info" | jq -r '.title')
                echo "DEBUG: New window detected - Class: '$class', Title: '$title', Address: '$window_address'"
                
                if should_float_window "$window_info"; then
                    echo "Floating window: $(echo "$window_info" | jq -r '.class') - $(echo "$window_info" | jq -r '.title')"
                    # Combine commands to reduce visual flicker
                    hyprctl --batch "dispatch togglefloating address:$window_address; dispatch resizewindowpixel exact 800 600,address:$window_address; dispatch centerwindow 1"
                fi
            fi
            ;;
        windowtitle*)
            # Handle title changes - some apps change title after opening
            local window_address=$(echo "$event" | cut -d'>' -f3 | cut -d',' -f1)
            echo "DEBUG: Title change detected for address: $window_address"
            sleep 0.05
            
            local window_info=$(get_window_info "$window_address")
            if [[ -n "$window_info" ]]; then
                local class=$(echo "$window_info" | jq -r '.class')
                local title=$(echo "$window_info" | jq -r '.title')
                echo "DEBUG: Title changed - Class: '$class', New title: '$title', Address: 0x$window_address"
                
                local is_floating=$(echo "$window_info" | jq -r '.floating')
                if [[ "$is_floating" == "false" ]] && should_float_window "$window_info"; then
                    echo "Title changed, now floating: $(echo "$window_info" | jq -r '.class') - $(echo "$window_info" | jq -r '.title')"
                    # Combine commands to reduce visual flicker
                    hyprctl --batch "dispatch togglefloating address:0x$window_address; dispatch resizewindowpixel exact 800 600,address:0x$window_address; dispatch centerwindow 1"
                fi
            else
                echo "DEBUG: Could not get window info for address: 0x$window_address"
                # Let's see what windows exist
                echo "DEBUG: Available windows:"
                hyprctl clients -j | jq -r '.[].address' | head -3
            fi
            ;;
    esac
}

# Check if required tools are available
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed"
    exit 1
fi

if ! command -v socat &> /dev/null; then
    echo "Error: socat is required but not installed"
    exit 1
fi

if [[ -z "$HYPR_SOCKET" ]] || [[ ! -S "$HYPR_SOCKET" ]]; then
    echo "Error: Cannot find Hyprland socket2. Searched for:"
    echo "  - /run/user/$(id -u)/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
    echo "  - /tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
    echo "Available sockets:"
    find /run/user/$(id -u)/hypr /tmp/hypr -name "*.socket*" 2>/dev/null | head -5
    exit 1
fi

echo "Starting Hyprland window floating daemon..."
echo "Listening on: $HYPR_SOCKET"

# Main event loop
socat -U - UNIX-CONNECT:"$HYPR_SOCKET" | while read -r line; do
    handle_event "$line"
done
