# General purpose functions.

# System update
maj() {
    echo "Mise à jour du système Debian"
    echo "━━━━━━━━━━━━━━━━"
    # -qq hides the "Hit:" lines, -q keeps what gets upgraded
    sudo apt-get update -qq
    sudo apt-get upgrade -y -q
    sudo apt-get autoremove -y -qq
    sudo apt-get autoclean -y -qq
    echo "Outils npm globaux (~/.local)"
    npm update -g --no-fund --no-audit --loglevel=error
    echo "Mise à jour terminée"
    echo "━━━━━━━━━━━━━━━━"
}

# mkdir + cd in one step
mkcd() {
    [[ -z "$1" ]] && echo "Usage: mkcd <dir>" && return 1
    mkdir -p "$1" && cd "$1" || return 1
}

# Extract any archive
extract() {
    if [[ -z "$1" ]]; then
        echo "Usage: extract <file>"
        return 1
    fi
    if [[ ! -f "$1" ]]; then
        echo "Error: '$1' is not a file"
        return 1
    fi
    case "$1" in
        *.tar.bz2)  tar xjf "$1"     ;;
        *.tar.gz)   tar xzf "$1"     ;;
        *.tar.xz)   tar xJf "$1"     ;;
        *.tar.zst)  tar --zstd -xf "$1" ;;
        *.tar)      tar xf "$1"      ;;
        *.bz2)      bunzip2 "$1"     ;;
        *.gz)       gunzip "$1"      ;;
        *.zip)      unzip "$1"       ;;
        *.7z)       7z x "$1"        ;;
        *.rar)      unrar x "$1"     ;;
        *.xz)       unxz "$1"        ;;
        *.zst)      zstd -d "$1"     ;;
        *)          echo "Unknown format: '$1'" && return 1 ;;
    esac
}

# Find process by name
psg() {
    [[ -z "$1" ]] && echo "Usage: psg <process>" && return 1
    pgrep -ail "$1"
}

# Quick HTTP server in current directory
serve() {
    local port="${1:-8000}"
    echo "Serving on http://localhost:${port}"
    python3 -m http.server "${port}"
}

# Forget the known_hosts entry of the VPS (address read from ~/.ssh/config)
vps-clear() {
    local host
    host=$(ssh -G vps | awk '/^hostname /{print $2}')
    [[ -z "${host}" ]] && echo "Host 'vps' not found in ~/.ssh/config" && return 1
    ssh-keygen -f "${HOME}/.ssh/known_hosts" -R "${host}"
}

# Show public IP
myip() {
    curl -s https://ifconfig.me && echo
}
