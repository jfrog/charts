#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

readonly REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel)}"

run_kind() {

    echo "Get kind binary..."
    # curl -Lo kind https://storage.googleapis.com/jfrog-helm-ci-artifacts/kind && chmod +x kind && sudo mv kind /usr/local/bin/
    curl -sSLo kind https://github.com/kubernetes-sigs/kind/releases/download/"$KIND_VERSION"/kind-linux-amd64 && chmod +x kind && sudo mv kind /usr/local/bin/

    echo "Download kubectl..."
    curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/"${K8S_VERSION}"/bin/linux/amd64/kubectl && chmod +x kubectl && sudo mv kubectl /usr/local/bin/
    echo

    echo "Create Kubernetes cluster with kind..."
    kind create cluster --image=kindest/node:"$K8S_VERSION"

    echo "Export kubeconfig..."
    # shellcheck disable=SC2155
    export KUBECONFIG="$(kind get kubeconfig-path)"
    echo

    echo "Ensure the apiserver is responding..."
    kubectl cluster-info
    echo

    echo "Wait for Kubernetes to be up and ready..."
    JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}'; until kubectl get nodes -o jsonpath="$JSONPATH" 2>&1 | grep -q "Ready=True"; do sleep 1; done
    echo '✔︎'
    echo
}

run_tillerless() {
     # -- Work around for Tillerless Helm, till Helm v3 gets released -- #
     docker exec "$config_container_id" apk add bash
     echo "Install Tillerless Helm plugin..."
     docker exec "$config_container_id" helm init --client-only
     docker exec "$config_container_id" helm plugin install https://github.com/rimusz/helm-tiller
     docker exec "$config_container_id" bash -c 'echo "Starting Tiller..."; helm tiller start-ci >/dev/null 2>&1 &'
     docker exec "$config_container_id" bash -c 'echo "Waiting Tiller to launch on 44134..."; while ! nc -z localhost 44134; do sleep 1; done; echo "Tiller launched..."'
     echo
}

install_hostpath-provisioner() {
     # kind doesn't support Dynamic PVC provisioning yet, this one of the ways to get it working
     # https://github.com/rimusz/charts/tree/master/stable/hostpath-provisioner

     # delete default storage class
     kubectl delete storageclass standard

     echo "Install Hostpath Provisioner..."
     docker exec -e HELM_HOST=127.0.0.1:44134 -e HELM_TILLER_SILENT=true "$config_container_id" helm upgrade --install hostpath-provisioner --namespace kube-system test/hostpath-provisioner-0.2.3.tgz
     echo
}

main() {

    echo "Starting kind ..."
    echo
    run_kind

    local config_container_id
    config_container_id=$(docker run -it -d -v "/home:/home" -v "$REPO_ROOT:/workdir" \
        --workdir /workdir "$CHART_TESTING_IMAGE:$CHART_TESTING_TAG" cat)

    # shellcheck disable=SC2064
    trap "docker rm -f $config_container_id > /dev/null" EXIT

    # Get kind container IP
    kind_container_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kind-1-control-plane)
    # Copy kubeconfig file
    docker exec "$config_container_id" mkdir /root/.kube
    docker cp "$KUBECONFIG" "$config_container_id:/root/.kube/config"
    # Update localhost to kind container IP
    docker exec "$config_container_id" sed -i "s/localhost/$kind_container_ip/g" /root/.kube/config
    
    echo "Add git remote k8s ${CHARTS_REPO}"
    git remote add k8s "${CHARTS_REPO}" &> /dev/null || true
    git fetch k8s master
    echo

    # --- Work around for Tillerless Helm, till Helm v3 gets released --- #
    run_tillerless

    # Install hostpath-provisioner for Dynammic PVC provisioning
    install_hostpath-provisioner

    # shellcheck disable=SC2086
    docker exec -e HELM_HOST=127.0.0.1:44134 -e HELM_TILLER_SILENT=true "$config_container_id" ct install --config /workdir/test/ct.yaml

    echo "Done Testing!"
}

main
