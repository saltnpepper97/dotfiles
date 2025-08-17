#!/bin/bash

# Get current hour (24-hour format)
hour=$(date +%H)

# Convert to integer for comparison
hour=$((10#$hour))

# Determine greeting based on time
if [ $hour -ge 5 ] && [ $hour -lt 12 ]; then
    greeting="Good morning"
elif [ $hour -ge 12 ] && [ $hour -lt 17 ]; then
    greeting="Good afternoon"
elif [ $hour -ge 17 ] && [ $hour -lt 21 ]; then
    greeting="Good evening"
else
    greeting="Good night"
fi

# Output the greeting with username
echo "$greeting, $USER"
