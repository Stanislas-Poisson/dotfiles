# ~/.bashrc - Zairakai
# Loads ~/.bashrc.d/*.sh in order. Keep secrets out of those files (tokens live in ~/.config/tokens).

# Skip if not interactive
case $- in
    *i*) ;;
      *) return;;
esac

for f in "${HOME}"/.bashrc.d/*.sh; do
    # shellcheck source=/dev/null
    [ -r "${f}" ] && . "${f}"
done
unset f

# Local aliases override (not versioned)
if [ -f ~/.bash_aliases ]; then
    # shellcheck source=/dev/null
    . ~/.bash_aliases
fi
