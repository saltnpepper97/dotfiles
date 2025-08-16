# 🏠 Dotfiles

![Arch Linux](https://img.shields.io/badge/Arch%20Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)
![Hyprland](https://img.shields.io/badge/Hyprland-58E1FF?style=for-the-badge&logo=wayland&logoColor=white)
![Neovim](https://img.shields.io/badge/Neovim-57A143?style=for-the-badge&logo=neovim&logoColor=white)
![Kitty](https://img.shields.io/badge/Kitty-000000?style=for-the-badge&logo=gnometerminal&logoColor=white)
![Python](https://img.shields.io/badge/Pywal-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)
![Wayland](https://img.shields.io/badge/Wayland-FFBC00?style=for-the-badge&logo=wayland&logoColor=black)
![Last Commit](https://img.shields.io/github/last-commit/saltnpepper97/dotfiles?style=for-the-badge&color=ffb4a2&labelColor=201a19)
![License](https://img.shields.io/github/license/saltnpepper97/dotfiles?style=for-the-badge&color=ffb4a2&labelColor=201a19)
![Stars](https://img.shields.io/github/stars/saltnpepper97/dotfiles?style=for-the-badge&color=ffb4a2&labelColor=201a19)

My personal dotfiles for a modern Linux desktop setup featuring Hyprland, pywal theming, and automated wallpaper management.

> **⚠️ Note**: I use a 36-key split keyboard, so some keybindings might feel unusual on traditional keyboards. Feel free to fork and adapt the bindings in `.config/hypr/hyprland.conf` to your preferences!

## ✨ Features

- 🎨 **Dynamic theming** with pywal - colors generated from wallpapers
- 🪟 **Hyprland** - Modern Wayland compositor configuration
- 🔔 **Mako** - Notification daemon with pywal integration
- 🔧 **Waybar** - Customizable status bar with scripts
- 📝 **Neovim** - Modern text editor with pywal theme
- 🖥️ **Kitty** - GPU-accelerated terminal emulator
- 🎯 **Custom scripts** for system automation
- 🖼️ **Automated theming** - Wallpaper changes update entire system theme

## 🎨 Theme System

The setup uses pywal to generate color schemes from wallpapers and automatically applies them to:
- GTK 3/4 applications
- Qt applications via Kvantum
- Waybar status bar
- Mako notifications
- Neovim colorscheme
- Yazi file manager

## 📱 Screenshots

***todo***

## 🗂️ Structure

```
.config/
├── hypr/           # Hyprland window manager
├── waybar/         # Status bar configuration
├── mako/           # Notification daemon
├── kitty/          # Terminal emulator
├── nvim/           # Neovim editor
├── yazi/           # File manager
├── wal/            # Pywal templates
└── waypaper/       # Wallpaper manager

.local/bin/
├── wal-set         # Wallpaper + theme setter
├── gtk.py          # GTK theme applicator
├── check-updates   # System update checker
└── ...             # Various utility scripts
```

## 🚀 Installation

### Prerequisites
- [Hyprland](https://hyprland.org/) - Wayland compositor
- [pywal](https://github.com/dylanaraps/pywal) - Color scheme generator
- [Waybar](https://github.com/Alexays/Waybar) - Status bar
- [Mako](https://github.com/emersion/mako) - Notification daemon
- [Kitty](https://sw.kovidgoyal.net/kitty/) - Terminal emulator
- [Neovim](https://neovim.io/) - Text editor
- [Waypaper](https://github.com/anufrievroman/waypaper) - Wallpaper setter

### Quick Setup

```bash
# Clone the repository (bare repo method)
git clone --bare https://github.com/yourusername/dotfiles.git $HOME/.dotfiles

# Create alias
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Checkout files
dotfiles checkout

# Hide untracked files
dotfiles config --local status.showUntrackedFiles no

# Make the alias permanent
echo "alias dotfiles='/usr/bin/git --git-dir=\$HOME/.dotfiles/ --work-tree=\$HOME'" >> ~/.zshrc
```

### Manual Installation

If you encounter conflicts during checkout, back up existing files:

```bash
mkdir -p ~/.config-backup
dotfiles checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} ~/.config-backup/{}
dotfiles checkout
```

## 🎨 Usage

### Setting Wallpapers
Wallpapers are managed through **Waypaper** with automatic theme integration:
1. Use Waypaper to select and set wallpapers
2. The `wal-set` script runs automatically after wallpaper changes
3. All application themes update to match the new wallpaper colors

Simply open Waypaper, choose your wallpaper, and the entire system theme updates automatically!

### Managing Dotfiles
```bash
# Check status
dotfiles status

# Add new config files
dotfiles add ~/.config/new-app/config

# Commit changes
dotfiles commit -m "Add new-app configuration"

# Push to remote
dotfiles push
```

## 🎯 Key Bindings

| Binding | Action |
|---------|---------|
| `Super + Return` | Launch terminal `kitty` |
| `Super + R` | Application launcher `rofi` |
| `Super + C` | Close window |
| `Super + F` | Toggle floating |
| `Super + E` | Open Quick Edits (custom script) |

*See `.config/hypr/hyprland.conf` for complete keybindings*

## 📦 Scripts

| Script | Description |
|--------|-------------|
| `check-updates` | Check for system updates |
| `gtk.py` | Apply GTK themes from pywal |
| `reload-waybar` | Restart waybar with new config |

## 🔧 Customization

### Adding New Templates
Create new pywal templates in `.config/wal/templates/`:

```bash
# Example: Add new application template
cp ~/.config/app/config ~/.config/wal/templates/app-config
# Edit template with pywal color variables
```

### Modifying Themes
Edit the pywal templates to customize how colors are applied to each application.

## 🤝 Contributing

Feel free to:
- Report issues
- Suggest improvements
- Fork and customize for your setup

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [r/unixporn](https://reddit.com/r/unixporn) - Inspiration and community
- [Hyprland](https://hyprland.org/) - Amazing Wayland compositor
- [pywal](https://github.com/dylanaraps/pywal) - Automatic color generation
- All the amazing open-source developers who created these tools

---

⭐ **If you found this helpful, consider giving it a star!**
