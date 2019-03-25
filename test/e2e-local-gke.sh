#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

readonly IMAGE_TAG=${TEST_IMAGE_TAG}
readonly IMAGE_REPOSITORY="gcr.io/kubernetes-charts-ci/test-image"
readonly REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel)}"

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

cleanup() {
    echo 'Removing ct container...'
    docker kill ct > /dev/null 2>&1

    echo 'Done!'
}

docker_exec() {
    docker exec --interactive -e HELM_HOST=127.0.0.1:44134 -e HELM_TILLER_SILENT=true ct "$@"
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

install_tiller() {
     docker_exec apk add bash
     echo "Install Tillerless Helm plugin..."
     docker_exec helm init --client-only
     docker_exec helm plugin install https://github.com/rimusz/helm-tiller
     docker_exec bash -c 'echo "Starting Tiller..."; helm tiller start-ci >/dev/null 2>&1 &'
     docker_exec bash -c 'echo "Waiting Tiller to launch on 44134..."; while ! nc -z localhost 44134; do sleep 1; done; echo "Tiller launched..."'
     echo
}

install_charts() {
    echo "Add git remote k8s ${CHARTS_REPO}"
    git remote add k8s "${CHARTS_REPO}" &> /dev/null || true
    git fetch k8s master
    echo
    # shellcheck disable=SC2086
    docker_exec ct install ${CHART_TESTING_ARGS} --config /workdir/test/ct.yaml
    echo
}

main() {
    run_ct_container
    trap cleanup EXIT

    connect_to_cluster
    install_tiller
    install_charts
}

main
