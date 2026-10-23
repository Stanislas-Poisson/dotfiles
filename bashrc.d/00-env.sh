# Environment, PATH, history and colors.

export EDITOR="code --wait"
export VISUAL="code --wait"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
GPG_TTY=$(tty)
export GPG_TTY

# Consolidated PATH: ~/.local/bin first, then each directory once (first occurrence wins).
# Safe to source again: no entry is ever added twice.
_dedupe_path() {
    local IFS=: dir out=""
    for dir in "${HOME}/.local/bin" ${PATH}; do
        case ":${out}:" in
            *":${dir}:"*) ;;
            *) out="${out:+${out}:}${dir}" ;;
        esac
    done
    PATH="${out}"
    export PATH
}
_dedupe_path
unset -f _dedupe_path

# History
HISTCONTROL=ignoreboth:ignoredups:erasedups
HISTSIZE=10000
HISTFILESIZE=20000
HISTTIMEFORMAT="%Y-%m-%d %T "
shopt -s histappend
shopt -s checkwinsize

# Convenience: cd by typing a directory, fix small cd typos, ** matches recursively
shopt -s autocd cdspell globstar

# Up/Down arrows search the history for what is already typed
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# Colors
if [ -x /usr/bin/dircolors ]; then
    if [ -r ~/.dircolors ]; then
        eval "$(dircolors -b ~/.dircolors)"
    else
        eval "$(dircolors -b)"
    fi
fi
