#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

readonly IMAGE_TAG=${CHART_TESTING_TAG}
readonly IMAGE_REPOSITORY="gcr.io/kubernetes-charts-ci/chart-testing"
readonly REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel)}"

main() {
    if [[ $(git remote | grep k8s) = '' ]]; then
      git remote add k8s ${CHARTS_REPO}
    fi
    git fetch k8s master

    mkdir -p tmp
    docker run --rm -v "$(pwd):/workdir" --workdir /workdir "$IMAGE_REPOSITORY:$IMAGE_TAG" chart_test.sh --no-install --config /workdir/test/.testenv | tee tmp/lint.log

    echo "Done Linting!"
}

main
