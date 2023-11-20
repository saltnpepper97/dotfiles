# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd extendedglob nomatch notify
unsetopt beep
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/dustin/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Aliases

alias cl="clear"
alias du="dust"
alias fs="pfetch"
alias ls="exa --icons -l"
alias ps="procs"
alias rm="rm -IR"
alias Rm="sudo rm -IR"
alias vi="nvim"
alias Vi="sudo nvim"

alias xr="sudo xbps-remove"
alias xrr="sudo xbps-remove -R"
alias xqf="sudo xbps-query -f"
alias xu="sudo xbps-install -Su"

# variables

export browser="firefox"
export EDITOR="vim"
export VISUAL="emacsclient"
export PF_INFO="ascii title os kernel shell wm pkgs uptime"

# Path
path+=('/home/dustin/.local/bin')
path+=('/home/dustin/.local/share/pkgs/void-packages')
path+=('/home/dustin/.config/emacs/bin')

export PATH

source /home/dustin/.config/broot/launcher/bash/br
eval "$(starship init zsh)"
alias dotfiles='/usr/bin/git --git-dir=/home/dustin/.dotfiles/ --work-tree=/home/dustin'
