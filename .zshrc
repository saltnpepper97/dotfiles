#
#   ███████╗███████╗██╗  ██╗
#   ╚══███╔╝██╔════╝██║  ██║
#     ███╔╝ ███████╗███████║
#    ███╔╝  ╚════██║██╔══██║
#   ███████╗███████║██║  ██║
#   ╚══════╝╚══════╝╚═╝  ╚═╝
#     


# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# We'll disable OMZ themes since we're using Starship
ZSH_THEME=""

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Auto-update behavior
zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# History stamps
HIST_STAMPS="yyyy-mm-dd"

# Enhanced plugins for better experience
plugins=(
    git
    colored-man-pages
    command-not-found
    extract
    sudo
    web-search
    copypath
    copyfile
    dirhistory
    history-substring-search
    starship
)

source $ZSH/oh-my-zsh.sh

# zsh-autosuggestions
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh

# User configuration

# History settings (enhanced from your original config)
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry
setopt SHARE_HISTORY             # Share history between all sessions

# Other useful options
setopt autocd extendedglob nomatch notify
setopt AUTO_PUSHD                # Push the current directory visited on the stack
setopt PUSHD_IGNORE_DUPS         # Do not store duplicates in the stack
setopt PUSHD_SILENT              # Do not print the directory stack after pushd or popd

unsetopt beep
bindkey -v  # Vi mode

# Preferred editor
export EDITOR='nvim'
export VISUAL='nvim'

# Language environment
export LANG=en_US.UTF-8

# Add local bin to PATH if it exists
if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

#################
###  Aliases  ###
#################

# Terminal Control
alias reload='source ~/.zshrc'   # reload zsh config
alias cl="clear"
alias x='exit'                   # quick exit
alias :q='exit'                  # vim-like exit

# File/Directory Operations
alias cp="cp -iv"                  # interactive copy
alias mv="mv -iv"                  # interactive move
alias ln="ln -iv"                  # interactive link
alias mkdir="mkdir -pv"            # create parent dirs and be verbose
alias y="yazi"                     # yazi file manager
alias bin="cd ~/.local/bin; clear; eza --icons -l"

# Code Editor
alias nv="nvim"
alias v="nvim"
alias Nv="sudo nvim"
alias V="sudo nvim"
alias lazy="cd ~/.config/nvim/lua/plugins/; clear; eza --icons -l"

# Dotfiles
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Git (enhanced - OMZ git plugin adds more)
alias g="git"
alias gclone="git clone"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias gd="git diff"
alias gb="git branch"
alias gco="git checkout"
alias glog="git log --oneline --decorate --graph"

# GRUB
alias update-grub="sudo grub-mkconfig -o /boot/grub/grub.cfg"

# Navigation with eza
alias ls="eza --icons --color=always --group-directories-first"
alias l="eza --icons --color=always --group-directories-first"
alias la="eza -a --color=always --group-directories-first --icons"
alias lla="eza -la --color=always --group-directories-first --icons"
alias ll="eza -l --color=always --group-directories-first --icons"
alias lt="eza -la --color=always --group-directories-first --sort=modified"
alias lh="eza -la --color=always --group-directories-first --binary"
alias tree="eza --tree --color=always --group-directories-first"
alias ltree="eza --tree --color=always --group-directories-first --long"

# Safe deletion
alias rm="echo 'Use trash-put instead of rm, or use /bin/rm for real deletion'"
alias tp="trash-put"        # trash files
alias tl="trash-list"       # list trash
alias tr="trash-restore"    # restore from trash
alias te="trash-empty"      # empty trash
alias rmf="/bin/rm -rf"     # real rm when you need it

# Pacman & Paru Package Managers
alias pi="paru -S"          # install package(s)
alias pq="paru -Ss"         # search packages
alias pu="paru -Su"         # update all packages
alias pr="paru -R"          # remove package(s)
alias pra="paru -Rns"       # remove package(s) recursively
alias psc="paru -Sc"        # clean cache
alias pl="paru -Ql"         # list installed files of a package
alias pinfo="paru -Qi"      # package info (installed)
alias pfu="paru -Syu"       # full system upgrade
alias pau="paru -Sua"       # upgrade only AUR packages
alias po="paru -Qtdq"       # list orphaned packages

alias update-mirrors='sudo reflector --country "Canada" --age 6 --protocol https --sort rate --save /etc/pacman.d/mirrorlist'

# Mounting
alias mount="mount | column -t"   # pretty mount output
alias umount="umount -v"          # verbose unmount

# System Control (systemd)
alias sctl="systemctl"
alias sctle="systemctl enable"
alias sctld="systemctl disable"
alias sctls="systemctl start"
alias sctlr="systemctl restart"
alias sctlst="systemctl stop"
alias sctlstat="systemctl status"
alias sctlu="systemctl --user"    # user services
alias jctl="journalctl"
alias jctlf="journalctl -f"       # follow logs

# System Information
alias uptime="uptime -p"          # pretty uptime
alias ff="fastfetch"

# Quick Edits
alias barconf="$EDITOR ~/.config/waybar/config.jsonc"   # edit waybar config
alias barstyle="$EDITOR ~/.config/waybar/style.css"     # edit waybar style
alias nvconf="$EDITOR ~/.config/nvim/init.lua"          # edit neovim config
alias rconf="$EDITOR ~/.config/rofi/config.rasi"        # edit rofi config
alias zshrc="$EDITOR ~/.zshrc"                          # edit zsh config
alias kittyconf="$EDITOR ~/.config/kitty/kitty.conf"    # edit kitty config
alias hyprconf="$EDITOR ~/.config/hypr/hyprland.conf"   # edit hyprland config
alias idleconf="$EDITOR ~/.config/hypr/hypridle.conf"   # edit hypridle config
alias lockconf="$EDITOR ~/.config/hypr/hyprlock.conf"   # edit hyprlock config

# Key bindings for history substring search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down


