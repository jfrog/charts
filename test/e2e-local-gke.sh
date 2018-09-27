#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

readonly IMAGE_TAG=${CHART_TESTING_TAG}
readonly IMAGE_REPOSITORY="gcr.io/kubernetes-charts-ci/chart-testing"
readonly REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel)}"

copy_files() {
    # ------- Some work around ------- #
    docker cp test/chart_test.sh "$config_container_id:/testing/chart_test.sh"
    docker cp test/chartlib.sh "$config_container_id:/testing/lib/chartlib.sh"
}

run_tillerless() {
     # -- Work around for Tillerless Helm, till Helm v3 gets released -- #
     echo "Install Tillerless Helm plugin..."
     # shellcheck disable=SC2154
     docker exec "$config_container_id" helm init --client-only
     # shellcheck disable=SC2154
     docker exec "$config_container_id" helm plugin install https://github.com/rimusz/helm-tiller
     # shellcheck disable=SC2154
     docker exec "$config_container_id" bash -c 'echo "Starting Tiller..."; helm tiller start-ci >/dev/null 2>&1 &'
     # shellcheck disable=SC2154
     docker exec "$config_container_id" bash -c 'echo "Waiting Tiller to launch on 44134..."; while ! nc -z localhost 44134; do sleep 1; done; echo "Tiller launched..."'
     echo
}

main() {

    echo "Refresh GKE user token..."
    kubectl get nodes > /dev/null
    echo

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

    # Workarounds #
    ###copy_files
    # ---------- #

    # --- Work around for Tillerless Helm, till Helm v3 gets released --- #
    if [[ "${CHART_TESTING_ARGS}" != *"--no-install"* ]]; then
      run_tillerless
    fi
    # shellcheck disable=SC2086
    docker exec -e HELM_HOST=localhost:44134 "$config_container_id" chart_test.sh --config /workdir/test/.testenv ${CHART_TESTING_ARGS}
    # ------------------------------------------------------------------- #

    ##### docker exec "$config_container_id" chart_test.sh --config /workdir/test/.testenv ${CHART_TESTING_ARGS}

    echo "Done Testing!"
}

main
