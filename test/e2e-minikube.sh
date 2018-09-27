#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

readonly REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel)}"

run_minikube() {
    echo "Install socat and util-linux"
    sudo apt-get update
    sudo apt-get install -y socat util-linux
    echo

    echo "Copy nsenter tool for Ubuntu 14.04 (current travisCI build VM version)"
    # shellcheck disable=SC2046
    sudo docker run --rm -v $(pwd):/target jpetazzo/nsenter
    sudo mv -fv nsenter /usr/local/bin/
    echo

    echo "Download kubectl, which is a requirement for using minikube..."
    curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/"${K8S_VERSION}"/bin/linux/amd64/kubectl && chmod +x kubectl && sudo mv kubectl /usr/local/bin/
    echo

    echo "Download Minikube..."
    curl -Lo minikube https://github.com/kubernetes/minikube/releases/download/"${MINIKUBE_VERSION}"/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
    echo

    echo "Setup Minikuke..."
    # TODO: remove the --bootstrapper flag once this issue is solved: https://github.com/kubernetes/minikube/issues/2704
    sudo minikube config set WantReportErrorPrompt false
    sudo -E minikube start --cpus 2 --memory 7168 --vm-driver=none --bootstrapper=localkube --kubernetes-version="${K8S_VERSION}" --extra-config=apiserver.Authorization.Mode=RBAC
    echo

    echo "Enable add-ons..."
    sudo minikube addons disable kube-dns
    sudo minikube addons enable coredns
    echo

    echo "Update kubectl context..."
    minikube update-context
    echo

    echo "Wait for Kubernetes to be up and ready..."
    JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}'; until kubectl get nodes -o jsonpath="$JSONPATH" 2>&1 | grep -q "Ready=True"; do sleep 1; done
    echo

    echo "Get cluster info..."
    kubectl cluster-info
    echo

    echo "Create cluster admin..."
    kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default
    echo
}

run_tillerless() {
     # -- Work around for Tillerless Helm, till Helm v3 gets released -- #
     echo "Install Tillerless Helm plugin..."
     # shellcheck disable=SC2154
     docker exec "$config_container_id" helm init --client-only
     # shellcheck disable=SC2154
     docker exec "$config_container_id" helm plugin install https://github.com/rimusz/helm-tiller
     # shellcheck disable=SC2154
     docker exec "$config_container_id" bash -c 'echo "Starting Tiller..."; helm tiller start-ci >/dev/null 2>&1 &'
     # shellcheck disable=SC2154
     docker exec "$config_container_id" bash -c 'echo "Waiting Tiller to launch on 44134..."; while ! nc -z localhost 44134; do sleep 1; done; echo "Tiller launched..."'
     echo
}

main() {

    echo "Starting Minikube..."
    echo
    run_minikube

    echo "Add git remote k8s ${CHARTS_REPO}"
    git remote add k8s "${CHARTS_REPO}" &> /dev/null || true
    git fetch k8s master
    echo

    local config_container_id
    config_container_id=$(docker run -it -d -v "/home:/home" -v "$REPO_ROOT:/workdir" \
        --workdir /workdir "$CHART_TESTING_IMAGE:$CHART_TESTING_TAG" cat)

    # shellcheck disable=SC2064
    trap "docker rm -f $config_container_id > /dev/null" EXIT

    # copy kubeconfig file
    docker cp /home/travis/.kube "$config_container_id:/root/.kube"

    # --- Work around for Tillerless Helm, till Helm v3 gets released --- #
    run_tillerless
    # shellcheck disable=SC2086
    docker exec -e HELM_HOST=localhost:44134 "$config_container_id" chart_test.sh --no-lint --config /workdir/test/.testenv_minikube
    # ------------------------------------------------------------------- #

    ##### docker exec -e KUBECONFIG="/home/travis/.kube/config" "$config_container_id" chart_test.sh --no-lint --config /workdir/test/.testenv ${CHART_TESTING_ARGS}

    echo "Done Testing!"
}

main
