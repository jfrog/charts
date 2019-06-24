#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

readonly REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel)}"
readonly CLUSTER_NAME=chart-testing

# shellcheck source=test/common.sh
source "${REPO_ROOT}/test/common.sh"

run_ct_container() {
    echo 'Running ct container...'
    docker run --rm --interactive --detach --network host --name ct \
        --volume "$REPO_ROOT:/workdir" \
        --workdir /workdir \
        "$CHART_TESTING_IMAGE:$CHART_TESTING_TAG" \
        cat
    echo
}

cleanup_kind() {
    cleanup
    echo 'Removing kind container...'
    kind delete cluster --name "${CLUSTER_NAME}" > /dev/null 2>&1
    echo 'Done!'
}

create_kind_cluster() {
    echo 'Installing kind...'

    if [[ "${LOCAL_RUN}" = "true" ]] 
    then
        echo "Local run, not downloading kind cli..."
    else
        echo "CI run, downloading kind cli..."
        curl -sSLo kind "https://github.com/kubernetes-sigs/kind/releases/download/$KIND_VERSION/kind-linux-amd64"
        chmod +x kind
        sudo mv kind /usr/local/bin/kind
    fi

    kind create cluster --name "$CLUSTER_NAME" --image "kindest/node:$K8S_VERSION"

    docker_exec mkdir -p /root/.kube

    echo 'Copying kubeconfig to container...'
    local kubeconfig
    kubeconfig="$(kind get kubeconfig-path --name "$CLUSTER_NAME")"
    docker cp "$kubeconfig" ct:/root/.kube/config

    docker_exec kubectl cluster-info
    echo

    echo -n 'Waiting for cluster to be ready...'
    until ! grep --quiet 'NotReady' <(docker_exec kubectl get nodes --no-headers); do
        printf '.'
        sleep 1
    done

    echo '✔︎'
    echo

    docker_exec kubectl get nodes
    echo

    echo 'Cluster ready!'
    echo
}

install_local-path-provisioner() {
    # kind doesn't support Dynamic PVC provisioning yet, this is one ways to get it working
    # https://github.com/rancher/local-path-provisioner

    # Remove default storage class. It will be recreated by local-path-provisioner
    docker_exec kubectl delete storageclass standard

    echo 'Installing local-path-provisioner...'
    docker_exec kubectl apply -f test/local-path-provisioner.yaml
    echo
}

main() {
    run_ct_container
    trap cleanup_kind EXIT

    create_kind_cluster
    install_local-path-provisioner
    install_tiller
    install_charts
}

main
