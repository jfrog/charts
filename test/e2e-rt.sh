#!/usr/bin/env bash

set -o errexit
set -o pipefail

readonly REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel)}"
readonly namespace=rt
readonly HELM="helm tiller run -- helm"

# shellcheck source=test/common.sh
source "${REPO_ROOT}/test/common.sh"

deploy() {

    ${HELM} upgrade --install artifactory --namespace ${namespace} "${REPO_ROOT}"/stable/artifactory/ --set nginx.enabled=false,postgresql.postgresqlPassword=password
    echo
    echo "Waiting for Artifactory to be ready!"
    kubectl rollout status statefulset/artifactory-postgresql -w -n ${namespace} --request-timeout="10m"
    kubectl rollout status statefulset/artifactory-artifactory -w -n ${namespace} --request-timeout="10m"
    echo
}

clean() {

    ${HELM} delete --purge artifactory
    sleep 20
    kubectl delete ns ${namespace} --force --grace-period=0
}

main() {

    if [[ "${RUN_CLEAN}" == "true" ]]; then
        echo
        echo "Remove Artifactory..."
        echo
        clean
    else
        installHelmLocal
        echo
        echo "Deploy Artifactory..."
        echo
        deploy
    fi
}

main
