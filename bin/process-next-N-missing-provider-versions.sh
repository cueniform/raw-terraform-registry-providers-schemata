#!/usr/bin/env bash
set -euo pipefail

trap 'cleanup' EXIT

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
    _log_cmd \
        tail --lines=${num_to_process} priorities.txt

    tail --lines=${num_to_process} priorities.txt \
    | while read address version priority; do
        if ! ./bin/generate-schema-for-provider-version.sh "${address}" "${version}"; then
            record_errata "${address}" "${version}"
        fi

        _log "${log_prefix}: sleeping ${delay_sec}"
        sleep "${delay_sec}"
    done
}

function record_errata() {
    local address="${1}"
    local version="${2}"

    local log_prefix="errata: ${address}/${version}"

    local gha_url
    if [ -z "${GITHUB_ACTIONS:-}" ]; then
        gha_url="process not running inside GHA"
    else
        gha_url="$GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID"
    fi

    file_errata="errata/automata/$(echo "${address}/${version}" | tr / _).cue"

    _log "${log_prefix}: adding ${file_errata}"

    cue export \
        ./internal/templates \
        -e errata \
        -t address="${address}" \
        -t version="${version}" \
        -t error="${gha_url}" \
        --out cue \
    | sed '1i package errata' \
    | cue fmt - \
    >"${file_errata}"

    if   [ -z "${RUNNING_IN_TEST:-}" ]; then
        _log "${log_prefix}: running inside a test; not opening an Issue"
    elif [ -z "${GITHUB_ACTIONS:-}" ]; then
        _log "${log_prefix}: not running inside GHA; not opening an Issue"
    else
        _log_cmd \
            gh issue create \
            --title    "errata: ${address} ${version} failed to install" \
            --body     "File: \`${file_errata}\`\nGHA run: ${gha_url}" \
            --assignee "@jpluscplusm"
    fi

}

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
. "${SCRIPT_DIR}/lib/functions.sh"

main "$@"
