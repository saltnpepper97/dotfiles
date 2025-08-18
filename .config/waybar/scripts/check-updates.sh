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

# Prevent multiple concurrent updates
[[ -f "$LOCK_FILE" && $(( $(date +%s) - $(stat -c %Y "$LOCK_FILE") )) -lt 300 ]] && return_cached && exit
touch "$LOCK_FILE"

# Immediate output for Waybar
return_cached

# Background update
(
    # Pacman updates
    pacman=$(timeout 60 checkupdates 2>/dev/null | wc -l)

    # AUR updates
    aur=0
    rate_file="/tmp/waybar-aur-ratelimit"
    if [[ -f "$AUR_CACHE_FILE" ]]; then
        aur_age=$(( $(date +%s) - $(stat -c %Y "$AUR_CACHE_FILE") ))
        [[ $aur_age -lt $AUR_CACHE_DURATION ]] && aur=$(cat "$AUR_CACHE_FILE")
    fi

    if [[ $aur -eq 0 && (! -f "$rate_file" || $(( $(date +%s) - $(stat -c %Y "$rate_file") )) -gt $AUR_RETRY_DELAY) ]]; then
        if command -v paru &>/dev/null; then
            out=$(timeout 180 paru -Qua 2>&1)
            if [[ $? -eq 0 ]]; then
                aur=$(echo "$out" | wc -l)
            elif echo "$out" | grep -qE "429|Too Many Requests|rate.limit"; then
                touch "$rate_file"
            fi
        fi
    fi

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

    # Write to cache safely
    tmp=$(mktemp)
    printf '{"text":"%s","class":"%s"}\n' "$txt" "$cls" > "$tmp"
    mv "$tmp" "$CACHE_FILE"

    rm -f "$LOCK_FILE"
) &
