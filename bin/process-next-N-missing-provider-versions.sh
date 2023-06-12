#!/usr/bin/env bash
set -euo pipefail

function cleanup() {
    _log_cmd \
        rm -vf priorities.txt
}

function main() {
    local num_to_process="${1:-1}"
    local delay_sec="${2:-0}s"

    local log_prefix="main"
    _log "${log_prefix}: delay=${delay_sec}"

    make priorities.txt

    tail --lines=${num_to_process} priorities.txt \
    | while read address version priority; do
        ./bin/generate-schema-for-provider-version.sh "${address}" "${version}"
        _log "${log_prefix}: sleeping ${delay_sec}"
        sleep "${delay_sec}"
    done

    cleanup
}

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
. "${SCRIPT_DIR}/lib/functions.sh"

main "$@"
