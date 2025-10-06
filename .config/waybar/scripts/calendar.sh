#!/usr/bin/env bash
# Check if btm is already running in any kitty instance
if pgrep -f "kitty.*calcurse" > /dev/null; then
    # Already running, do nothing
    exit 0
fi

# Launch btm in kitty
kitty --class calcurse -e calcurse
