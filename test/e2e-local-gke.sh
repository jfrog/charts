#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

readonly IMAGE_TAG=${TEST_IMAGE_TAG}
readonly IMAGE_REPOSITORY="gcr.io/kubernetes-charts-ci/test-image"
readonly REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel)}"

# shellcheck source=test/common.sh
source "${REPO_ROOT}/test/common.sh"

run_ct_container() {
    echo 'Running ct container...'
    docker run --rm --interactive --detach --name ct \
        --volume "$HOME/.config/gcloud:/root/.config/gcloud" \
        --volume "$REPO_ROOT:/workdir" \
        --workdir /workdir \
        "$IMAGE_REPOSITORY:$IMAGE_TAG" \
        cat
    echo
}

connect_to_cluster() {
    # copy and update kubeconfig file
    docker cp "$HOME/.kube"  ct:/root/.kube
    # shellcheck disable=SC2086
    docker_exec sed -i 's|'${HOME}'||g' /root/.kube/config
    # Set to specified cluster
    if [[ -e CLUSTER ]]; then
        # shellcheck disable=SC1091
        source CLUSTER
        if [[ -n "${GKE_CLUSTER}" ]]; then
            echo
            docker_exec kubectl config use-context "${GKE_CLUSTER}"
            echo
        fi
    fi
}

main() {
    run_ct_container
    trap cleanup EXIT

    connect_to_cluster
    install_tiller
    install_charts
}

main
