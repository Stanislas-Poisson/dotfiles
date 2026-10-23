# Expiry follow-up of secrets. The list holds names and dates only, never a value.
# Format of the list, one per line: NAME YYYY-MM-DD description
_TOKEN_EXPIRY_FILE="${HOME}/.config/tokens/expiry.list"
# Warn at shell start when something expires within this many days
_TOKEN_WARN_DAYS=14

# Print "days name date description" lines sorted by date (negative days = expired)
_token_scan() {
    [[ -r "${_TOKEN_EXPIRY_FILE}" ]] || return 1
    local -a names=() dates=() descs=() epochs=()
    local name date desc
    while read -r name date desc; do
        [[ -z "${name}" || "${name}" == \#* ]] && continue
        names+=("${name}")
        dates+=("${date}")
        descs+=("${desc}")
    done < "${_TOKEN_EXPIRY_FILE}"
    [[ ${#names[@]} -gt 0 ]] || return 0

    # One call to date for the whole list
    mapfile -t epochs < <(printf '%s\n' "${dates[@]}" | date -f - +%s 2>/dev/null)
    local now i
    now=$(date +%s)
    for i in "${!names[@]}"; do
        [[ -n "${epochs[i]:-}" ]] || continue
        printf '%s %s %s %s\n' "$(( (epochs[i] - now) / 86400 ))" "${names[i]}" "${dates[i]}" "${descs[i]}"
    done | sort -n
}

# List the secrets and the days left before each expiry
tokens() {
    local out days name date desc color
    out=$(_token_scan) || { echo "No expiry list: ${_TOKEN_EXPIRY_FILE}"; return 1; }
    while read -r days name date desc; do
        if   [[ ${days} -le 0 ]];                 then color='1;31'
        elif [[ ${days} -le ${_TOKEN_WARN_DAYS} ]]; then color='1;31'
        elif [[ ${days} -le 30 ]];                then color='1;33'
        else color='0;32'
        fi
        printf '\033[%sm%5s d\033[0m  %-26s %s  %s\n' "${color}" "${days}" "${name}" "${date}" "${desc}"
    done <<< "${out}"
}

# Silent unless something expires soon
_token_warn() {
    local out count
    out=$(_token_scan) || return 0
    count=$(awk -v max="${_TOKEN_WARN_DAYS}" '$1 <= max {n++} END {print n+0}' <<< "${out}")
    [[ ${count} -gt 0 ]] && printf '\033[1;33mtokens:\033[0m %s expire within %s days (or already expired), run: tokens\n' "${count}" "${_TOKEN_WARN_DAYS}"
    return 0
}
_token_warn
