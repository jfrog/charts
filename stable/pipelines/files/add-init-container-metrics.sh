#!/bin/bash

find_diff(){
    local date_end=${1};
    local date_begin=${2};
    if [[ -z "${date_begin}" || -z "${date_end}" ]]; then
        return 1;
    fi
    local diff_in_milli_sec=0;
    diff_in_milli_sec=$(( ($(date --date="$date_end" +%s) - $(date --date="$date_begin" +%s) )*(1000) ));
    echo "$diff_in_milli_sec"
}

append_metrics_json(){
    local start_time="${1}"
    local log_file="${2}"
    local domain="${3}"
    if [[ -z "${start_time}" || -z "${log_file}" || -z "${domain}" ]]; then
        return 1;
    fi
    local end_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ");
    local current_time="${end_time}";
    local duration_in_milli_sec="$(find_diff "${end_time}" "${start_time}")";

    if [[ -z "${duration_in_milli_sec}" ]]; then
        return 1;
    fi

    local paretDir=$(dirname "${log_file}");
    [ -d "${paretDir}" ] || mkdir -p "${paretDir}"

    echo "Adding metric with duration ${duration_in_milli_sec} to ${log_file}"
    echo "{\"timestamp\":\"${current_time}\",\"domain\":\"${domain}\",\"durationMillis\":${duration_in_milli_sec}}" >> "${log_file}"
}

start_time="${1}";
log_file="${2}";
domain="${3}";

append_metrics_json "${start_time}" "${log_file}" "${domain}"
