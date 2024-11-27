# Source zsh plugins
source $(brew --prefix)/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

export LANG=en_US.UTF-8

eval "$(starship init zsh)"
export STARSHIP_CONFIG=~/.config/starship/starship.toml
eval "$(zoxide init --cmd cd zsh)"


# Aliases for common dirs
alias home="cd ~"

# System Aliases
alias ..="cd .."
alias x="exit"
alias cl='clear'
alias ssh="TERM=xterm-256color ssh"

# Git Aliases
alias gc="git commit"
alias gca="git commit -a -m"
alias gp="git push origin HEAD"
alias gpu="git pull origin"
alias gst="git status"
alias glog="git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit"
alias gdiff="git diff"
alias gco="git checkout"
alias gb='git branch'
alias gba='git branch -a'
alias gadd='git add'
alias gr='git remote'
alias gre='git reset'

# Docker Aliases
alias dco="docker compose"
alias dps="docker ps"
alias dpa="docker ps -a"
alias dl="docker ps -l -q"
alias dx="docker exec -it"


export EDITOR='code'
export NVM_DIR=~/.nvm

export PATH=/opt/homebrew/bin:$PATH
source $(brew --prefix nvm)/nvm.sh
export PATH="$HOME/.emacs.d/bin:$PATH"
export XDG_CONFIG_HOME="/Users/marcus/.config"
