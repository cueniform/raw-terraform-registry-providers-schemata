function _log() {
    local message="$1"

    echo "# $(date -uIs): ${message}" >&2
}

function _log_stream() {
    while read -r LINE; do
        _log "$LINE"
    done
}

function _log_cmd() {
    local command="$@"

    _log "exec: ${command}"
    ${command} 2>&1 | _log_stream
}
