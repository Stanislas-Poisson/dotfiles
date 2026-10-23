#!/usr/bin/env bash
# Link the dotfiles of this repository into $HOME.
# Existing files are moved aside (suffix .bak-<date>), never deleted. Safe to run again.
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
stamp="$(date +%Y%m%d-%H%M%S)"

# link <source> <target>
link() {
    local src="$1" dst="$2"
    if [[ -L "${dst}" && "$(readlink -f "${dst}")" == "$(readlink -f "${src}")" ]]; then
        echo "ok      ${dst}"
        return
    fi
    if [[ -e "${dst}" || -L "${dst}" ]]; then
        mv "${dst}" "${dst}.bak-${stamp}"
        echo "moved   ${dst} -> ${dst}.bak-${stamp}"
    fi
    mkdir -p "$(dirname "${dst}")"
    ln -s "${src}" "${dst}"
    echo "linked  ${dst} -> ${src}"
}

link "${repo}/bashrc" "${HOME}/.bashrc"
link "${repo}/bashrc.d" "${HOME}/.bashrc.d"
link "${repo}/bin/store-token" "${HOME}/.local/bin/store-token"

# Secrets directory: owner only
mkdir -p "${HOME}/.config/tokens"
chmod 700 "${HOME}/.config/tokens"

# Expiry list: created from the example only when missing
if [[ ! -f "${HOME}/.config/tokens/expiry.list" ]]; then
    cp "${repo}/tokens/expiry.list.example" "${HOME}/.config/tokens/expiry.list"
    chmod 600 "${HOME}/.config/tokens/expiry.list"
    echo "created ${HOME}/.config/tokens/expiry.list (edit it with your own tokens)"
fi

# Block secrets before every commit of this repository
git -C "${repo}" config core.hooksPath scripts/hooks
echo "hooks   core.hooksPath = scripts/hooks"

echo "Done. Open a new terminal or run: exec bash"
