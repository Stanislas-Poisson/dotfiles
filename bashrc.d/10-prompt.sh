# Prompt: time, user@host, shortened path and cached git status.

# Shorten long paths: ~/a/b/.../x/y/z
_smart_path() {
    local path
    path=$(pwd | sed "s|${HOME}|~|")
    if [[ ${#path} -gt 80 ]]; then
        local start end
        start=$(echo "${path}" | cut -d'/' -f1-3)
        end=$(echo "${path}" | rev | cut -d'/' -f1-3 | rev)
        echo "${start}/.../${end}"
    else
        echo "${path}"
    fi
}

# Git status, cached to avoid lag on large repos
_GIT_STATUS_CACHE=""
_GIT_STATUS_PWD=""
_GIT_STATUS_TIME=0
# seconds
_GIT_CACHE_TTL=2

_git_prompt() {
    # Skip if not a git repo
    git rev-parse --git-dir &>/dev/null || return

    local now
    now=$(date +%s)

    # Invalidate cache on directory change or TTL expiry
    if [[ "${PWD}" != "${_GIT_STATUS_PWD}" ]] || \
       (( now - _GIT_STATUS_TIME >= _GIT_CACHE_TTL )); then

        local branch
        branch=$(git symbolic-ref --short HEAD 2>/dev/null \
            || git rev-parse --short HEAD 2>/dev/null)

        local git_status staged unstaged untracked stash_count
        git_status=$(git status --porcelain 2>/dev/null)
        staged=$(echo "${git_status}"    | grep -c '^[MADRC]' || true)
        unstaged=$(echo "${git_status}"  | grep -c '^.[MD]'   || true)
        untracked=$(echo "${git_status}" | grep -c '^??'       || true)
        stash_count=$(git stash list 2>/dev/null | wc -l)

        local ahead=0 behind=0 counts
        counts=$(git rev-list --count --left-right '@{upstream}...HEAD' 2>/dev/null || true)
        if [[ -n "${counts}" ]]; then
            behind=$(echo "${counts}" | cut -f1)
            ahead=$(echo "${counts}"  | cut -f2)
        fi

        local status=""
        [[ ${staged}      -gt 0 ]] && status+=" \033[1;32m+${staged}\033[0m"
        [[ ${unstaged}    -gt 0 ]] && status+=" \033[1;31m~${unstaged}\033[0m"
        [[ ${untracked}   -gt 0 ]] && status+=" \033[1;37m?${untracked}\033[0m"
        [[ ${stash_count} -gt 0 ]] && status+=" \033[1;36m📦${stash_count}\033[0m"
        [[ ${ahead}       -gt 0 ]] && status+=" \033[1;33m↑${ahead}\033[0m"
        [[ ${behind}      -gt 0 ]] && status+=" \033[1;35m↓${behind}\033[0m"

        if [[ -z "${status}" ]]; then
            _GIT_STATUS_CACHE="\n\033[1;33mgit:\033[0m \033[1;36m${branch}\033[0m \033[1;32m✓\033[0m"
        else
            _GIT_STATUS_CACHE="\n\033[1;33mgit:\033[0m \033[1;36m${branch}\033[0m${status}"
        fi

        _GIT_STATUS_PWD="${PWD}"
        _GIT_STATUS_TIME=${now}
    fi

    echo -e "${_GIT_STATUS_CACHE}"
}

# Exit code of the last command, saved first thing in PROMPT_COMMAND (before
# any other command of the prompt can overwrite $?).
_LAST_EXIT=0

# Shown after user@host, only on failure.
# \001 and \002 tell readline the escapes have no width.
_exit_status() {
    [[ ${_LAST_EXIT} -ne 0 ]] && printf ' \001\033[1;31m\002✗ %s\001\033[0m\002' "${_LAST_EXIT}"
    return 0
}

# Save the exit code, then append each command to the history file right away
# (shared between terminals). Keeps the exit code of the user command.
_prompt_history() {
    _LAST_EXIT=$?
    history -a
    return ${_LAST_EXIT}
}
# Added once only, so sourcing the file again does not stack it
[[ "${PROMPT_COMMAND:-}" == *_prompt_history* ]] \
    || PROMPT_COMMAND="_prompt_history${PROMPT_COMMAND:+;${PROMPT_COMMAND}}"

PS1="\[\033[1;34m\](\t)\[\033[0m\] \[\033[0;31m\]\u@\h\[\033[0m\]\$(_exit_status)
\[\033[1;32m\]\$(_smart_path)\[\033[0m\]\$(_git_prompt)
\[\033[0;35m\]>\[\033[0m\] "

case "${TERM}" in
    xterm*|rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]${PS1}"
        ;;
esac
