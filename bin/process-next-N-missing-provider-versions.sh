#!/usr/bin/env bash
set -euo pipefail

function cleanup() {
    _log_cmd \
        rm -vf schemata.txt schemata/empty.cue desiderata.txt
}

function main() {
    local num_to_process="${1:-1}"
    local delay_sec="${2:-0}s"

    local log_prefix="main"
    _log "${log_prefix}: delay=${delay_sec}"

    echo "package schemata" >schemata/empty.cue
    cue export ./schemata \
        -e 'strata.text' \
        --outfile schemata.txt \
        --force

    cat desiderata/*.txt \
    | { grep \
        --invert-match \
        --line-regexp \
        --fixed-strings \
        --file=schemata.txt \
    || true ; } \
    | sort -Vr \
    | awk '
        BEGIN{prev=""; pri=0}
        {cur=$1}
        prev==cur{pri++}
        prev!=cur{prev=cur; pri=0}
        {print $0, pri}' \
    | sort -k3 \
    >desiderata.txt

    head --lines=${num_to_process} desiderata.txt \
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
