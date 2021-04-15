#!/usr/bin/env bash

update_commit_status_custom() {
    ### Usage: update_commit_status_custom RESOURCE [--status STATUS --message \"MESSAGE\" --context CONTEXT --url URL]
    ### update_commit_status_custom charts_repo_fork_pr --context "${step_name}" --message "Scripts linting successful." --url "https://jfrog.com/...."
    
    if [[ $# -le 0 ]]; then
      echo "Usage: update_commit_status_custom RESOURCE [--status STATUS --message \"MESSAGE\" --context CONTEXT --url URL]" >&2
      exit 99
    fi
    # parse and validate the resource details
    local resourceName="$1"
    shift
    local resource_id=$(find_resource_variable "$resourceName" resourceId)
    if [ -z "$resource_id" ]; then
      echo "Error: resource not found for $resourceName" >&2
      exit 99
    fi
    local integrationAlias=$(find_resource_variable "$resourceName" integrationAlias)
    local integration_name=$(eval echo "$"res_"$resourceName"_"$integrationAlias"_name)
    if [ -z "$integration_name" ]; then
      echo "Error: integration data not found for $resourceName" >&2
      exit 99
    fi
    local i_mastername=$(eval echo "$"res_"$resourceName"_"$integrationAlias"_masterName)
    # declare options and defaults, and parse arguments
    export opt_status=""
    export opt_message=""
    export opt_context=""
    export opt_url="$step_url"
    if [ -z "$opt_context" ]; then
      opt_context="${pipeline_name}_${step_name}"
    fi
    while [ $# -gt 0 ]; do
      case $1 in
        --status)
          opt_status="$2"
          shift
          shift
          ;;
        --message)
          opt_message="$2"
          shift
          shift
          ;;
        --context)
          opt_context="$2"
          shift
          shift
          ;;
        --url)
          opt_url="$2"
          shift
          shift
          ;;
        *)
          echo "Warning: Unrecognized flag \"$1\""
          shift
          ;;
      esac
    done
    if [ -z "$opt_status" ]; then
      case "$current_script_section" in
        onStart | onExecute )
          opt_status="processing"
          ;;
        onSuccess )
          opt_status="success"
          ;;
        onFailure )
          opt_status="failure"
          ;;
        onComplete )
          if [ "$is_success" == "true" ]; then
            opt_status="success"
          else
            opt_status="failure"
          fi
          ;;
        *)
          echo "Error: unable to determine status in section $current_script_section" >&2
          exit 99
          ;;
      esac
    fi
    if [ "$opt_status" != "processing" ] && [ "$opt_status" != "success" ] && [ "$opt_status" != "failure" ] ; then
      echo "Error: --status may only be processing, success, or failure" >&2
      exit 99
    fi
    if [ -z "$opt_message" ]; then
      opt_message="Step $opt_status in pipeline $pipeline_name"
    fi
    local payload=""
    local endpoint=""
    local headers=""
    local commit=$(find_resource_variable "$resourceName" commitSha)
    local full_name=$(find_resource_variable "$resourceName" gitRepoFullName)
    local integration_url=$(eval echo "$"res_"$resourceName"_"$integrationAlias"_url)
    local token=$(eval echo "$"res_"$resourceName"_"$integrationAlias"_token)
    local state=""
    if [ "$opt_status" == "processing" ] ; then
      state="pending"
    elif [ "$opt_status" == "success" ] ; then
      state="success"
    elif [ "$opt_status" == "failure" ] ; then
      state="failure"
    fi
    payload="{\"target_url\": \"\${opt_url}\",\"description\": \"\${opt_message}\", \"context\": \"\${opt_context}\", \"state\": \"$state\"}"
    endpoint="$integration_url/repos/$full_name/statuses/$commit"
    headers="-H Authorization:'token $token' -H Accept:'application/vnd.GithubProvider.v3'"
    local payload_file=/tmp/payload.json
    echo $payload > $payload_file
    replace_envs $payload_file
    local isValid=$(jq type $payload_file || true)
    if [ -z "$isValid" ]; then
      echo "Error: payload is not valid JSON" >&2
      exit 99
    fi
    echo "sending update"
    _post_curl "$payload_file" "$headers" "$endpoint"
}