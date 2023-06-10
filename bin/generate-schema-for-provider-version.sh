#!/usr/bin/env bash
set -euo pipefail

function cleanup() {
    :
}

function setup() {
    local provider_address="$1"
    local provider_version="$2"

    local log_prefix="${provider_address}/${provider_version}: setup"
    _log "${log_prefix}"

    local dir_tf="$(mktemp -d --tmpdir=.)"
    _log "${log_prefix}: using dir: ${dir_tf}"

    _log_cmd \
        cue export \
        -t address="${provider_address} \
        -t version="${provider_version} \
        -e provider_tf.out \
        -o "${dir_tf}/config.tf.json" \
        ./internal/templates

    _log "${log_prefix}: Terraform init"
    _log_cmd \
        terraform -chdir="${dir_tf}" \
            init \
            -input=false \
            -no-color

    echo "${dir_tf}"
}

function main() {
    local a="$1"
    local v="$2"

    local log_prefix="${a}/${v}: main"
    _log "${log_prefix}"

    local dir_tf="$(setup "${a}" "${v}")"
    _log "${log_prefix}: using dir ${dir_tf}"

    local dir_base="schemata"

    local file_base="$(echo "${a}_${v}" | tr "/" "_")"
    local file_schema_json="${file_base}.json"
    local file_metadata_cue="${file_base}.metadata.cue"
    local file_schema_zst="${file_schema_json}.zst"

    local path_schema_json="${dir_base}/${file_schema_json}"
    local path_metadata_cue="${dir_base}/${file_metadata_cue}"
    local path_schema_zst="${dir_base}/${file_schema_zst}"

    local path_terraform_metadata="${dir_tf}/terraform.metadata.json"

    _log "${log_prefix}: extracting schema & terraform metadata"
    terraform -chdir="${dir_tf}" \
            providers schema -json \
    >"${path_schema_json}"
    terraform -chdir="${dir_tf}" \
        version -json \
    | cue export \
        json: - \
        -l 'terraform:' \
        -o "${path_terraform_metadata}"

    _log "${log_prefix}: collecting raw metadata"
    meta_raw_size=$(stat -c %s "${path_schema_json}")
    meta_raw_hash_md5=$(cat "${path_schema_json}" | ( exec 2>/dev/null; md5 || md5sum ) | awk '{print $1}')

    _log_cmd \
        zstd \
            --ultra -22 \
            --rm --force \
            "${path_schema_json}" \
            -o "${path_schema_zst}"

    _log "${log_prefix}: collecting compressed metadata"
    meta_zst_size=$(stat -c %s "${path_schema_zst}")
    meta_zst_hash_md5=$(cat "${path_schema_zst}" | ( exec 2>/dev/null; md5 || md5sum ) | awk '{print $1}')

    _log "${log_prefix}: storing metadata"
    cue export \
        ./internal/metadata \
        -l 'input:' \
        "${path_terraform_metadata}" \
        -t raw_size="${meta_raw_size}" \
        -t raw_hash_md5="${meta_raw_hash_md5}" \
        -t raw_filename="${file_schema_json}" \
        -t zst_size="${meta_zst_size}" \
        -t zst_hash_md5="${meta_zst_hash_md5}" \
        -t zst_filename="${file_schema_zst}" \
        -t now="$(date -uIs)" \
        -t commit_id="$(git rev-parse HEAD)" \
        -e out \
        --out cue \
    | sed '1i package schemata' \
    | cue fmt - \
    >"${path_metadata_cue}"

    echo "${dir_base}/${file_base}"

    _log_cmd \
        rm -rf "${dir_tf}"
    cleanup
}

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
. "${SCRIPT_DIR}/lib/functions.sh"

main "$@"
