#!/usr/bin/env bash
## Basic Rofi Application Launcher
#
## Usage: ./rofi-launcher.sh

# Theme path
theme="$HOME/.config/rofi/config.rasi"

# Launch rofi with drun mode
rofi -show drun -theme "${theme}"
