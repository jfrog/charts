#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

readonly IMAGE_TAG=${TEST_IMAGE_TAG}
readonly IMAGE_REPOSITORY="gcr.io/kubernetes-charts-ci/test-image"
readonly REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel)}"

main() {
    git remote add k8s "${CHARTS_REPO}" &> /dev/null || true
    git fetch k8s master

    local config_container_id
    config_container_id=$(docker run -ti -d -v "/workspace/.kube:/root/.kube" -v "$REPO_ROOT:/workdir" \
        "$IMAGE_REPOSITORY:$IMAGE_TAG" cat)

    # shellcheck disable=SC2064
    trap "docker rm -f $config_container_id" EXIT

    # --- Work around for Tillerless Helm, till Helm v3 gets released --- #
    docker exec "$config_container_id" helm init --client-only
    docker exec "$config_container_id" helm plugin install https://github.com/rimusz/helm-tiller
    docker exec "$config_container_id" bash -c 'echo "Starting Tiller..."; helm tiller start-ci >/dev/null 2>&1 &'
    docker exec "$config_container_id" bash -c 'echo "Waiting Tiller to launch on 44134..."; while ! nc -z localhost 44134; do sleep 1; done; echo "Tiller launched..."'
    echo
    docker exec -e HELM_HOST=localhost:44134 "$config_container_id" chart_test.sh --config /workdir/test/.testenv
    # ------------------------------------------------------------------- #

    ##### docker exec "$config_container_id" chart_test.sh --config /workdir/test/.testenv

    echo "Done Testing!"
}

main
