#!/usr/bin/env bash

# Copyright 2018 The Helm Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

readonly IMAGE_TAG=${CHART_TESTING_TAG}
readonly IMAGE_REPOSITORY="quay.io/helmpack/chart-testing"
readonly CLUSTER_NAME=chart-testing

run_ct_container() {
    echo 'Running ct container...'
    docker container run --rm --interactive --detach --name ct \
        --volume "$(pwd):/workdir" \
        --workdir /workdir \
        "$IMAGE_REPOSITORY:$IMAGE_TAG"
    echo
}

cleanup() {
    echo 'Removing ct container...'
    docker kill ct > /dev/null 2>&1

    echo 'Done!'
}

docker_exec() {
    docker exec --interactive -e HELM_HOST=127.0.0.1:44134 -e HELM_TILLER_SILENT=true ct "$@"
}

lookup_apiserver_container_id() {
    docker container list --filter name=k8s_kube-apiserver --format '{{ .ID }}'
}

get_apiserver_arg() {
    local container_id="$1"
    local arg="$2"
    docker container inspect "$container_id" | jq -r ".[].Args[] | capture(\"$arg=(?<arg>.*)\") | .arg"
}

connect_to_cluster() {
    local apiserver_id
    apiserver_id=$(lookup_apiserver_container_id)

    if [[ -z "$apiserver_id" ]]; then
        echo "ERROR: API-Server container not found. Make sure 'Show system containers' is enabled in Docker4Mac 'Preferences'!" >&2
        exit 1
    fi

    local ip
    ip=$(get_apiserver_arg "$apiserver_id" --advertise-address)

    local port
    port=$(get_apiserver_arg "$apiserver_id" --secure-port)

    docker cp "$HOME/.kube" ct:/root/.kube
    docker_exec kubectl config set-cluster docker-desktop "--server=https://$ip:$port"
    docker_exec kubectl config set-cluster docker-desktop --insecure-skip-tls-verify=true
    docker_exec kubectl config use-context docker-desktop
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

install_charts() {
    echo "Add git remote k8s ${CHARTS_REPO}"
    git remote add k8s "${CHARTS_REPO}" &> /dev/null || true
    git fetch k8s master
    echo
    # shellcheck disable=SC2086
    docker_exec ct install ${CHART_TESTING_ARGS} --config /workdir/test/ct.yaml
    echo
}

main() {
    run_ct_container
    trap cleanup EXIT

    connect_to_cluster
    install_tiller
    install_charts
}

main
