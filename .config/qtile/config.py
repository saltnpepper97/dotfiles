import os
import subprocess

from typing import Callable
from libqtile import bar, layout, widget, hook, qtile
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.core.manager import Qtile

# Variables

mod = "mod4"
terminal = "alacritty"
launcher = "rofi -show drun -theme config"
editor = "emacsclient -c -a 'emacs' "
session_manager = "/home/dustin/.config/rofi/powermenu.sh"

# Hooks

# Autostart script
@hook.subscribe.startup_complete
def run_every_startup():
    autostart = os.path.expanduser("~/.config/qtile/autostart.sh")
    subprocess.run([autostart])

@hook.subscribe.setgroup
def setgroup():
    for i in range(len(groups)):
        qtile.groups[i].label = ""
        qtile.current_group.label = "󰐾"

@hook.subscribe.client_new
def new_client(client):
    if client.name == "firefox":
        client.focus()

# Keybindings

keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.window.toggle_fullscreen(), desc="Toggle fullscreen on the focused window"),
    Key([mod, "shift"], "c", lazy.window.kill(), desc="Kill focused window"),
    Key([mod], "t", lazy.window.toggle_floating(), desc="Toggle floating on the focused window"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.spawn(session_manager), desc="Show session management menu"),
    Key([mod], "d", lazy.spawn(launcher), desc="Spawn a command using a prompt widget"),
    Key([mod], "e", lazy.spawn(editor), desc="Spawn emacs text editor"),

    # Multimedia Keys
    Key([], "XF86AudioLowerVolume", lazy.spawn("/home/dustin/.local/bin/changeVolume 2%- unmute"), desc="Lower Volume by 5%"),
    Key([], "XF86AudioRaiseVolume", lazy.spawn("/home/dustin/.local/bin/changeVolume 2%+ unmute"), desc="Raise Volume by 5%"),
    Key([], "XF86AudioMute", lazy.spawn("/home/dustin/.local/bin/changeVolume toggle mute"), desc="Mute/Unmute Volume"),
]

groups = [
    # Screen affinity here is used to make
    # sure the groups startup on the right screens
    Group(name="1", screen_affinity=0),
    Group(name="2", screen_affinity=0),
    Group(name="3", screen_affinity=0),
    Group(name="4", screen_affinity=0),
    Group(name="5", matches=[Match(wm_class="Firefox")], screen_affinity=1),
    Group(name="6", screen_affinity=1),
    Group(name="7", screen_affinity=1),
    Group(name="8", screen_affinity=1),
]

def go_to_group(name: str) -> Callable:
    def _inner(qtile: Qtile) -> None:
        if len(qtile.screens) == 1:
            qtile.groups_map[name].toscreen()
            return

        if name in '1234':
            qtile.focus_screen(0)
            qtile.groups_map[name].toscreen()
        else:
            qtile.focus_screen(1)
            qtile.groups_map[name].toscreen()

    return _inner

for i in groups:
    keys.append(Key([mod], i.name, lazy.function(go_to_group(i.name))))
    keys.append(Key([mod, "shift"], i.name, lazy.window.togroup(i.name, switch_group=True)))


layouts = [
    # layout.Columns(border_focus_stack=["#d75f5f", "#8f3d3d"], border_width=2, margin=8),
    # layout.Max(),
    # layout.Stack(num_stacks=2),
    # layout.Bsp(),
    # layout.Matrix(),
    layout.MonadTall(border_focus="#31748f", border_normal="#242933", new_client_position="top", border_width=2, margin=10),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]

widget_defaults = dict(
    foreground="#ebbcba",
    font="RobotoMono Nerd Font Medium",
    fontsize=18,
    padding=3,
)
extension_defaults = widget_defaults.copy()

def search():
    qtile.cmd_spawn("rofi -show drun -theme config")

def menu():
    qtile.cmd_spawn("/home/dustin/.config/rofi/powermenu.sh")

