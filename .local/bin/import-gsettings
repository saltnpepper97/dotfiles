#!/bin/sh

# Hardcoded theme settings - edit these values as needed
gtk_theme="adw-gtk3-dark"
icon_theme="Papirus-Dark"
cursor_theme="Bibata-Modern-Ice"
font_name="Cantarell 11"

gnome_schema="org.gnome.desktop.interface"

safe_gsettings() {
    if [ -n "$2" ]; then
        gsettings set "$1" "$2" "$3" 2>/dev/null || \
        echo "Warning: failed to set $2" >&2
    fi
}

if ! command -v gsettings >/dev/null 2>&1; then
    echo "Warning: gsettings not found. Skipping GTK settings." >&2
    return 0 2>/dev/null || exit 0
fi

echo "Setting GTK themes manually..."
safe_gsettings "$gnome_schema" "gtk-theme" "$gtk_theme"
safe_gsettings "$gnome_schema" "icon-theme" "$icon_theme"
safe_gsettings "$gnome_schema" "cursor-theme" "$cursor_theme"
safe_gsettings "$gnome_schema" "font-name" "$font_name"

echo "GTK settings applied:"
echo "  Theme: $gtk_theme"
echo "  Icons: $icon_theme"
echo "  Cursor: $cursor_theme"
echo "  Font: $font_name"
