#!/usr/bin/env bash
set -euo pipefail

# Nerd Font icons (your choices)
ICON_WIFI="󰖩"
ICON_ETH="󰈁"
ICON_DOWN="󰖪"

# Force English output so "connected" matches reliably
status=$(LC_ALL=C nmcli -t -f TYPE,STATE device status 2>/dev/null || true)

# Wi-Fi first
if echo "$status" | grep -qE '^wifi:connected$'; then
  echo "$ICON_WIFI"
  exit 0
fi

# Then Ethernet
if echo "$status" | grep -qE '^ethernet:connected$'; then
  echo "$ICON_ETH"
  exit 0
fi

# Neither Wi-Fi nor Ethernet connected
echo "$ICON_DOWN"

