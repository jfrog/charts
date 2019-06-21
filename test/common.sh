#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

LOCAL_RUN="${LOCAL_RUN:-""}"

docker_exec() {
    docker exec --interactive -e HELM_HOST=127.0.0.1:44134 -e HELM_TILLER_SILENT=true ct "$@"
}

install_tiller() {
     docker_exec apk add bash
     echo "Install Tillerless Helm plugin..."
     docker_exec helm init --client-only
     docker_exec helm plugin install https://github.com/rimusz/helm-tiller
     docker_exec bash -c 'echo "Starting Tiller..."; helm tiller start-ci >/dev/null 2>&1 &'
     docker_exec bash -c 'echo "Waiting Tiller to launch on 44134..."; while ! nc -z localhost 44134; do sleep 1; done; echo "Tiller launched..."'
     echo
}

git_fetch() {
    echo "Add git remote k8s ${CHARTS_REPO}"
    git remote add k8s "${CHARTS_REPO}" &> /dev/null || true
    git fetch k8s master
    echo
}

get_changed_charts() {
    local changed_charts=("")
    while IFS='' read -r line; do changed_charts+=("$line"); done < <(docker run --rm -v "$(pwd):/workdir" --workdir /workdir "${IMAGE_REPOSITORY}:${IMAGE_TAG}" ct list-changed --chart-dirs stable )
    echo "${changed_charts[*]}"
}

cleanup() {
    echo 'Removing ct container...'
    docker kill ct > /dev/null 2>&1

    echo 'Done!'
}

install_charts() {
    git_fetch

    local ct_command="docker_exec ct install --config /workdir/test/ct.yaml"
    local ct_args

    [[ "${LOCAL_RUN}" = "true" ]] && ct_args=${CHART_TESTING_ARGS}

    ${ct_command} "${ct_args}"
    echo
}

run_ct_container() {
    echo 'Running ct container...'
    docker run --rm --interactive --detach --name ct \
        --volume "$HOME/.config/gcloud:/root/.config/gcloud" \
        --volume "$REPO_ROOT:/workdir" \
        --workdir /workdir \
        "$IMAGE_REPOSITORY:$IMAGE_TAG" \
        cat
    echo
}
