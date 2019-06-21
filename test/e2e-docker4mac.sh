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
readonly REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel)}"

# shellcheck source=test/common.sh
source "${REPO_ROOT}/test/common.sh"

connect_to_cluster() {
    docker cp "$HOME/.kube" ct:/root/.kube
    docker_exec kubectl config set-cluster docker-for-desktop-cluster "--server=https://host.docker.internal:6443" "--insecure-skip-tls-verify=true"
    docker_exec kubectl config use-context docker-for-desktop
}

main() {
    run_ct_container
    trap cleanup EXIT

    connect_to_cluster
    install_tiller
    install_charts
}

main
