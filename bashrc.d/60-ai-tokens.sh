# AI agents and token loaders. No secret here: tokens live in ~/.config/tokens/*.env (mode 600).

# Claude Code
# Tokens of ~/.config/tokens are loaded into the claude process only, not into the shell.
# CLAUDE.md is also read automatically from workspace root.
function claude() {
    (
        set -a
        local f
        for f in "${HOME}"/.config/tokens/*.env; do
            # shellcheck source=/dev/null
            [ -f "${f}" ] && . "${f}"
        done
        set +a
        exec claude --dangerously-skip-permissions "$@"
    )
}

# GitHub: gh with the personal token or the Zairakai token, for one command only.
# Plain gh uses the personal token: there is no stored gh login.
# Usage: gh repo list | ghp repo list Stanislas-Poisson | ghz repo list Zairakai
function ghp() {
    ( . "${HOME}/.config/tokens/GITHUB_TOKEN_PERSONAL.env" && GH_TOKEN="${GITHUB_TOKEN_PERSONAL}" command gh "$@" )
}
function ghz() {
    ( . "${HOME}/.config/tokens/GITHUB_TOKEN_ZAIRAKAI.env" && GH_TOKEN="${GITHUB_TOKEN_ZAIRAKAI}" command gh "$@" )
}
function gh() {
    ghp "$@"
}
