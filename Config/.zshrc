# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '~/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Useful Aliases

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ll="ls -alF"
alias la="ls -A"
alias l="ls -CF"

# File operations
alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -iv"
alias mkdir="mkdir -pv"

# Git shortcuts
alias gst="git status"
alias gl="git log"
alias gp="git pull"
alias gco="git checkout"
alias gcm="git commit -m"
alias gb="git branch"
alias ga="git add"
alias gpl="git pull"
alias gps="git push"

# Update and upgrade
alias update="sudo apt update && sudo apt upgrade -y"

# Network
alias ip="ip -c a"
alias ports="netstat -tulanp"

# Other shortcuts
alias cls="clear"
alias h="history"
alias j="jobs -l"

# Docker
alias d="docker"
alias dps="docker ps"
alias di="docker images"
alias db="docker build"
alias dr="docker run"
alias dexec="docker exec -it"

# Source .env file
source ~/.env

######
