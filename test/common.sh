#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

LOCAL_RUN="${LOCAL_RUN:-""}"

docker_exec() {
    docker exec --interactive ct "$@"
}

git_fetch() {
    echo "Add git remote k8s ${CHARTS_REPO}"
    git remote add k8s "${CHARTS_REPO}" &> /dev/null || true
    git fetch k8s master
    echo
}

get_changed_charts() {
    local changed_charts=("")
    while IFS='' read -r line; do changed_charts+=("$line"); done < <(docker run --rm -v "$(pwd):/workdir" --workdir /workdir "${IMAGE_REPOSITORY}:${IMAGE_TAG}" ct list-changed --config /workdir/test/ct.yaml --chart-dirs stable )
    echo "${changed_charts[*]}"
}

cleanup() {
    echo 'Removing ct container...'
    docker kill ct > /dev/null 2>&1

    echo 'Done!'
}

install_charts() {
    ## git_fetch
    local ct_args=""
    if [[ ${LOCAL_RUN} = "true" ]]; then
        ct_args=${CHART_TESTING_ARGS}
    fi
    mkdir -p tmp
    echo "charts install"
    # shellcheck disable=SC2086
    docker_exec ct install ${ct_args} --upgrade --config /workdir/test/ct.yaml --debug | tee tmp/install.log
    echo
}

install_helm() {
    echo 'Installing helm...'

    if [[ "${LOCAL_RUN}" = "true" ]]
    then
        echo "Local run, not downloading helm cli..."
    else
        echo "Install Helm ${HELM_VERSION} cli"
        curl -s -O https://get.helm.sh/helm-"${HELM_VERSION}"-linux-amd64.tar.gz
        tar -zxvf helm-"${HELM_VERSION}"-linux-amd64.tar.gz && mv linux-amd64/helm /usr/local/bin/helm
        echo
    fi
}

install_kubeval() {
    echo 'Installing kubeval...'

    if [[ "${LOCAL_RUN}" = "true" ]]
    then
        echo "Local run, not downloading kubeval cli..."
    else
        echo "CI run, downloading kubeval cli..."
        curl -sSLo tmp/kubeval.tar.gz "https://github.com/instrumenta/kubeval/releases/download/$KUBEVAL_VERSION/kubeval-linux-amd64.tar.gz"
        tar xf tmp/kubeval.tar.gz -C tmp && chmod +x tmp/kubeval
        sudo mv tmp/kubeval /usr/local/bin/kubeval
    fi
}
