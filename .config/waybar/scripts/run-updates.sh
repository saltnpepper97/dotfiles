#!/usr/bin/env bash
set -euo pipefail
LOCKFILE="/tmp/run-updates.lock"

# -----------------------------
# Check if another instance is running BEFORE launching Kitty
# -----------------------------
if [ -e "$LOCKFILE" ]; then
    notify-send "Update already running" "Please wait for the current update to finish."
    exit 0
fi

# -----------------------------
# Only launch GUI terminal if not inside Kitty
# -----------------------------
if [ -z "${INSIDE_KITTY:-}" ]; then
    export INSIDE_KITTY=1
    kitty --class updates --title "Arch Updates" bash "$0"
    exit 0
fi

# -----------------------------
# Write own PID to lockfile
# -----------------------------
echo $$ > "$LOCKFILE"

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
    local width=40
    local progress=0
    
    echo -e "${CYAN}${message}${RESET}"
    
    while kill -0 "$pid" 2>/dev/null; do
        # Calculate progress (cycles through 0-100%)
        progress=$(( (progress + 2) % 101 ))
        local filled=$(( progress * width / 100 ))
        local empty=$(( width - filled ))
        
        printf "\r${CYAN}["
        printf "%*s" $filled | tr ' ' '|'
        printf "%*s" $empty | tr ' ' ' '
        printf "] %3d%%${RESET}" $progress
        
        sleep 0.1
    done
    
    # Show completed bar
    printf "\r${GREEN}["
    printf "%*s" $width | tr ' ' '|'
    printf "] 100%%${RESET}\n"
    echo -e "${GREEN}✔ ${message} completed${RESET}\n"
}

# -----------------------------
# Function to show package changes
# -----------------------------
show_package_changes() {
    echo -e "${BOLD}${YELLOW}Checking for package updates...${RESET}"
    
    # Get list of packages to be updated
    local updates
    updates=$(paru -Qu 2>/dev/null || true)
    
    if [ -z "$updates" ]; then
        echo -e "${GREEN}✔ System is up to date!${RESET}\n"
        return 1
    fi
    
    echo -e "${BOLD}${CYAN}Package version changes:${RESET}"
    echo -e "${CYAN}────────────────────────────────${RESET}"
    
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            package=$(echo "$line" | awk '{print $1}')
            old_version=$(echo "$line" | awk '{print $2}')
            new_version=$(echo "$line" | awk '{print $4}')
            echo -e "${YELLOW}${package}${RESET}: ${RED}${old_version}${RESET} → ${GREEN}${new_version}${RESET}"
        fi
    done <<< "$updates"
    
    echo -e "${CYAN}────────────────────────────────${RESET}"
    echo
    
    return 0
}

# -----------------------------
# Function to run paru with progress bar
# -----------------------------
run_paru_update() {
    local temp_log="/tmp/paru_output.log"
    
    # Run paru in background, redirect output to log file
    paru -Syu --noconfirm > "$temp_log" 2>&1 &
    local paru_pid=$!
    
    # Show progress bar while paru runs
    progress_bar $paru_pid "Installing updates"
    
    # Wait for paru to complete and get exit status
    wait $paru_pid
    local exit_status=$?
    
    # Clean up log file
    rm -f "$temp_log"
    
    if [ $exit_status -eq 0 ]; then
        echo -e "${GREEN}✔ All packages updated successfully!${RESET}"
    else
        echo -e "${RED}✗ Update process encountered errors${RESET}"
    fi
    
    return $exit_status
}

# -----------------------------
# Fancy title
# -----------------------------
clear
echo -e "${BOLD}${CYAN}╔══════════════════════════════════╗${RESET}"
echo -e "${BOLD}${CYAN}║        Arch Linux Updates        ║${RESET}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════╝${RESET}"
echo
echo -e "${YELLOW}Host: ${RESET}$(cat /etc/hostname)"
echo -e "${YELLOW}User: ${RESET}$USER"
echo -e "${YELLOW}Date: ${RESET}$(date '+%Y-%m-%d %H:%M:%S')"
echo
sleep 1

# -----------------------------
# Show package changes and run update
# -----------------------------
if show_package_changes; then
    echo
    echo -e "${YELLOW}Do you want to proceed with the updates? (y/N): ${RESET}"
    read -rp "" confirm
    
    if [[ ! "$confirm" =~ ^[Yy]([Ee][Ss])?$ ]]; then
        echo -e "${CYAN}Update cancelled by user.${RESET}"
        echo
        # Flush any stray keypresses
        read -t 0.1 -n 10000 discard 2>/dev/null || true
        echo -e "${YELLOW}Press Enter to close...${RESET}"
        read -rp ""
        # Refresh Waybar updates (silent)
        ~/.config/waybar/scripts/check-updates.sh force
        # Remove lockfile when user hits enter
        rm -f "$LOCKFILE"
        exit 0
    fi
    
    echo -e "${YELLOW}Starting system update...${RESET}"
    echo
    
    if run_paru_update; then
        echo
        echo -e "${GREEN}${BOLD}Update completed successfully!${RESET}"
    else
        echo
        echo -e "${RED}${BOLD}Update completed with errors. Check the system logs for details.${RESET}"
    fi
else
    echo -e "${GREEN}${BOLD}No updates available.${RESET}"
fi

echo

# -----------------------------
# Flush any stray keypresses
# -----------------------------
read -t 0.1 -n 10000 discard 2>/dev/null || true

# -----------------------------
# Wait for fresh Enter
# -----------------------------
echo -e "${YELLOW}Press Enter to close...${RESET}"
read -rp ""

# -----------------------------
# Refresh Waybar updates (silent)
# -----------------------------
~/.config/waybar/scripts/check-updates.sh force

# Remove lockfile when user hits enter
rm -f "$LOCKFILE"
