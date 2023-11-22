#!/bin/bash
#
# autostart.sh

function run {
	if ! pgrep -f "$1" ;
	then
		$@&
	fi
}

run blueman-applet
run clipit
run dunst
run emacs --daemon
run /usr/libexec/polkit-gnome-authentication-agent-1
run numlockx
run picom
run solaar -w hide
run /home/dustin/.local/bin/idleHook
run pipewire

sleep 2 && notify-send -u low "System started, Welcome $USER"
