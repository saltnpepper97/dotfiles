#!/bin/bash

# Immediately output zero while checks run in background
printf '{"text": "0", "class": "checking"}\n'

# Function to count pacman updates
count_pacman_updates() {
    local updates
    updates=$(checkupdates 2>/dev/null | wc -l)
    echo "$updates"
}

# Function to count AUR updates using paru
count_paru_updates() {
    local updates
    # Check if paru is installed
    if ! command -v paru &> /dev/null; then
        echo "0"
        return
    fi
    
    # Get AUR updates count
    updates=$(paru -Qua 2>/dev/null | wc -l)
    echo "$updates"
}

# Run checks in background and update output
{
    # Get update counts
    pacman_updates=$(count_pacman_updates)
    paru_updates=$(count_paru_updates)
    
    # Calculate total updates
    total_updates=$((pacman_updates + paru_updates))
    
    # Output final result
    if [ "$total_updates" -gt 0 ]; then
        printf '{"text": "%d", "class": "updates-available"}\n' "$total_updates"
    else
        printf '{"text": "0", "class": "no-updates"}\n'
    fi
} &

# Wait for background process to complete
wait
