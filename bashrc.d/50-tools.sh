# Completions and tool loaders.

# Bash completion
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        # shellcheck source=/usr/share/bash-completion/bash_completion
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        # shellcheck source=/etc/bash_completion
        . /etc/bash_completion
    fi
fi

# Node is the system package (NodeSource, current LTS), updated by `maj`.
# Global npm tools install in ~/.local (npm prefix), no version manager.
