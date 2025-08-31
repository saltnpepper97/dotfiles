#!/bin/bash

# Configuration
CACHE_FILE="/tmp/waybar-updates.json"
LOCK_FILE="/tmp/waybar-updates.lock"
CACHE_DURATION=1800  # 30 minutes
BACKGROUND_CHECK_FLAG="/tmp/waybar-updates-bg.flag"

# Default output
default_output() {
    echo '{"text":"?","class":"checking","tooltip":"Checking for updates..."}'
}

# Loading output
loading_output() {
    echo '{"text":"...","class":"checking","tooltip":"Checking for updates..."}'
}

# Check if package managers are busy
is_busy() {
    [[ -f /var/lib/pacman/db.lck ]] && return 0
    pgrep -x "pacman|paru|yay" >/dev/null 2>&1 && return 0
    return 1
}

# Return cached result if valid
use_cache() {
    if [[ -f "$CACHE_FILE" ]]; then
        local age=$(( $(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0) ))
        if [[ $age -lt $CACHE_DURATION ]]; then
            cat "$CACHE_FILE"
            return 0
        fi
    fi
    return 1
}

# Background update check
background_check() {
    # Mark that background check is running
    touch "$BACKGROUND_CHECK_FLAG"
    
    # Check for updates
    local pacman=0 aur=0
    
    # Pacman updates
    if command -v checkupdates >/dev/null 2>&1; then
        local pacman_out
        pacman_out=$(timeout 60 checkupdates 2>/dev/null)
        [[ $? -eq 0 && -n "$pacman_out" ]] && pacman=$(echo "$pacman_out" | wc -l)
    fi
    
    # AUR updates (only if paru is available and system not busy)
    if command -v paru >/dev/null 2>&1 && ! is_busy; then
        local aur_out
        aur_out=$(timeout 90 paru -Qua 2>/dev/null | grep -v "^::")
        [[ $? -eq 0 && -n "$aur_out" ]] && aur=$(echo "$aur_out" | wc -l)
    fi
    
    # Generate output
    local total=$((pacman + aur))
    local text class tooltip
    
    if [[ $total -gt 0 ]]; then
        text="$total"
        class="updates-available"
        tooltip="$total update(s) available"
        if [[ $pacman -gt 0 && $aur -gt 0 ]]; then
            tooltip="$pacman pacman + $aur AUR update(s)"
        elif [[ $pacman -gt 0 ]]; then
            tooltip="$pacman pacman update(s)"
        elif [[ $aur -gt 0 ]]; then
            tooltip="$aur AUR update(s)"
        fi
    else
        text="0"
        class="no-updates"
        tooltip="System is up to date"
    fi
    
    # Write to cache atomically
    local tmp_file
    tmp_file=$(mktemp)
    printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' "$text" "$class" "$tooltip" > "$tmp_file"
    mv "$tmp_file" "$CACHE_FILE"
    
    # Remove background check flag
    rm -f "$BACKGROUND_CHECK_FLAG"
}

# Main execution
main() {
    local FORCE_UPDATE="$1"  # pass 'force' to bypass cache/busy checks
    
    # If forced update, do full check synchronously
    if [[ "$FORCE_UPDATE" == "force" ]]; then
        # Create lock
        touch "$LOCK_FILE"
        trap 'rm -f "$LOCK_FILE"' EXIT
        background_check
        cat "$CACHE_FILE"
        exit 0
    fi
    
    # If another instance is running, use cache or default
    if [[ -f "$LOCK_FILE" ]]; then
        local lock_age=$(( $(date +%s) - $(stat -c %Y "$LOCK_FILE" 2>/dev/null || echo 0) ))
        if [[ $lock_age -lt 300 ]]; then
            use_cache || loading_output
            exit 0
        else
            rm -f "$LOCK_FILE"
        fi
    fi
    
    # If package manager is busy, use cache or default
    if is_busy; then
        use_cache || default_output
        exit 0
    fi
    
    # Use cache if still valid
    if use_cache; then
        exit 0
    fi
    
    # If no valid cache and no background check is running, start one
    if [[ ! -f "$BACKGROUND_CHECK_FLAG" ]]; then
        # Create lock
        touch "$LOCK_FILE"
        
        # Start background check
        (
            trap 'rm -f "$LOCK_FILE"' EXIT
            background_check
        ) &
        
        # Detach from parent
        disown
    fi
    
    # Return loading indicator immediately
    loading_output
}

# Run main function
main "$@"
