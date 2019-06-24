#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

readonly IMAGE_TAG=${CHART_TESTING_TAG}
readonly IMAGE_REPOSITORY="quay.io/helmpack/chart-testing"
readonly REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel)}"
readonly DESIRED_VERSION=${HELM_VERSION}

# shellcheck source=test/common.sh
source "${REPO_ROOT}/test/common.sh"

check_changelog_version() {
    local changed_charts=("")
    while IFS='' read -r line; do changed_charts+=("$line"); done < <(get_changed_charts)
    echo "------------------------------------------------------------------------------------------------------------------------"
    echo " Checking CHANGELOG!"
    echo " Charts to be processed: ${changed_charts[*]}"
    echo "------------------------------------------------------------------------------------------------------------------------"
    for chart_name in ${changed_charts[*]} ; do
        echo "==> Checking CHANGELOG for chart ${chart_name}"
        echo "------------------------------------------------------------------------------------------------------------------------"
        local chart_version
        chart_version=$(grep "version:" "${REPO_ROOT}/${chart_name}/Chart.yaml" | cut -d" " -f 2)
        ## Check that the version has an entry in the changelog
        if ! grep -q "\[${chart_version}\]" "${REPO_ROOT}/${chart_name}/CHANGELOG.md"; then
            echo "No CHANGELOG entry for chart ${chart_name} version ${chart_version}"
            exit 1
        else
            echo "Found CHANGELOG entry for chart ${chart_name} version ${chart_version}"
        fi
    done
    echo "------------------------------------------------------------------------------------------------------------------------"
    echo "Done CHANGELOG Check!"
    echo "------------------------------------------------------------------------------------------------------------------------"
    echo
}

validate_manifests() {
    local changed_charts=("")
    while IFS='' read -r line; do changed_charts+=("$line"); done < <(get_changed_charts)
    echo "------------------------------------------------------------------------------------------------------------------------"
    echo " Validating Manifests!"
    echo " Charts to be processed: ${changed_charts[*]}"
    echo "------------------------------------------------------------------------------------------------------------------------"
    for chart_name in ${changed_charts[*]} ; do
        echo "Validating chart ${chart_name}"
        rm -rf "tmp/${chart_name}/"
        mkdir -p tmp/stable
        cp -r "${chart_name}" tmp/stable/
        rm -rf tmp/"${chart_name}"/charts/
        rm -rf tmp/"${chart_name}"/requirements.*
        echo "------------------------------------------------------------------------------------------------------------------------"
        echo "==> Processing with tmp/${chart_name}/values.yaml"
        echo "------------------------------------------------------------------------------------------------------------------------"
        helm template tmp/"${chart_name}" | kubeval
        if [ -d "tmp/${chart_name}/ci" ]
        then
            FILES="tmp/${chart_name}/ci/*"
            for file in $FILES
            do
                echo "------------------------------------------------------------------------------------------------------------------------"
                echo "==> Processing with $file "
                echo "------------------------------------------------------------------------------------------------------------------------"
                helm template tmp/"${chart_name}" -f "$file" | kubeval
            done
        fi 
    done
    echo "------------------------------------------------------------------------------------------------------------------------"
    echo "Done Manifests validating!"
    echo
}

main() {
    mkdir -p tmp
    install_kubeval
    install_helm
    git_fetch
    # Lint helm charts
    docker run --rm -v "$(pwd):/workdir" --workdir /workdir "$IMAGE_REPOSITORY:$IMAGE_TAG" ct lint --config /workdir/test/ct.yaml | tee tmp/lint.log
    echo "Done Charts Linting!"
    echo
    # Check for changelog version
    check_changelog_version
    # Validate Kubernetes manifests
    validate_manifests
}

main
