#
#   ███████╗███████╗██╗  ██╗
#   ╚══███╔╝██╔════╝██║  ██║
#     ███╔╝ ███████╗███████║
#    ███╔╝  ╚════██║██╔══██║
#   ███████╗███████║██║  ██║
#   ╚══════╝╚══════╝╚═╝  ╚═╝
#

# ===============================================
# PATH & ENVIRONMENT VARIABLES
# ===============================================

# PATH configuration
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Add local bin to PATH if it exists
if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Environment variables
export EDITOR='nvim'
export VISUAL='nvim'
export LANG=en_US.UTF-8

# ===============================================
# OH MY ZSH CONFIGURATION
# ===============================================

# Path to Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Disable OMZ themes since we're using Starship
ZSH_THEME=""

# Completion settings
HYPHEN_INSENSITIVE="true"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

# Auto-update behavior
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 13

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
    zoxide
)

# Initialize Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Additional plugin sources
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh

# ===============================================
# ZSH OPTIONS & HISTORY CONFIGURATION
# ===============================================

# History settings
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000

# History options
setopt HIST_IGNORE_DUPS          # Don't record duplicate entries
setopt HIST_IGNORE_ALL_DUPS      # Delete old duplicate entries
setopt HIST_FIND_NO_DUPS         # Don't display previously found duplicates
setopt HIST_IGNORE_SPACE         # Don't record entries starting with space
setopt HIST_SAVE_NO_DUPS         # Don't write duplicates to history file
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks
setopt SHARE_HISTORY             # Share history between sessions

# General ZSH options
setopt autocd extendedglob nomatch notify
setopt AUTO_PUSHD                # Auto push directories to stack
setopt PUSHD_IGNORE_DUPS         # Don't store duplicate directories
setopt PUSHD_SILENT              # Silence pushd/popd output

unsetopt beep
bindkey -v                       # Vi mode

# ===============================================
# KEY BINDINGS
# ===============================================

# History substring search bindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# ===============================================
# ALIASES
# ===============================================

# ----------------- TERMINAL CONTROL -----------------
alias reload='source ~/.zshrc'
alias cl="clear"
alias x='exit'
alias :q='exit'                  # vim-like exit

# ----------------- FILE OPERATIONS -----------------
alias cp="cp -iv"                # interactive copy
alias mv="mv -iv"                # interactive move
alias ln="ln -iv"                # interactive link
alias mkdir="mkdir -pv"          # create parent dirs verbosely

# File managers
alias y="yazi"
alias bin="cd ~/.local/bin; clear; eza --icons -l"

# Safe deletion with trash
alias rm="echo 'Use trash-put instead of rm, or use /bin/rm for real deletion'"
alias tp="trash-put"
alias tl="trash-list"
alias tr="trash-restore"
alias te="trash-empty"
alias rmf="/bin/rm -rf"          # real rm when needed

# ----------------- NAVIGATION & LISTING -----------------
alias ls="eza --icons --color=always --group-directories-first"
alias l="eza --icons --color=always --group-directories-first"
alias la="eza -a --color=always --group-directories-first --icons"
alias ll="eza -l --color=always --group-directories-first --icons"
alias lla="eza -la --color=always --group-directories-first --icons"
alias lt="eza -la --color=always --group-directories-first --sort=modified"
alias lh="eza -la --color=always --group-directories-first --binary"
alias tree="eza --tree --color=always --group-directories-first"
alias ltree="eza --tree --color=always --group-directories-first --long"

# ----------------- TEXT EDITORS -----------------
alias nv="nvim"
alias v="nvim"
alias Nv="sudo nvim"
alias V="sudo nvim"
alias lazy="cd ~/.config/nvim/lua/plugins/; clear; eza --icons -l"

# ----------------- VERSION CONTROL -----------------
# Git shortcuts (OMZ git plugin provides more)
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

# Dotfiles management
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# ----------------- PACKAGE MANAGEMENT -----------------
# Pacman & Paru
alias pi="paru -S"               # install package(s)
alias pq="paru -Ss"              # search packages
alias pu="paru -Su"              # update packages
alias pr="paru -R"               # remove package(s)
alias pra="paru -Rns"            # remove with dependencies
alias psc="paru -Sc"             # clean cache
alias pl="paru -Ql"              # list package files
alias pinfo="paru -Qi"           # package info
alias pfu="paru -Syu"            # full system upgrade
alias pau="paru -Sua"            # upgrade AUR packages only
alias po="paru -Qtdq"            # list orphaned packages

# Mirror management
alias update-mirrors='sudo reflector --country "Canada" --age 6 --protocol https --sort rate --save /etc/pacman.d/mirrorlist'

# ----------------- SYSTEM MANAGEMENT -----------------
# Mounting
alias mount="mount | column -t"
alias umount="umount -v"

# SystemD control
alias sctl="systemctl"
alias sctle="systemctl enable"
alias sctld="systemctl disable"
alias sctls="systemctl start"
alias sctlr="systemctl restart"
alias sctlst="systemctl stop"
alias sctlstat="systemctl status"
alias sctlu="systemctl --user"
alias jctl="journalctl"
alias jctlf="journalctl -f"

# System info
alias uptime="uptime -p"
alias ff="fastfetch"

# GRUB
alias update-grub="sudo grub-mkconfig -o /boot/grub/grub.cfg"

# ----------------- AI/LLM TOOLS -----------------
alias qwen="ollama run qwen3:14b"
alias oss="ollama run gpt-oss:20b"
alias deepseek="ollama run deepseek-r1:14b"

# ----------------- CONFIGURATION FILES -----------------
# Quick config edits
alias zshrc="$EDITOR ~/.zshrc"
alias nvconf="$EDITOR ~/.config/nvim/init.lua"

# Hyprland configs
alias hyprconf="$EDITOR ~/.config/hypr/hyprland.conf"
alias idleconf="$EDITOR ~/.config/hypr/hypridle.conf"
alias lockconf="$EDITOR ~/.config/hypr/hyprlock.conf"

# UI configs
alias barconf="$EDITOR ~/.config/waybar/config.jsonc"
alias barstyle="$EDITOR ~/.config/waybar/style.css"
alias rconf="$EDITOR ~/.config/rofi/config.rasi"
alias kittyconf="$EDITOR ~/.config/kitty/kitty.conf"


