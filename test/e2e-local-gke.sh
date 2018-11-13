#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

readonly IMAGE_TAG=${TEST_IMAGE_TAG}
readonly IMAGE_REPOSITORY="gcr.io/kubernetes-charts-ci/test-image"
readonly REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel)}"

run_tillerless() {
     # -- Work around for Tillerless Helm, till Helm v3 gets released -- #
     docker exec "$config_container_id" apk add bash
     echo "Install Tillerless Helm plugin..."
     docker exec "$config_container_id" helm init --client-only
     docker exec "$config_container_id" helm plugin install https://github.com/rimusz/helm-tiller
     docker exec "$config_container_id" ash -c 'echo "Starting Tiller..."; helm tiller start-ci >/dev/null 2>&1 &'
     docker exec "$config_container_id" ash -c 'echo "Waiting Tiller to launch on 44134..."; while ! nc -z localhost 44134; do sleep 1; done; echo "Tiller launched..."'
     echo
}

main() {

    echo "Add git remote k8s ${CHARTS_REPO}"
    git remote add k8s "${CHARTS_REPO}" &> /dev/null || true
    git fetch k8s master
    echo

    local config_container_id
    config_container_id=$(docker run -ti -d -v "$HOME/.config/gcloud:/root/.config/gcloud" -v "$REPO_ROOT:/workdir" \
        --workdir /workdir "$IMAGE_REPOSITORY:$IMAGE_TAG" cat)

    # shellcheck disable=SC2064
    trap "docker rm -f $config_container_id > /dev/null" EXIT

    # copy and update kubeconfig file
    docker cp "$HOME/.kube"  "$config_container_id:/root/.kube"
    # shellcheck disable=SC2086
    docker exec "$config_container_id" sed -i 's|'${HOME}'||g' /root/.kube/config
    # Set to specified cluster
    if [[ -e CLUSTER ]]; then
        # shellcheck disable=SC1091
        source CLUSTER
        if [[ -n "${GKE_CLUSTER}" ]]; then
            echo
            docker exec "$config_container_id" kubectl config use-context "${GKE_CLUSTER}"
            echo
        fi
    fi

    # --- Work around for Tillerless Helm, till Helm v3 gets released --- #
    run_tillerless
    # shellcheck disable=SC2086
    docker exec -e HELM_HOST=127.0.0.1:44134 -e HELM_TILLER_SILENT=true "$config_container_id" ct install ${CHART_TESTING_ARGS} --config /workdir/test/ct.yaml 
    # ------------------------------------------------------------------- #

    ##### docker exec "$config_container_id" ct install ${CHART_TESTING_ARGS} --config /workdir/test/ct.yaml

    echo "Done Testing!"
}

main
