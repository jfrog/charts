#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

readonly IMAGE_REPOSITORY="koalaman/shellcheck-alpine"

main() {

    docker run --rm -v "$(pwd):/workdir" --workdir /workdir "$IMAGE_REPOSITORY" shellcheck -x test/e2e-docker4mac.sh
    docker run --rm -v "$(pwd):/workdir" --workdir /workdir "$IMAGE_REPOSITORY" shellcheck -x test/e2e-github.sh
    docker run --rm -v "$(pwd):/workdir" --workdir /workdir "$IMAGE_REPOSITORY" shellcheck -x test/e2e-gke.sh
    docker run --rm -v "$(pwd):/workdir" --workdir /workdir "$IMAGE_REPOSITORY" shellcheck -x test/e2e-kind.sh
    docker run --rm -v "$(pwd):/workdir" --workdir /workdir "$IMAGE_REPOSITORY" shellcheck -x test/e2e-local-gke.sh
    docker run --rm -v "$(pwd):/workdir" --workdir /workdir "$IMAGE_REPOSITORY" shellcheck -x test/lint-charts.sh
    docker run --rm -v "$(pwd):/workdir" --workdir /workdir "$IMAGE_REPOSITORY" shellcheck -x test/lint-charts-local.sh

    echo "Done Scripts Linting!"
}

main
