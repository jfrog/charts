#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

readonly IMAGE_TAG=${CHART_TESTING_TAG}
readonly IMAGE_REPOSITORY="quay.io/helmpack/chart-testing"
readonly REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel)}"

main() {
    echo "Add git remote k8s ${CHARTS_REPO}"
    git remote add k8s "${CHARTS_REPO}" &> /dev/null || true
    git fetch k8s master
    echo
    
    mkdir -p tmp
    docker run --rm -v "$(pwd):/workdir" --workdir /workdir "$IMAGE_REPOSITORY:$IMAGE_TAG" ct lint --config /workdir/test/ct.yaml | tee tmp/lint.log

    echo "Done Charts Linting!"
}

main
