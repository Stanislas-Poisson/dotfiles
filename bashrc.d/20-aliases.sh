# Aliases.

# ls
alias ls='ls --color=auto --group-directories-first'
alias ll='ls -AlFh'
alias la='ls -A'
alias l='ls -lAh'
alias lt='ls -lAht'

# safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# navigation
alias ..='cd ..'
alias ...='cd ../..'
alias cl='clear'

# system
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias t='tree -a -L 3 --gitignore -I ".git|.idea|.vscode"'
alias tf='tree -a'

# grep
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# git
alias gs='git status'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit -m'
alias gca='git commit --amend'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gl='git pull'
alias glog='git log --oneline --graph --decorate -20'
alias gdiff='git diff'
alias gstash='git stash'
alias gpop='git stash pop'

# make
alias m='make'

# docker
alias dc='docker compose'

# shell
alias reload='exec bash'

# network (the VPS address lives in ~/.ssh/config, host "vps"; see vps-clear in 30-functions.sh)
alias vps='ssh vps'

# WSL
alias wsl-clean='find . -type f -name "*.Identifier" -delete'
