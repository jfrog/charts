#!/usr/bin/env bash

set -o errexit
set -o pipefail

main() {

    echo "Install socat and util-linux"
    sudo apt-get update
    sudo apt-get install -y socat util-linux
    echo

    if [ -n "${GCLOUD_GKE_CLUSTER:-}" ]; then
        echo "PR is from main repo, running in GKE..."
        echo
        test/e2e-gke.sh
    else
        echo "PR is from fork, running in Minikube..."
        echo
        test/e2e-minikube.sh
    fi

}

main
