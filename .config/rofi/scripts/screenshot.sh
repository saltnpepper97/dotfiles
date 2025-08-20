#!/usr/bin/env bash

# Screenshot script for rofi with feather icons (Hyprland/Wayland)
# Requires: grim, slurp, wl-clipboard, notify-send, jq

# Define screenshot directory
SCREENSHOT_DIR="$HOME/pictures/screenshots"
mkdir -p "$SCREENSHOT_DIR"

# Get current date for filename
DATE=$(date +"%Y-%m-%d_%H-%M-%S")

# Define options with feather icons (using icomoon feather font)
# (Icons must match exactly in case statement below)
FULL=""   # camera - full screen
AREA=""   # crop - select area  
WIN=""    # monitor - current window
DELAY1="" # clock - 1 minute delay
DELAY5="" # clock - 5 minute delay

options="$FULL\n$AREA\n$WIN\n$DELAY1\n$DELAY5"

# Show rofi menu
chosen=$(echo -e "$options" | rofi -dmenu -p "Screenshot" -theme ~/.config/rofi/screenshot.rasi)

case $chosen in
    "$FULL") # Full screen
        sleep 1
        grim "$SCREENSHOT_DIR/fullscreen_$DATE.png"
        notify-send "Screenshot Taken" "Full screen saved to Screenshots folder"
        ;;

    "$AREA") # Select area
        sleep 1
        grim -g "$(slurp)" "$SCREENSHOT_DIR/selection_$DATE.png"
        notify-send "Screenshot Taken" "Selected area saved to Screenshots folder"
        ;;

    "$WIN") # Current window
        if command -v hyprctl &> /dev/null; then
            WINDOW=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
            sleep 0.5
            grim -g "$WINDOW" "$SCREENSHOT_DIR/window_$DATE.png"
            notify-send "Screenshot Taken" "Active window saved to Screenshots folder"
        else
            notify-send "Screenshot Error" "hyprctl not found - required for window screenshots"
            exit 1
        fi
        ;;

    "$DELAY1") # 1 minute delay
        notify-send "Screenshot" "Taking screenshot in 1 minute..."
        sleep 60
        grim "$SCREENSHOT_DIR/delayed_1min_$DATE.png"
        notify-send "Screenshot Taken" "1 minute delayed screenshot saved to Screenshots folder"
        ;;

    "$DELAY5") # 5 minute delay
        notify-send "Screenshot" "Taking screenshot in 5 minutes..."
        sleep 300
        grim "$SCREENSHOT_DIR/delayed_5min_$DATE.png"
        notify-send "Screenshot Taken" "5 minute delayed screenshot saved to Screenshots folder"
        ;;

    *)
        exit 1
        ;;
esac
