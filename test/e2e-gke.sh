#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

source ${PWD}/cluster

readonly IMAGE_TAG=${TEST_IMAGE_TAG}
readonly IMAGE_REPOSITORY="gcr.io/kubernetes-charts-ci/test-image"
readonly REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel)}"

main() {
    if [[ $(git remote | grep k8s) = '' ]]; then
      git remote add k8s ${CHARTS_REPO}
    fi
    git fetch k8s master

    echo $GCLOUD_SERVICE_KEY_CHARTS_CI | base64 --decode -i > ${PWD}/gcloud-service-key.json

    local config_container_id
    config_container_id=$(docker run -ti -d -v "${PWD}/gcloud-service-key.json:/gcloud-service-key.json" -v "$REPO_ROOT:/workdir" \
        "$IMAGE_REPOSITORY:$IMAGE_TAG" cat)

    # shellcheck disable=SC2064
    trap "docker rm -f $config_container_id" EXIT

    docker exec "$config_container_id" gcloud auth activate-service-account --key-file /gcloud-service-key.json
    docker exec "$config_container_id" gcloud container clusters get-credentials $CLUSTER_NAME --project $PROJECT_NAME --zone $CLOUDSDK_COMPUTE_ZONE
    docker exec "$config_container_id" chart_test.sh --config /workdir/test/.testenv

    echo "Done Testing!"
}

main
