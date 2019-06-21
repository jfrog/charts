#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

readonly IMAGE_REPOSITORY="koalaman/shellcheck-alpine"
readonly SHELLCHECK_CMD="docker run --rm -v "$(pwd):/workdir" --workdir /workdir ${IMAGE_REPOSITORY} shellcheck -x"

main() {

    ${SHELLCHECK_CMD} test/e2e-docker4mac.sh
    ${SHELLCHECK_CMD} test/e2e-github.sh
    ${SHELLCHECK_CMD} test/e2e-gke.sh
    ${SHELLCHECK_CMD} test/e2e-kind.sh
    ${SHELLCHECK_CMD} test/e2e-local-gke.sh
    ${SHELLCHECK_CMD} test/lint-charts.sh

    echo "Done Scripts Linting!"
}

main
