#!/bin/bash
CACHE_FILE="/tmp/waybar-updates.json"
AUR_CACHE_FILE="/tmp/waybar-aur-updates.json"
LOCK_FILE="/tmp/waybar-updates.lock"
CACHE_DURATION=1800       # Arch cache: 30m
MIN_INTERVAL=300          # Min interval: 5m
AUR_CACHE_DURATION=$((48*3600)) # AUR cache: 48h
AUR_RETRY_DELAY=$((4*3600))    # Retry after rate limit: 4h

# Return cached JSON or default 0
return_cached() {
    if [[ -f "$CACHE_FILE" && -s "$CACHE_FILE" ]]; then
        cat "$CACHE_FILE"
    else
        echo '{"text":"0","class":"no-updates"}'
    fi
}

# More precise check for package manager activity
is_package_manager_busy() {
    # Check for pacman database lock (more reliable than process checking)
    [[ -f /var/lib/pacman/db.lck ]] && return 0
    
    # Check for specific package manager processes (not substrings)
    pgrep -x "pacman\|paru\|yay" >/dev/null 2>&1 && return 0
    
    # Check for package manager processes with common flags
    pgrep -f "^pacman -S\|^paru -S\|^yay -S" >/dev/null 2>&1 && return 0
    
    return 1
}

# Prevent multiple concurrent updates with shorter timeout
[[ -f "$LOCK_FILE" && $(( $(date +%s) - $(stat -c %Y "$LOCK_FILE") )) -lt 60 ]] && return_cached && exit

# If package manager is busy, return cached and exit immediately
if is_package_manager_busy; then
    return_cached
    exit 0
fi

# Check cache age first - if recent, just return cached
if [[ -f "$CACHE_FILE" ]]; then
    cache_age=$(( $(date +%s) - $(stat -c %Y "$CACHE_FILE") ))
    if [[ $cache_age -lt $MIN_INTERVAL ]]; then
        return_cached
        exit 0
    fi
fi

touch "$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"' EXIT

# Immediate output for Waybar
return_cached

# Background update with better error handling
(
    # Set trap for cleanup in background process too
    trap 'rm -f "$LOCK_FILE" 2>/dev/null' EXIT
    
    # More conservative check before starting
    sleep 1  # Brief delay to avoid race conditions
    if is_package_manager_busy; then
        exit 0
    fi
    
    # Pacman updates with timeout and error handling
    pacman=0
    if command -v checkupdates &>/dev/null; then
        pacman_out=$(timeout 60 checkupdates 2>/dev/null)
        [[ -n "$pacman_out" ]] && pacman=$(echo "$pacman_out" | wc -l)
    fi
    
    # AUR updates with better rate limiting
    aur=0
    rate_file="/tmp/waybar-aur-ratelimit"
    
    # Check AUR cache first
    if [[ -f "$AUR_CACHE_FILE" ]]; then
        aur_age=$(( $(date +%s) - $(stat -c %Y "$AUR_CACHE_FILE") ))
        if [[ $aur_age -lt $AUR_CACHE_DURATION ]]; then
            aur=$(cat "$AUR_CACHE_FILE" 2>/dev/null || echo 0)
        fi
    fi
    
    # Only check AUR if cache is stale and we're not rate limited
    if [[ $aur -eq 0 && (! -f "$rate_file" || $(( $(date +%s) - $(stat -c %Y "$rate_file") )) -gt $AUR_RETRY_DELAY) ]]; then
        # Final comprehensive check before running paru
        if ! is_package_manager_busy && command -v paru &>/dev/null; then
            # Use a more specific lock file
            exec 200>/var/lock/waybar-paru.lock
            if flock -n 200; then
                # Double-check one more time
                if ! is_package_manager_busy; then
                    # Run paru with minimal output and strict timeout
                    paru_out=$(timeout 120 paru -Qua 2>&1 | grep -v "^::" | head -100)
                    paru_exit=$?
                    
                    if [[ $paru_exit -eq 0 && -n "$paru_out" ]]; then
                        aur=$(echo "$paru_out" | wc -l)
                    elif [[ $paru_exit -eq 124 ]]; then
                        # Timeout occurred
                        echo "Waybar: paru timed out" >&2
                    elif echo "$paru_out" | grep -qiE "429|too many requests|rate.limit"; then
                        touch "$rate_file"
                        echo "Waybar: AUR rate limited" >&2
                    fi
                fi
                flock -u 200
            fi
            exec 200>&-
        fi
    fi
    
    # Ensure aur is a valid number
    [[ ! "$aur" =~ ^[0-9]+$ ]] && aur=0
    
    # Save AUR cache
    echo "$aur" > "$AUR_CACHE_FILE"
    
    # Combine totals
    total=$((pacman + aur))
    if [[ $total -gt 0 ]]; then
        cls="updates-available"
        txt="$total"
        [[ $pacman -gt 0 && $aur -gt 0 ]] && txt="${total} (${pacman}+${aur})"
    else
        cls="no-updates"
        txt="0"
    fi
    
    # Write to cache atomically
    tmp=$(mktemp)
    if printf '{"text":"%s","class":"%s"}\n' "$txt" "$cls" > "$tmp"; then
        mv "$tmp" "$CACHE_FILE"
    else
        rm -f "$tmp"
    fi
    
) &

# Don't wait for background process
disown
