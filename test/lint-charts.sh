#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

readonly IMAGE_TAG=${CHART_TESTING_TAG}
readonly IMAGE_REPOSITORY="quay.io/helmpack/chart-testing"
readonly REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel)}"
# shellcheck disable=SC2034  # This variable is used by the script get_helm.sh
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
    cd tmp
    for chart_name in ${changed_charts[*]} ; do
        echo "Validating chart ${chart_name}"
        rm -rf stable
        mkdir stable
        helm template "${REPO_ROOT}/${chart_name}" --output-dir stable > /dev/null 2>&1
        echo "------------------------------------------------------------------------------------------------------------------------"
        echo "==> Processing with default values..."
        echo "------------------------------------------------------------------------------------------------------------------------"
        TEMPLATE_FILES="${chart_name}/templates"
        # shellcheck disable=SC2086
        kubeval -d ${TEMPLATE_FILES}
        if [ -d "${REPO_ROOT}/${chart_name}/ci" ]
        then
            FILES="${REPO_ROOT}/${chart_name}/ci/*"
            for file in $FILES
            do
                echo "------------------------------------------------------------------------------------------------------------------------"
                echo "==> Processing with $file..."
                echo "------------------------------------------------------------------------------------------------------------------------"
                rm -rf stable
                mkdir stable
                helm template "${REPO_ROOT}/${chart_name}" -f "$file" --output-dir stable > /dev/null 2>&1
                TEMPLATE_FILES="${chart_name}/templates/*" 
                # shellcheck disable=SC2086
                kubeval ${TEMPLATE_FILES}
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
    # shellcheck disable=SC2086
    docker run --rm -v "$(pwd):/workdir" --workdir /workdir "$IMAGE_REPOSITORY:$IMAGE_TAG" ct lint ${CHART_TESTING_ARGS} --config /workdir/test/ct.yaml | tee tmp/lint.log
    echo "Done Charts Linting!"
    echo
    if [[ -z "${CHART_TESTING_ARGS}" ]]
    then
        # Check for changelog version
        check_changelog_version
        # Validate Kubernetes manifests
        validate_manifests
    fi
}

main
