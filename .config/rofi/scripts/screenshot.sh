#!/usr/bin/env bash

# Screenshot script for rofi with feather icons (Hyprland/Wayland)
# Requires: grim, slurp, wl-clipboard, notify-send, jq

SCREENSHOT_DIR="$HOME/pictures/screenshots"
mkdir -p "$SCREENSHOT_DIR"

FULL=""   # camera - full screen
AREA=""   # crop - select area  
WIN=""    # monitor - current window
DELAY1="" # clock - 1 minute delay
DELAY5="" # clock - 5 minute delay

options="$FULL\n$AREA\n$WIN\n$DELAY1\n$DELAY5"

chosen=$(echo -e "$options" | rofi -dmenu -p "Screenshot" -theme ~/.config/rofi/screenshot.rasi)

take_screenshot() {
    type=$1
    
    case $type in
        "$FULL")
            sleep 1
            DATE=$(date +"%Y-%m-%d_%H-%M-%S")
            grim "$SCREENSHOT_DIR/fullscreen_$DATE.png"
            notify-send "Screenshot Taken" "Full screen saved to Screenshots folder"
            ;;
        "$AREA")
            sleep 1
            DATE=$(date +"%Y-%m-%d_%H-%M-%S")
            grim -g "$(slurp)" "$SCREENSHOT_DIR/selection_$DATE.png"
            notify-send "Screenshot Taken" "Selected area saved to Screenshots folder"
            ;;
        "$WIN")
            sleep 0.5
            DATE=$(date +"%Y-%m-%d_%H-%M-%S")
            case "$XDG_CURRENT_DESKTOP" in
                Hyprland)
                    if command -v hyprctl &> /dev/null; then
                        WINDOW=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
                        grim -g "$WINDOW" "$SCREENSHOT_DIR/window_$DATE.png"
                        notify-send "Screenshot Taken" "Active window saved to Screenshots folder"
                    else
                        notify-send "Screenshot Error" "hyprctl not found - required for Hyprland window screenshots"
                    fi
                    ;;
                niri)
                    # Parse window info from niri msg window
                    WINDOW_INFO=$(niri msg window 2>/dev/null | grep -A6 'Window ID .*: (focused)' | grep -E 'Window size|Window offset' | awk '{print $3}' | tr '\n' ' ')
                    if [[ -n "$WINDOW_INFO" ]]; then
                        read W H X Y <<< "$WINDOW_INFO"
                        grim -g "${X},${Y} ${W}x${H}" "$SCREENSHOT_DIR/window_$DATE.png"
                        notify-send "Screenshot Taken" "Active window saved to Screenshots folder (Niri)"
                    else
                        notify-send "Screenshot Error" "Could not detect active window in Niri"
                    fi
                    ;;
                *)
                    notify-send "Screenshot Error" "Unsupported desktop/session: $XDG_CURRENT_DESKTOP"
                    ;;
            esac
            ;;
        "$DELAY1")
            notify-send "Screenshot" "Taking screenshot in 1 minute..."
            sleep 60
            DATE=$(date +"%Y-%m-%d_%H-%M-%S")
            grim "$SCREENSHOT_DIR/delayed_1min_$DATE.png"
            notify-send "Screenshot Taken" "1 minute delayed screenshot saved to Screenshots folder"
            ;;
        "$DELAY5")
            notify-send "Screenshot" "Taking screenshot in 5 minutes..."
            sleep 300
            DATE=$(date +"%Y-%m-%d_%H-%M-%S")
            grim "$SCREENSHOT_DIR/delayed_5min_$DATE.png"
            notify-send "Screenshot Taken" "5 minute delayed screenshot saved to Screenshots folder"
            ;;
    esac
}

# Run the screenshot in background so the menu returns immediately
take_screenshot "$chosen" &
