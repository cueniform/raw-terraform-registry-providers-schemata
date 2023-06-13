#!/usr/bin/env bash
set -euo pipefail

trap 'cleanup' EXIT

function cleanup() { :
    _log_cmd \
        rm -vf "tmp.sd.*"
}

function perform_service_discovery() {
    local host="$1"

    local log_prefix="${host}: service discovery"
    _log "${log_prefix}"

    local file_well_known_json="tmp.sd.well-known.${host}.json"
    local file_base_path_txt="tmp.sd.provider.base_path.${host}.txt"
    local file_base_url_txt="tmp.sd.provider.base_url.${host}.txt"

    if [ -s "${file_base_url_txt}" ]; then
        _log "${log_prefix}: already complete"
        cat "${file_base_url_txt}"
        return
    fi

    _log "${log_prefix}: starting"

    _log_cmd \
        curl --fail --location --silent \
            --header @bin/lib/http-headers.kv \
            --output "${file_well_known_json}" \
            "https://${host}/.well-known/terraform.json"

    # https://github.com/cue-lang/cue/issues/358
    _log_cmd \
        cue export \
            -l 'root:' \
            "${file_well_known_json}" \
            -e 'root["providers.v1"]' \
            --outfile "${file_base_path_txt}"

    echo -n "${host}"            >"${file_base_url_txt}"
    cat "${file_base_path_txt}" >>"${file_base_url_txt}"

    cat "${file_base_url_txt}"

    _log_cmd \
        rm -vf "${file_base_path_txt}" "${file_well_known_json}"

    _log "${log_prefix}: complete"
}

function process_provider() {
    local provider_hostname="$1"
    local provider_namespace="$2"
    local provider_type="$3"

    local log_prefix="${provider_hostname}/${provider_namespace}/${provider_type}"
    _log "${log_prefix}: processing"

    base_address="$(perform_service_discovery "${provider_hostname}")"
    file_api_response="$(mktemp --tmpdir=. --suffix=.json)"

    # https://developer.hashicorp.com/terraform/internals/provider-registry-protocol#list-available-versions
    _log_cmd \
        curl --fail --location --silent \
            --header @bin/lib/http-headers.kv \
            --output "${file_api_response}" \
            "https://${base_address}${provider_namespace}/${provider_type}/versions"

    file_provider_version_list="desiderata/${provider_hostname}_${provider_namespace}_${provider_type}.txt"
    address="${provider_hostname}/${provider_namespace}/${provider_type}"

    _log "${log_prefix}: exporting API reponse"
    cue export \
        -t address="${address}" \
        -e out.as_string \
        --out text \
        ./internal/desiderata \
        "${file_api_response}" \
    | sort -V \
    >"${file_provider_version_list}"

    _log_cmd rm -vf "${file_api_response}"
}

function main() {
    local delay_secs="${1:-0}s"
    _log "main: delay=${delay_secs}"

    _log_cmd \
        rm -vf desiderata/*.txt
    cat providata/*.txt \
    | while IFS=/ read h n t; do
        process_provider "${h}" "${n}" "${t}"
        _log "main: sleeping ${delay_secs}"
        sleep "${delay_secs}"
    done
}

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
. "${SCRIPT_DIR}/lib/functions.sh"

main "$@"
