#!/bin/bash

# Configuration
CACHE_FILE="/tmp/waybar-updates.json"
LOCK_FILE="/tmp/waybar-updates.lock"
LOG_FILE="/tmp/waybar-updates.log"
CACHE_DURATION=1800  # 30 minutes in seconds
MINIMUM_INTERVAL=300 # 5 minutes minimum between checks
MAX_LOCK_AGE=300     # Remove stale locks after 5 minutes

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
}

# Cleanup function
cleanup() {
    rm -f "$LOCK_FILE"
    log "Script completed, lock removed"
}
trap cleanup EXIT

# Check if another instance is running
check_lock() {
    if [[ -f "$LOCK_FILE" ]]; then
        # Check if lock is stale
        local lock_age=$(( $(date +%s) - $(stat -c %Y "$LOCK_FILE" 2>/dev/null || echo 0) ))
        if [[ $lock_age -gt $MAX_LOCK_AGE ]]; then
            log "Removing stale lock (age: ${lock_age}s)"
            rm -f "$LOCK_FILE"
        else
            log "Another instance is running (lock age: ${lock_age}s)"
            return 1
        fi
    fi
    return 0
}

# Get cache age in seconds
get_cache_age() {
    if [[ -f "$CACHE_FILE" ]]; then
        local cache_time=$(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)
        echo $(( $(date +%s) - cache_time ))
    else
        echo 999999  # Very old if doesn't exist
    fi
}

# Return cached result if valid
return_cached() {
    if [[ -f "$CACHE_FILE" ]]; then
        cat "$CACHE_FILE"
        log "Returned cached result"
        return 0
    else
        printf '{"text": "?", "class": "checking"}\n'
        log "No cache available, returned checking state"
        return 1
    fi
}

# Count package updates with timeout and error handling
count_pacman_updates() {
    log "Checking pacman updates..."
    local result
    if timeout 60 checkupdates 2>/dev/null; then
        result=$(timeout 60 checkupdates 2>/dev/null | wc -l)
        log "Pacman updates found: $result"
        echo "$result"
    else
        log "Pacman check failed or timed out"
        echo "0"
    fi
}

count_aur_updates() {
    if ! command -v paru &>/dev/null; then
        log "paru not found, skipping AUR updates"
        echo "0"
        return
    fi
    
    log "Checking AUR updates..."
    local result
    if timeout 120 paru -Qua 2>/dev/null >/dev/null; then
        result=$(timeout 120 paru -Qua 2>/dev/null | wc -l)
        log "AUR updates found: $result"
        echo "$result"
    else
        log "AUR check failed or timed out"
        echo "0"
    fi
}

# Main logic
main() {
    log "Script started"
    
    # Check if we can run (no other instance)
    if ! check_lock; then
        return_cached
        exit 0
    fi
    
    local cache_age=$(get_cache_age)
    log "Cache age: ${cache_age}s"
    
    # If cache is fresh enough, use it
    if [[ $cache_age -lt $MINIMUM_INTERVAL ]]; then
        log "Cache is too fresh (${cache_age}s < ${MINIMUM_INTERVAL}s), using cached result"
        return_cached
        exit 0
    fi
    
    # If cache exists and is not too old, use it but maybe refresh in background
    if [[ $cache_age -lt $CACHE_DURATION ]]; then
        log "Cache is acceptable (${cache_age}s < ${CACHE_DURATION}s), using cached result"
        return_cached
        exit 0
    fi
    
    # Cache is old or doesn't exist, we need to check
    log "Cache is stale or missing, performing update check"
    
    # Create lock
    touch "$LOCK_FILE"
    
    # Return cached result first if available (for immediate UI response)
    if [[ -f "$CACHE_FILE" ]]; then
        cat "$CACHE_FILE"
        log "Returned stale cache while updating"
    else
        printf '{"text": "⟳", "class": "checking"}\n'
        log "No cache, returned checking indicator"
    fi
    
    # Perform the actual checks
    log "Starting package checks..."
    pac=$(count_pacman_updates)
    aur=$(count_aur_updates)
    total=$((pac + aur))
    
    log "Total updates found: $total (pacman: $pac, aur: $aur)"
    
    # Generate result
    local result_class
    local result_text
    
    if [[ $total -gt 0 ]]; then
        result_class="updates-available"
        result_text="$total"
        if [[ $pac -gt 0 && $aur -gt 0 ]]; then
            result_text="${total} (${pac}+${aur})"
        fi
    else
        result_class="no-updates"
        result_text="0"
    fi
    
    # Save to cache
    printf '{"text": "%s", "class": "%s"}\n' "$result_text" "$result_class" > "$CACHE_FILE"
    log "Updated cache with result: $result_text ($result_class)"
    
    # Don't auto-signal waybar - let the interval handle it
    log "Cache updated, waybar will refresh on next interval"
}

# Run main function
main

# Cleanup old log entries (keep last 100 lines)
if [[ -f "$LOG_FILE" ]] && [[ $(wc -l < "$LOG_FILE") -gt 100 ]]; then
    tail -n 50 "$LOG_FILE" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "$LOG_FILE"
fi