screens = [

    #
    # Screen 1
    #

    Screen(
	    wallpaper='~/pictures/wallpapers/wallpaper-1.png',
	    wallpaper_mode='fill',
        bottom=bar.Bar(
            [
                widget.TextBox(
                    background="#191724",
                    foreground="#ebbcba",
                    fmt=" ", font="Mononoki Nerd Font Propo",
                    fontsize=26,
                    mouse_callbacks={"Button1": menu}
                ),

                widget.Image(filename="~/.config/qtile/assets/1.png"),

                widget.GroupBox(
                    active="#ebbcba",
                    foreground="#e5e9f0",
                    inactive="#191724",
                    this_current_screen_border="#31748f",
                    disable_drag=True,
                    fontsize=25,
                    highlight_method='text',
                    spacing=10,
                    visible_groups=["1", "2", "3", "4"],
                ),

                widget.Image(filename="~/.config/qtile/assets/2.png"),

                widget.Spacer(length=10),

                widget.Image(
                    filename="~/.config/qtile/assets/layout.png",
                    margin=9
                ),
                widget.Spacer(length=5),
                widget.CurrentLayout(),

                widget.Image(filename="~/.config/qtile/assets/3.png"),

                widget.TextBox(
                    background="#191724",
                    fmt="",
                    font="Mononoki Nerd Font Propo",
                    mouse_callbacks={"Button1": search}
                ),
                widget.Spacer(
                    background="#191724",
                    length=5
                ),
                widget.TextBox(
                    background="#191724",
                    fmt="Search",
                    mouse_callbacks={"Button1": search}
                ),

                widget.Image(filename="~/.config/qtile/assets/4.png"),

                widget.Spacer(length=5),

                widget.WindowName(
                    format="{name}",
                    empty_group_string="Desktop",
                    max_chars=35,
                    foreground="#ebbcba"
                ),

                # NB Systray is incompatible with Wayland, consider using StatusNotifier instead
                # widget.StatusNotifier(),

                widget.Systray(
                    icon_size=24,
                    padding=5
                ),
                widget.Spacer(length=10),

                widget.Image(filename="~/.config/qtile/assets/5.png"),

                widget.TextBox(
                    background="#191724",
                    fmt="󰌌",
                    font="Mononoki Nerd Font Propo",
                    fontsize=24
                ),
                widget.Spacer(
                    background="#191724",
                    length=5
                ),
                widget.KeyboardLayout(background="#191724"),

                widget.Spacer(background="#191724", length=10),
                widget.Image(filename="~/.config/qtile/assets/6.png"),

                widget.Spacer(length=10),

                widget.TextBox(
                    fmt="󰏕",
                    font="Mononoki Nerd Font Propo",
                    fontsize=24
                ),
                widget.Spacer(length=5),
                widget.CheckUpdates(
                    colour_have_updates="#ebbcba",
                    colour_no_updates="#ebbcba",
                    distro='Void',
                    no_update_string="No Updates",
                    update_interval=3600
                ),

                widget.Spacer(length=10),

                widget.Image(filename="~/.config/qtile/assets/7.png"),

                widget.Volume(
                    emoji=True,
                    emoji_list=["󰝟", "󰕿", "󰖀", "󰕾"],
                    fontsize=24
                ),
                widget.Spacer(length=5),
                widget.Volume(),

                widget.Image(filename="~/.config/qtile/assets/8.png"),

                widget.TextBox(
                    background="#191724",
                    fmt="",
                    font="Mononoki Nerd Font Propo"
                ),
                widget.Spacer(
                    background="#191724",
                    length=5
                ),
                widget.Clock(
                    background="#191724",
                    format="%a %b %d, %I:%M %p"
                ),

                widget.Spacer(background="#191724", length=10),
            ],
            38,
            background="#26233a",
            # border_width=4,
            # border_color="#1e222a",
            margin=10,
        ),
        # You can uncomment this variable if you see that on X11 floating resize/moving is laggy
        # By default we handle these events delayed to already improve performance, however your system might still be struggling
        # This variable is set to None (no cap) by default, but you can set it to 60 to indicate that you limit it to 60 events per second
        # x11_drag_polling_rate = 60,
    ),

    #
    # Screen 2
    #

    Screen(
	    wallpaper='~/pictures/wallpapers/wallpaper-1.png',
	    wallpaper_mode='fill',
        bottom=bar.Bar(
            [
                widget.TextBox(
                    background="#191724",
                    foreground="#ebbcba",
                    fmt=" ",
                    font="Mononoki Nerd Font Propo",
                    fontsize=26,
                    mouse_callbacks={"Button1": menu}
                ),

                widget.Image(filename="~/.config/qtile/assets/1.png"),

                widget.GroupBox(
                    active="#ebbcba",
                    foreground="#e5e9f0",
                    inactive="#191724",
                    this_current_screen_border="#31748f",
                    disable_drag=True,
                    fontsize=25,
                    highlight_method='text',
                    spacing=10,
                    visible_groups=["5", "6", "7", "8"],
                ),

                widget.Image(filename="~/.config/qtile/assets/2.png"),

                widget.Spacer(length=10),

                widget.Image(
                    filename="~/.config/qtile/assets/layout.png",
                    margin=9
                ),
                widget.Spacer(length=5),
                widget.CurrentLayout(),

                widget.Image(filename="~/.config/qtile/assets/3.png"),

                widget.TextBox(
                    background="#191724",
                    foreground="#ebbcba",
                    fmt="",
                    font="Mononoki Nerd Font Propo",
                    mouse_callbacks={"Button1": search}
                ),
                widget.Spacer(
                    background="#191724",
                    length=5
                ),
                widget.TextBox(
                    background="#191724",
                    fmt="Search",
                    mouse_callbacks={"Button1": search}
                ),

                widget.Image(filename="~/.config/qtile/assets/4.png"),

                widget.Spacer(length=5),

                widget.WindowName(foreground="#ebbcba", format="{name}", empty_group_string="Desktop", max_chars=35),

                widget.Image(filename="~/.config/qtile/assets/8.png"),

                widget.TextBox(
                    background="#191724",
                    foreground="#ebbcba",
                    fmt="",
                    font="Mononoki Nerd Font Propo"
                ),
                widget.Spacer(
                    background="#191724",
                    length=5),
                widget.Clock(
                    background="#191724",
                    foreground="#ebbcba",
                    format="%a %b %d, %I:%M %p"
                ),

                widget.Spacer(background="#191724", length=10),
            ],
            36,
            background="#26233a",
            # border_width=4,  # Draw top and bottom borders
            # border_color="#1e222a",
            margin=10,
        ),
    ),
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
floating_layout = layout.Floating(
    border_width=2,
    border_focus="#ebbcba",
    border_normal="#191724",
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(wm_class="Galculator"),
        Match(wm_class="Lxappearance"),
        Match(wm_class="Pavucontrol"),
        Match(wm_class="System-config-printer.py"),
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "Qtile"
