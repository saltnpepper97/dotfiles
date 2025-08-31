#!/usr/bin/env bash
set -euo pipefail

LOCKFILE="/tmp/run-updates.lock"

# Check for lockfile *before* launching Kitty
if [ -e "$LOCKFILE" ]; then
    notify-send "Update already running" "Please wait for the current update to finish."
    exit 1
fi

# Only launch GUI terminal if not already inside Kitty
if [ -z "${INSIDE_KITTY:-}" ]; then
    export INSIDE_KITTY=1
    kitty --class updates --title "Arch Updates" bash "$0"
    exit 0
fi

# Create lockfile atomically
echo $$ > "$LOCKFILE" || {
    notify-send "Failed to create lockfile" "Could not start update process."
    exit 1
}

# -----------------------------
# Colors for fancy output
# -----------------------------
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
BOLD="\033[1m"
RESET="\033[0m"

# -----------------------------
# Progress bar function
# -----------------------------
progress_bar() {
    local pid=$1
    local message=$2
    local delay=0.2
    local width=20
    local progress=0
    
    while kill -0 "$pid" 2>/dev/null; do
        local filled=$((progress % (width + 1)))
        local empty=$((width - filled))
        
        printf "\r${CYAN}["
        printf "%*s" $filled | tr ' ' '|'
        printf "%*s" $empty | tr ' ' ' '
        printf "]${RESET} %s" "$message"
        
        progress=$((progress + 1))
        sleep $delay
    done
    
    # Show completed progress bar
    printf "\r${CYAN}["
    printf "%*s" $width | tr ' ' '|'
    printf "]${RESET} %s\n" "$message"
}

# -----------------------------
# Fancy title
# -----------------------------
clear
echo -e "${BOLD}${CYAN}---------------- Arch Update Manager ----------------${RESET}"
echo
echo -e "${YELLOW}Host: ${RESET}$(cat /etc/hostname)"
echo -e "${YELLOW}User: ${RESET}$USER"
echo -e "${YELLOW}Date: ${RESET}$(date '+%Y-%m-%d %H:%M:%S')"
echo

# -----------------------------
# Fetching update information
# -----------------------------
echo -e "${BOLD}Fetching update information...${RESET}"
if ! paru -Sy &>/dev/null; then
    echo -e "${RED}Failed to sync package databases${RESET}"
    rm -f "$LOCKFILE"
    exit 1
fi
updates=$(paru -Qu 2>/dev/null || true)

if [ -z "$updates" ]; then
    echo -e "${GREEN}No updates available${RESET}"
    echo -e "${YELLOW}Press Enter to close...${RESET}"
    stty sane  # Reset terminal settings
    read -r
    ~/.config/waybar/scripts/check-updates.sh force
    rm -f "$LOCKFILE"
    exit 0
fi

# -----------------------------
# Show packages that need updating
# -----------------------------
echo -e "${YELLOW}Packages that need updating:${RESET}"
echo "$updates"
echo
total_packages=$(echo "$updates" | wc -l)
echo -e "${YELLOW}Total packages to update: $total_packages${RESET}"
echo

# -----------------------------
# Ask for confirmation
# -----------------------------
echo -e "${BOLD}Do you want to proceed with the update? (y/n):${RESET}"
stty sane  # Reset terminal settings before reading input
read -rp "" response

case "$response" in
    [yY]|[yY][eE][sS])
        echo -e "${GREEN}Proceeding with update...${RESET}"
        ;;
    *)
        echo -e "${RED}Update cancelled${RESET}"
        ~/.config/waybar/scripts/check-updates.sh force
        rm -f "$LOCKFILE"
        exit 0
        ;;
esac

# -----------------------------
# Create cache directory if it doesn't exist
# -----------------------------
mkdir -p ~/.cache/updates

# -----------------------------
# Ensure lockfile is always removed
# -----------------------------
cleanup() {
    rm -f "$LOCKFILE"
}
trap cleanup EXIT

# -----------------------------
# Run system update and save output
# -----------------------------
# Run system update and save output
echo -e "${BOLD}Updating packages...${RESET}"
paru -Syu --noconfirm > ~/.cache/updates/last-update.txt 2>&1 &
update_pid=$!

# Show progress bar while update runs
progress_bar $update_pid "Updating packages"

# Wait for update to complete and check exit status
if wait $update_pid; then
    echo -e "${GREEN}[✔] Update complete${RESET}"
else
    echo -e "${RED}[✘] Update failed. Check ~/.cache/updates/last-update.txt for details${RESET}"
    ~/.config/waybar/scripts/check-updates.sh force
    rm -f "$LOCKFILE"
    exit 1
fi


# -----------------------------
# Run waybar script
# -----------------------------
~/.config/waybar/scripts/check-updates.sh force

# -----------------------------
# Wait for user to exit
# -----------------------------
echo -e "${YELLOW}Press Enter to close...${RESET}"
stty sane  # Reset terminal settings
read -r
