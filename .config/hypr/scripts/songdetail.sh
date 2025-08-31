#!/bin/bash

# Try to get song info
song_info=$(playerctl metadata --format '   {{artist}} - {{title}}' 2>/dev/null)

echo "$song_info"
