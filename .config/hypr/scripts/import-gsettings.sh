#!/bin/sh
# Hardcoded theme settings - edit these values as needed
gtk_theme="adw-gtk3-dark"
icon_theme="Papirus-Dark"
cursor_theme="Bibata-Modern-Ice"
cursor_size="24"
font_name="Cantarell 11"
gnome_schema="org.gnome.desktop.interface"

safe_gsettings() {
    if [ -n "$2" ]; then
        gsettings set "$1" "$2" "$3" 2>/dev/null || \
        echo "Warning: failed to set $2" >&2
    fi
}

# Create GTK config directory if it doesn't exist
mkdir -p "$HOME/.config/gtk-3.0"

# Update GTK 3.0 settings.ini
gtk3_config="$HOME/.config/gtk-3.0/settings.ini"
echo "Updating GTK 3.0 settings.ini..."

# Create or update the settings.ini file
cat > "$gtk3_config" << EOF
[Settings]
gtk-theme-name=$gtk_theme
gtk-icon-theme-name=$icon_theme
gtk-cursor-theme-name=$cursor_theme
gtk-cursor-theme-size=$cursor_size
gtk-font-name=$font_name
gtk-application-prefer-dark-theme=true
EOF



# Apply gsettings if available
if command -v gsettings >/dev/null 2>&1; then
    echo "Setting GTK themes via gsettings..."
    safe_gsettings "$gnome_schema" "gtk-theme" "$gtk_theme"
    safe_gsettings "$gnome_schema" "icon-theme" "$icon_theme"
    safe_gsettings "$gnome_schema" "cursor-theme" "$cursor_theme"
    safe_gsettings "$gnome_schema" "cursor-size" "$cursor_size"
    safe_gsettings "$gnome_schema" "font-name" "$font_name"
else
    echo "Warning: gsettings not found. Skipping gsettings configuration." >&2
fi

echo "GTK settings applied:"
echo "  Theme: $gtk_theme"
echo "  Icons: $icon_theme"
echo "  Cursor: $cursor_theme"
echo "  Cursor Size: $cursor_size"
echo "  Font: $font_name"
echo ""
echo "Configuration file updated:"
echo "  GTK 3.0: $gtk3_config"
