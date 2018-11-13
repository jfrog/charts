#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

readonly REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel)}"

main() {

    # shellcheck disable=SC2086
    echo $GCLOUD_SERVICE_KEY_CHARTS_CI | base64 --decode -i > $REPO_ROOT/gcloud-service-key.json
    # shellcheck disable=SC2086
    echo $GCLOUD_GKE_CLUSTER | base64 --decode -i > $REPO_ROOT/gke_cluster
    # shellcheck disable=SC1090,SC2086
    source $REPO_ROOT/gke_cluster

    git remote add k8s "${CHARTS_REPO}" &> /dev/null || true
    git fetch k8s master

    local config_container_id
    config_container_id=$(docker run -ti -d -v "$REPO_ROOT/gcloud-service-key.json:/gcloud-service-key.json" -v "$REPO_ROOT:/workdir" \
        "$TEST_IMAGE:$TEST_IMAGE_TAG" cat)

    # shellcheck disable=SC2064
    trap "docker rm -f $config_container_id" EXIT

    docker exec "$config_container_id" gcloud auth activate-service-account --key-file /gcloud-service-key.json
    docker exec "$config_container_id" gcloud container clusters get-credentials "$CLUSTER_NAME" --project "$PROJECT_NAME" --zone "$CLOUDSDK_COMPUTE_ZONE"

    # --- Work around for Tillerless Helm, till Helm v3 gets released --- #
    docker exec "$config_container_id" apk add bash
    docker exec "$config_container_id" helm init --client-only
    docker exec "$config_container_id" helm plugin install https://github.com/rimusz/helm-tiller
    docker exec "$config_container_id" bash -c 'echo "Starting Tiller..."; helm tiller start-ci >/dev/null 2>&1 &'
    docker exec "$config_container_id" bash -c 'echo "Waiting Tiller to launch on 44134..."; while ! nc -z localhost 44134; do sleep 1; done; echo "Tiller launched..."'
    echo
    docker exec -e HELM_HOST=127.0.0.1:44134 -e HELM_TILLER_SILENT=true "$config_container_id" ct install --config /workdir/test/ct.yaml
    # ------------------------------------------------------------------- #

    ##### docker exec "$config_container_id" ct install --config /workdir/test/ct.yaml

    echo "Done Testing!"
}

main
