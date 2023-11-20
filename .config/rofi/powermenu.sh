#!/bin/bash
#
# powermenu.sh

dir="$HOME/.config/rofi"
theme="powermenu"

# Options
shutdown='󰐥'
reboot='󰑐'
lock='󰌾'
suspend='󰤄'
logout='󰗽'
yes='󰄬'
no='󰅖'

rofi_cmd() {
    rofi -dmenu -theme ${dir}/${theme}.rasi
}

confirm_cmd() {
    rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 350px;}' \
        -theme-str 'mainbox {children: [ "message", "listview" ];}' \
        -theme-str 'listview {columns: 2; lines: 1;}' \
        -theme-str 'element-text {horizontal-align: 0.5;}' \
        -theme-str 'textbox {horizontal-align: 0.5;}' \
        -dmenu \
        -p 'Confirmation' \
        -mesg 'Are you sure?' \
        -theme ${dir}/${theme}.rasi
}

confirm_exit() {
    echo -e "$yes\n$no" | confirm_cmd
}

run_rofi() {
    echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

run_cmd() {
    selected="$(confirm_exit)"
    if [[ "$selected" == "$yes" ]]; then
        if [[ $1 == '--shutdown' ]]; then
            sudo poweroff
        elif [[ $1 == '--reboot' ]]; then
            sudo reboot
        elif [[ $1 == 'suspend' ]]; then
            amixer set Master mute
            sudo suspend
        elif [[ $1 == '--logout' ]]; then
            pkill pipewire && qtile cmd-obj -o cmd -f shutdown
        fi
    else
        exit 0
    fi
}

chosen="$(run_rofi)"
case ${chosen} in
    $shutdown)
        run_cmd --shutdown
        ;;
    $reboot)
        run_cmd --reboot
        ;;
    $lock)
        betterlockscreen -l
        ;;
    $suspend)
        run_cmd --suspend
        ;;
    $logout)
        run_cmd --logout
        ;;
esac
