#!/usr/bin/env bash
# Refuse to commit anything that looks like a secret.
# Usage: check-secrets.sh            check the staged files (used by the pre-commit hook)
#        check-secrets.sh --all      check every tracked file
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

if [[ "${1:-}" == "--all" ]]; then
    mapfile -t files < <(git ls-files)
else
    mapfile -t files < <(git diff --cached --name-only --diff-filter=ACM)
fi
[[ ${#files[@]} -gt 0 ]] || exit 0

# Known token formats and private key headers
patterns=(
    'ghp_[A-Za-z0-9]{20,}'
    'gho_[A-Za-z0-9]{20,}'
    'ghu_[A-Za-z0-9]{20,}'
    'ghs_[A-Za-z0-9]{20,}'
    'github_pat_[A-Za-z0-9_]{20,}'
    'glpat-[A-Za-z0-9_-]{15,}'
    'npm_[A-Za-z0-9]{30,}'
    'dckr_pat_[A-Za-z0-9_-]{15,}'
    'AKIA[0-9A-Z]{16}'
    '[MNO][A-Za-z0-9]{23}\.[A-Za-z0-9_-]{6}\.[A-Za-z0-9_-]{20,}'
    'BEGIN [A-Z ]*PRIVATE KEY'
    '(password|passwd|secret|token|api_key)[A-Za-z_]*[ ]*[=:][ ]*["'"'"'][A-Za-z0-9+/=_-]{12,}["'"'"']'
)

status=0
for file in "${files[@]}"; do
    [[ -f "${file}" ]] || continue
    # The scanner and its tests may contain the patterns themselves
    [[ "${file}" == "scripts/check-secrets.sh" ]] && continue
    for pattern in "${patterns[@]}"; do
        if grep -EIqn -- "${pattern}" "${file}"; then
            echo "secret-like content in ${file} (pattern: ${pattern})" >&2
            status=1
        fi
    done
done

# Public IPv4 addresses are not blocking, but worth a look before publishing
for file in "${files[@]}"; do
    [[ -f "${file}" ]] || continue
    [[ "${file}" == "scripts/check-secrets.sh" ]] && continue
    if grep -EIn '\b([1-9][0-9]?|1[0-9]{2}|2[0-4][0-9]|25[0-4])\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\b' "${file}" \
        | grep -vE '\b(127\.|10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[01])\.|0\.0\.0\.0)' >/dev/null; then
        echo "warning: IPv4 address in ${file}" >&2
    fi
done

if [[ ${status} -ne 0 ]]; then
    echo "Commit refused: remove the secret (secrets live in ~/.config/tokens, never in this repository)." >&2
fi
exit ${status}
