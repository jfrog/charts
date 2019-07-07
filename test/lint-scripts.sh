#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

readonly FILES_TO_LINT=$(ls test/*.sh)
readonly IMAGE_REPOSITORY="koalaman/shellcheck-alpine"
readonly SHELLCHECK_CMD="docker run --rm -v "$(pwd):/workdir" --workdir /workdir ${IMAGE_REPOSITORY} shellcheck -x"

main() {

    for f in ${FILES_TO_LINT} ; do
        ${SHELLCHECK_CMD} "${f}"
    done

    echo "Done Scripts Linting!"
}

main
