#!/bin/sh

volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
volume=$(echo "$volume" | awk '{print $2}')
volume=$(echo "( $volume * 100 ) / 1" | bc)

notify-send -t 1000 -a 'notify-volume' -h int:value:$volume "Volume: ${volume}%"

# Play the volume changed sound
canberra-gtk-play -i audio-volume-change -d "changeVolume"
