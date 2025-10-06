#!/bin/bash
# Configuration
CACHE_FILE="/tmp/waybar-updates.json"
LOCK_FILE="/tmp/waybar-updates.lock"
CACHE_DURATION=1800  # 30 minutes
BACKGROUND_CHECK_FLAG="/tmp/waybar-updates-bg.flag"

# Default output
default_output() {
    echo '{"text":"0","class":"checking","tooltip":"Checking for updates..."}'
}

# Loading output
loading_output() {
    echo '{"text":"0","class":"checking","tooltip":"Checking for updates..."}'
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

# Acquire lock with timeout
acquire_lock() {
    local timeout=${1:-300}  # 5 minutes default
    local count=0
    
    while [[ -f "$LOCK_FILE" ]] && [[ $count -lt $timeout ]]; do
        local lock_age=$(( $(date +%s) - $(stat -c %Y "$LOCK_FILE" 2>/dev/null || echo 0) ))
        # If lock is too old, remove it
        if [[ $lock_age -gt 300 ]]; then
            rm -f "$LOCK_FILE"
            break
        fi
        sleep 1
        ((count++))
    done
    
    # Try to create lock
    if (set -C; echo $$ > "$LOCK_FILE") 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Release lock
release_lock() {
    rm -f "$LOCK_FILE"
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
    
    # AUR updates (only if paru is available and system not busy for non-force calls)
    if command -v paru >/dev/null 2>&1; then
        # For force calls, we always check AUR even if busy
        if [[ "$1" == "force" ]] || ! is_busy; then
            local aur_out
            aur_out=$(timeout 90 paru -Qua 2>/dev/null | grep -v "^::")
            [[ $? -eq 0 && -n "$aur_out" ]] && aur=$(echo "$aur_out" | wc -l)
        fi
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
        # Try to acquire lock, but don't wait too long for force updates
        if acquire_lock 10; then
            trap 'release_lock' EXIT INT TERM
            # Clear old cache to force fresh check
            rm -f "$CACHE_FILE"
            background_check "force"
            cat "$CACHE_FILE"
            release_lock
            trap - EXIT INT TERM
        else
            # If we can't get lock quickly, just use cache or default
            use_cache || default_output
        fi
        exit 0
    fi
    
    # Check if lock exists and is recent
    if [[ -f "$LOCK_FILE" ]]; then
        local lock_age=$(( $(date +%s) - $(stat -c %Y "$LOCK_FILE" 2>/dev/null || echo 0) ))
        if [[ $lock_age -lt 300 ]]; then
            use_cache || loading_output
            exit 0
        else
            # Remove stale lock
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
        # Try to acquire lock for background check
        if acquire_lock 5; then
            # Start background check
            (
                trap 'release_lock' EXIT INT TERM
                background_check
                release_lock
            ) &
            
            # Detach from parent
            disown
        fi
    fi
    
    # Return loading indicator immediately
    loading_output
}

# Run main function
main "$@"
