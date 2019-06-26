#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

readonly REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel)}"

# shellcheck source=test/common.sh
source "${REPO_ROOT}/test/common.sh"

get_creds() {
    # shellcheck disable=SC2086
    echo $GCLOUD_SERVICE_KEY_CHARTS_CI | base64 --decode -i > $REPO_ROOT/gcloud-service-key.json
    # shellcheck disable=SC2086
    echo $GCLOUD_GKE_CLUSTER | base64 --decode -i > $REPO_ROOT/gke_cluster
    # shellcheck disable=SC1090,SC2086
    source $REPO_ROOT/gke_cluster
}

run_ct_container() {
    echo 'Running ct container...'
    docker run --rm --interactive --detach --name ct \
        --volume "$REPO_ROOT/gcloud-service-key.json:/gcloud-service-key.json" \
        --volume "$REPO_ROOT:/workdir" \
        "$TEST_IMAGE:$TEST_IMAGE_TAG" \
        cat
    echo
}

connect_to_cluster() {
    docker_exec gcloud auth activate-service-account --key-file /gcloud-service-key.json
    docker_exec gcloud container clusters get-credentials "$CLUSTER_NAME" --project "$PROJECT_NAME" --zone "$CLOUDSDK_COMPUTE_ZONE"
}

main() {
    get_creds
    run_ct_container
    trap cleanup EXIT

    connect_to_cluster
    install_tiller
    install_charts
}

main
